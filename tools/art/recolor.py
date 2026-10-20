"""Deterministic local stand-ins; preserves frame geometry and sprite metadata."""
from pathlib import Path
from PIL import Image
import colorsys
import shutil

ROOT = Path(__file__).resolve().parents[2]

def recolor(source, target, guard=False):
    src = ROOT / 'assets/sprites' / source
    dst = ROOT / 'assets/sprites' / target
    for path in sorted(src.rglob('*')):
        out = dst / path.relative_to(src)
        if path.suffix not in ('.png', '.json'):
            continue
        out.parent.mkdir(parents=True, exist_ok=True)
        if path.suffix == '.json':
            shutil.copyfile(path, out)
            continue
        im = Image.open(path).convert('RGBA')
        pixels = []
        for r, g, b, a in im.getdata():
            h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
            if a and ((0.18 < h < 0.48 and s > .15) or (guard and .04 < h < .16 and s > .25 and v > .45)):
                # Bright green/yellow skin becomes slate blue; dark cloth becomes brown-grey.
                h, s = (.59, .36) if v > .38 else (.08, .18)
            elif guard and a and (h < .06 or h > .92) and s > .25:
                h, s = .08, .18
            elif not guard and a and v < .19 and s < .38:
                h, s, v = .085, .48, min(.52, v * 1.55 + .13)
            rr, gg, bb = colorsys.hsv_to_rgb(h, s, v)
            pixels.append((round(rr*255), round(gg*255), round(bb*255), a))
        im.putdata(pixels)
        im.save(out)

if __name__ == '__main__':
    recolor('kael2', 'renn_standin')
    recolor('kael2_ledge', 'renn_standin_ledge')
    recolor('vesh', 'watch_standin', True)
    print('Stand-ins built locally')
