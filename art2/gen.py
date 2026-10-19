"""Second art budget ($1, ledger art/ledger-godot.json): new Kael for the Godot version. Run from repo root."""
import base64, io, json, os, sys
from pathlib import Path
os.environ.setdefault("PIXELLAB_LEDGER", "ledger-godot.json")
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "art"))
from tools.pixellab import call, spent
from raw_images import images
RAW = Path(__file__).resolve().parent / "raw"

def b64(path):
    return {"type": "base64", "base64": base64.b64encode(Path(path).read_bytes()).decode()}

def request(name, endpoint, payload, est):
    out = RAW / (name + ".json")
    if out.exists():
        res = json.loads(out.read_text())
    else:
        print(f"{name}: spent so far ${spent():.4f}", flush=True)
        res = call(endpoint, payload, est_usd=est, note=name)
        out.write_text(json.dumps(res))
    ims = images(res)
    for i, im in enumerate(ims):
        im.save(RAW / f"{name}_{i:02}.png")
    print(name, [im.size for im in ims], flush=True)
    return ims

KAEL = ("young swordsman hero, green skin, black hair tied in a short ponytail, emerald eyes, dark green tunic "
        "with ochre sash, brown leather bracers and boots, holding a curved steel short sword in his right hand, "
        "ready stance, full body, side view facing right")

if __name__ == "__main__":
    what = sys.argv[1]
    if what == "base":
        for seed in (11, 22, 33):
            request(f"kael_base_s{seed}", "create-image-bitforge", {
                "description": KAEL, "image_size": {"width": 96, "height": 96}, "no_background": True,
                "style_image": b64("art2/raw/style_vesh96.png"), "style_strength": 45,
                "view": "side", "direction": "east", "outline": "single color black outline",
                "shading": "detailed shading", "detail": "highly detailed", "seed": seed}, 0.03)
    print(f"total spent ${spent():.4f}")

def base2():
    for seed in (5, 6):
        request(f"kael_px_s{seed}", "create-image-pixflux", {
            "description": KAEL + ", clean readable silhouette, 72 pixels tall", "image_size": {"width": 96, "height": 96},
            "no_background": True, "view": "side", "direction": "east", "outline": "single color black outline",
            "shading": "medium shading", "detail": "medium detail", "text_guidance_scale": 9, "seed": seed}, 0.02)
    request("kael_flash", "create-image-pro-flash", {
        "description": "Side-scroller game sprite, " + KAEL + ". Clean readable silhouette, about 72 px tall, feet at the bottom.",
        "image_size": {"width": 96, "height": 96}, "no_background": True, "seed": 7}, 0.06)

if __name__ == "__main__" and sys.argv[1] == "base2":
    base2(); print(f"total spent ${spent():.4f}")

KEEP = (" Keep exactly the same character design, colours, outfit, sword and scale; side view facing right the whole time;"
        " no camera movement, no background, no giant effect swooshes.")
ANIMS = [
    ("idle", "standing in a relaxed sword-ready stance, breathing slowly, slight sway of the ponytail", 6),
    ("run", "running fast to the right, full running cycle with arms pumping, sword held low in the right hand", 8),
    ("jump", "crouches and leaps upward, knees tucked, rising through the air", 6),
    ("fall", "falling downward through the air, legs slightly apart, arms raised for balance", 4),
    ("attack1", "a fast horizontal sword slash forward to the right, then recovers to the ready stance", 6),
    ("attack2", "a powerful rising diagonal backhand sword slash upward to the right, then recovers", 6),
    ("roll", "a quick forward dodge roll to the right, tucking into a ball and rolling, ending crouched back on the feet", 6),
    ("block", "raises the sword horizontally in front of his body to parry a blow, braced", 4),
    ("hurt", "flinches backward from a hit to the chest, staggering", 4),
    ("death", "staggers, drops to his knees, then collapses face down on the ground motionless", 8),
    ("hang", "hanging from a ledge above with both hands, body dangling below, legs swaying slightly", 4),
    ("climb", "pulls himself up from hanging on a ledge above and climbs onto it, ending standing on top", 6),
]

def anims():
    base = {"type": "base64", "base64": base64.b64encode((RAW / "kael_flash_00.png").read_bytes()).decode()}
    for name, action, n in ANIMS:
        try:
            request("kael_" + name, "animate-with-text-v3", {"first_frame": base, "action": action + "." + KEEP,
                    "frame_count": n, "no_background": True}, 0.04)
        except Exception as err:  # keep going; report at the end
            print("FAILED", name, str(err)[:300], flush=True)

