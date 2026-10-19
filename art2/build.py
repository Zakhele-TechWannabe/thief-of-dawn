"""Package art2/raw Kael frames into assets/sprites/kael2 (96x96 frames, feet anchor from the base sprite)."""
import json
from pathlib import Path
from PIL import Image

RAW = Path(__file__).resolve().parent / "raw"
OUT = Path(__file__).resolve().parents[1] / "assets" / "sprites" / "kael2"
SPEC = {  # anim: (fps, loop, expected frames)
    "idle": (6, True, 6), "run": (12, True, 8), "jump": (12, False, 6), "fall": (8, True, 4),
    "attack1": (18, False, 6), "attack2": (16, False, 6), "roll": (16, False, 6), "block": (12, False, 4),
    "hurt": (12, False, 4), "death": (8, False, 8), "hang": (6, True, 4), "climb": (12, False, 6),
}

def clean(im):
    """Hard alpha edges: no soft halos when scaled with nearest-neighbour."""
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255 if a >= 128 else 0)
    return im

base = clean(Image.open(RAW / "kael_flash_00.png"))
l, t, r, b = base.getbbox()
anchor = [48, b]
meta = {"frame_size": [96, 96], "anchor": anchor, "anims": {}}
for anim, (fps, loop, n) in SPEC.items():
    frames = sorted(RAW.glob(f"kael_{anim}_[0-9][0-9].png"))
    if not frames:
        print("missing", anim)
        continue
    if len(frames) == n + 1:      # the first frame is the reference pose; loops read better without it
        frames = frames[1:] if loop else frames
    d = OUT / anim
    d.mkdir(parents=True, exist_ok=True)
    for old in d.glob("*.png"):
        old.unlink()
    for i, f in enumerate(frames):
        clean(Image.open(f)).save(d / f"{i:02}.png")
    meta["anims"][anim] = {"fps": fps, "loop": loop}
    print(anim, len(frames))
(OUT / "meta.json").write_text(json.dumps(meta, indent=2))
print("anchor", anchor)
