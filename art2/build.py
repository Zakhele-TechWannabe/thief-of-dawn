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

# hand-picked frame ranges (source indices after the reference-frame drop); the generator pads starts with idle poses
PICK = {"jump": ("jump", [4, 5]), "fall": ("jump", [5, 6]), "attack1": ("attack1", [2, 3, 4, 5, 6]),
        "attack2": ("attack2", [1, 2, 3, 4, 5, 6]), "roll": ("roll", [2, 3, 4, 5, 6]), "hurt": ("hurt", [3, 4]),
        "block": ("block", [2, 3, 4])}

base = clean(Image.open(RAW / "kael_flash_00.png"))
l, t, r, b = base.getbbox()
anchor = [48, b]
meta = {"frame_size": [96, 96], "anchor": anchor, "anims": {}}
for anim, (fps, loop, n) in SPEC.items():
    src_anim, pick = PICK.get(anim, (anim, None))
    frames = sorted(RAW.glob(f"kael_{src_anim}_[0-9][0-9].png"))
    if pick:
        frames = [frames[i] for i in pick if i < len(frames)]
        n = -1
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


def build_actor(actor, prefix, base_name, spec, faces="right"):
    """Generic packer: frames art2/raw/<prefix>_<anim>_NN.png -> assets/sprites/<actor>/<anim>/NN.png."""
    out = OUT.parent / actor
    b = clean(Image.open(RAW / base_name)).getbbox()
    meta = {"frame_size": [96, 96], "anchor": [48, b[3]], "faces": faces, "anims": {}}
    for anim, (fps, loop, pick) in spec.items():
        frames = sorted(RAW.glob(f"{prefix}_{anim}_[0-9][0-9].png"))
        if pick:
            frames = [frames[i] for i in pick if i < len(frames)]
        if not frames:
            print(actor, "missing", anim)
            continue
        d = out / anim
        d.mkdir(parents=True, exist_ok=True)
        for old in d.glob("*.png"):
            old.unlink()
        for i, f in enumerate(frames):
            clean(Image.open(f)).save(d / f"{i:02}.png")
        meta["anims"][anim] = {"fps": fps, "loop": loop}
        print(actor, anim, len(frames))
    (out / "meta.json").write_text(json.dumps(meta, indent=2))


def strip_ledge(src, dst):
    """Hang/climb art includes a strip of ledge stone; the level's tiles provide the ledge, so remove grey stone/vines."""
    im = clean(Image.open(src))
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            mx, mn = max(r, g, b), min(r, g, b)
            grey = mx - mn < 26 and mx > 70          # stone
            vine = g > r + 12 and g > b + 12 and y < 30 and (r + g + b) < 330 and not (60 < r < 200 and g > 150)
            if (grey and y < 40) or (vine and y < 16):
                px[x, y] = (0, 0, 0, 0)
    im.save(dst)


if __name__ == "__main__":
    import sys
    if "shade" in sys.argv:
        build_actor("shade2", "shade", "shade_flash_s3_00.png", {
            "idle": (8, True, None), "walk": (10, True, None), "attack": (16, False, None),
            "block": (10, False, None), "hurt": (12, False, None), "death": (10, False, None)}, faces="left")
    if "hang" in sys.argv:
        for prefix in ("kael_hangidle", "kael_climbup"):
            for f in sorted(RAW.glob(f"{prefix}_[0-9][0-9].png")):
                strip_ledge(f, RAW / f.name.replace(prefix, prefix + "_clean"))
