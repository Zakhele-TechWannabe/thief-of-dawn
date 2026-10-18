"""Offline rebuild from art/raw, including actor scale and foot registration."""
from pathlib import Path
import runpy
import sys

TARGET_HEIGHTS = {'kael': 46, 'shade': 46, 'vesh': 50, 'morrow': 54}

def fit_actor(im, actor, anim):
    """Register opaque bounds without cropping; upright poses share actor height.

    Fallen bodies retain their pose proportions. Registration keeps every
    opaque pixel inside the canvas; horizontal placement follows the feet.
    """
    from PIL import Image
    box = im.getbbox()
    if not box:
        return im
    cut = im.crop(box)
    height = TARGET_HEIGHTS[actor]
    if anim == 'death':
        height = min(height, cut.height)
    width = round(cut.width * height / cut.height)
    cut = cut.resize((width, height), Image.Resampling.NEAREST)
    if width > 64:
        raise ValueError(f'{actor}/{anim}: pose exceeds 64 px; review source bounds')
    alpha=cut.getchannel('A')
    feet=[x for y in range(max(0,height-3),height) for x in range(width) if alpha.getpixel((x,y))]
    foot_x=sum(feet)/len(feet) if feet else width/2
    offset=max(0,min(64-width,round(32-foot_x)))
    canvas = Image.new('RGBA', (64, 64))
    canvas.alpha_composite(cut, (offset, 60-height))
    return canvas

if __name__ == '__main__':
    art_directory = Path(__file__).resolve().parents[1] / 'art'
    sys.path.insert(0, str(art_directory))
    runpy.run_path(str(art_directory / 'art_build.py'), run_name='__main__')