if __name__ == "__main__" and sys.argv[1] == "anims":
    anims(); print(f"total spent ${spent():.4f}")

SHADE = ("Tenebri shade warrior: a spectral humanoid of living shadow, dark violet semi-transparent body with wispy "
         "smoky edges, hooded, glowing pale lilac eyes, holding a curved black blade, menacing ready stance, full body, "
         "side view facing left")

if __name__ == "__main__" and sys.argv[1] == "shade_base":
    for seed in (3, 4):
        request(f"shade_flash_s{seed}", "create-image-pro-flash", {
            "description": "Side-scroller game sprite, " + SHADE + ". Clean readable silhouette, about 70 px tall, feet at the bottom.",
            "image_size": {"width": 96, "height": 96}, "no_background": True, "seed": seed}, 0.06)
    print(f"total spent ${spent():.4f}")

SHADE_KEEP = (" Keep exactly the same shadowy hooded design, violet smoke wisps, glowing eyes, curved blade and scale;"
              " side view facing left the whole time; no camera movement, no background.")
SHADE_ANIMS = [
    ("idle", "hovering menacingly in place, smoky wisps drifting, slight bob", 6),
    ("walk", "stalking forward to the left with slow menacing steps, smoke trailing", 6),
    ("attack", "draws the curved blade back then slashes forward hard to the left, then recovers", 6),
    ("block", "raises the curved blade defensively in front of its body, braced", 4),
    ("hurt", "recoils backward from a hit, body flickering and smoke bursting", 4),
    ("death", "comes apart: the body unravels into drifting violet smoke and fades away completely", 8),
]

if __name__ == "__main__" and sys.argv[1] == "shade_anims":
    base = {"type": "base64", "base64": base64.b64encode((RAW / "shade_flash_s3_00.png").read_bytes()).decode()}
    for name, action, n in SHADE_ANIMS:
        try:
            request("shade_" + name, "animate-with-text-v3", {"first_frame": base, "action": action + "." + SHADE_KEEP,
                    "frame_count": n, "no_background": True}, 0.04)
        except Exception as err:
            print("FAILED", name, str(err)[:300], flush=True)
    print(f"total spent ${spent():.4f}")

if __name__ == "__main__" and sys.argv[1] == "hang_base":
    ref = {"image": {"type": "base64", "base64": base64.b64encode((RAW / "kael_flash_00.png").read_bytes()).decode()}, "size": {"width": 96, "height": 96}}
    for seed in (21, 22):
        request(f"kael_hangbase_s{seed}", "create-image-pro-flash", {
            "description": ("Side-scroller game sprite, side view facing right: the same young green-skinned swordsman "
                            "(black ponytail, dark green tunic, ochre sash, brown bracers and boots) HANGING from a stone "
                            "ledge: both arms stretched straight up gripping the ledge edge at the top of the image, body "
                            "dangling straight down below the hands, legs hanging, curved sword sheathed at his hip. "
                            "Hands at the very top centre, feet near the bottom."),
            "image_size": {"width": 96, "height": 96}, "no_background": True, "seed": seed,
            "style_image": ref, "style_options": {"color_palette": True, "outline": True, "detail": True, "shading": True}}, 0.06)
    print(f"total spent ${spent():.4f}")

if __name__ == "__main__" and sys.argv[1] == "climb":
    base = {"type": "base64", "base64": base64.b64encode((RAW / "kael_hangbase_s22_00.png").read_bytes()).decode()}
    request("kael_climbup", "animate-with-text-v3", {"first_frame": base, "action": (
        "pulls himself up with both arms, swings a knee over the stone ledge and climbs on top of it, ending crouched "
        "on top of the ledge. Keep exactly the same character, outfit and scale; no camera movement, no background."),
        "frame_count": 6, "no_background": True}, 0.04)
    request("kael_hangidle", "animate-with-text-v3", {"first_frame": base, "action": (
        "hangs from the ledge by both hands, body swaying very slightly, legs dangling. Keep exactly the same "
        "character, outfit and scale; no camera movement, no background."), "frame_count": 4, "no_background": True}, 0.04)
    print(f"total spent ${spent():.4f}")
