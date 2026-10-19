"""Budget-guarded PixelLab API v2 client. The ONLY way this project talks to PixelLab.

Hard cap: the owner allowed $1.00 total for this game. Spend is measured from the account's real balance
(GET /balance) against the baseline recorded in art/ledger.json on first use, so the cap holds even if a
request's cost is unknown. A request is refused when spent + its estimate would pass the cap.

    from tools.pixellab import call, poll, spent
    resp = call("create-image-pixflux", {...}, est_usd=0.02, note="hero portrait")

The API key is read from .env (PIXELLAB_API_KEY or PIXEL_API_KEY) and is never printed or logged.
"""
import json
import os
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEDGER = ROOT / "art" / os.environ.get("PIXELLAB_LEDGER", "ledger.json")  # one ledger per budget
API = "https://api.pixellab.ai/v2"
CAP_USD = 1.00


class BudgetError(RuntimeError):
    pass


def _key() -> str:
    for name in ("PIXELLAB_API_KEY", "PIXEL_API_KEY"):
        if os.environ.get(name, "").strip():
            return os.environ[name].strip()
    env = ROOT / ".env"
    if env.exists():
        for line in env.read_text().splitlines():
            name, _, value = line.partition("=")
            if name.strip() in ("PIXELLAB_API_KEY", "PIXEL_API_KEY") and value.strip():
                return value.strip().strip('"').strip("'")
    raise RuntimeError("no PixelLab key in .env")


def _request(method: str, path: str, body=None, timeout=180) -> dict:
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + "/" + path.lstrip("/"), data=data, method=method, headers={
        "Authorization": "Bearer " + _key(), "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read() or b"{}")
    except urllib.error.HTTPError as err:
        raise RuntimeError(f"PixelLab {method} {path} -> HTTP {err.code}: {err.read()[:800].decode(errors='replace')}")


def balance() -> float:
    return float(_request("GET", "balance")["credits"]["usd"])


def _ledger() -> dict:
    if LEDGER.exists():
        return json.loads(LEDGER.read_text())
    LEDGER.parent.mkdir(parents=True, exist_ok=True)
    ledger = {"cap_usd": CAP_USD, "baseline_usd": balance(), "calls": []}
    LEDGER.write_text(json.dumps(ledger, indent=2))
    return ledger


def spent() -> float:
    """Real spend so far: baseline balance minus current balance."""
    return max(0.0, _ledger()["baseline_usd"] - balance())


def call(endpoint: str, payload: dict, *, est_usd: float = 0.05, note: str = "") -> dict:
    """POST a generation request after checking the cap. Records the real cost (balance difference)."""
    ledger = _ledger()
    before = balance()
    so_far = ledger["baseline_usd"] - before
    if so_far + est_usd > ledger["cap_usd"] + 1e-9:
        raise BudgetError(f"refused: ${so_far:.4f} spent + ${est_usd:.4f} estimate > ${ledger['cap_usd']:.2f} cap")
    resp = _request("POST", endpoint, payload)
    job = resp.get("background_job_id") or resp.get("job_id")
    if job:
        resp = poll(job)
    after = balance()
    ledger["calls"].append({"time": time.strftime("%Y-%m-%dT%H:%M:%S"), "endpoint": endpoint, "note": note,
                            "cost_usd": round(before - after, 5), "spent_total_usd": round(ledger["baseline_usd"] - after, 5)})
    LEDGER.write_text(json.dumps(ledger, indent=2))
    return resp


def poll(job_id: str, timeout_s: int = 600) -> dict:
    """Wait for an async background job and return its final payload."""
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        status = _request("GET", f"background-jobs/{job_id}")
        state = str(status.get("status", "")).lower()
        if state in ("completed", "complete", "succeeded", "success", "done"):
            return status
        if state in ("failed", "error", "cancelled", "canceled"):
            raise RuntimeError(f"job {job_id} {state}: {json.dumps(status)[:800]}")
        time.sleep(4)
    raise TimeoutError(f"job {job_id} still running after {timeout_s}s")


def get(path: str) -> dict:
    """Free GET (character/tileset details, exports)."""
    return _request("GET", path)


if __name__ == "__main__":
    print(f"spent ${spent():.4f} of ${CAP_USD:.2f}")
