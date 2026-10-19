from pathlib import Path
import pytest
from PIL import Image
from game.level import Level
from tools.art_build import TARGET_HEIGHTS

@pytest.mark.parametrize('number', range(1,6))
def test_small_potions_are_scarce(number):
    assert 2 <= sum(len(r.positions('h')) for r in Level(number).rooms.values()) <= 3

@pytest.mark.parametrize('actor,target', TARGET_HEIGHTS.items())
def test_idle_scale_and_feet(actor,target):
    frames=list(Path('assets/sprites',actor,'idle').glob('*.png'))
    assert frames
    for path in frames:
        bounds=Image.open(path).getbbox()
        assert abs(bounds[3]-bounds[1]-target)<=3
        assert abs(bounds[3]-60)<=2

@pytest.mark.parametrize('actor',['shade','morrow'])
def test_tenebri_dissolve_finishes_in_eight_tenths(actor):
    import pygame
    from game.world import World
    from game.assets import Assets
    from game.render import Renderer
    from game.enemy import Enemy
    w=World();w.enemies=[Enemy(x=240,y=160,hp=0,kind=actor,dead_time=.4)]
    r=Renderer(Assets());surface=pygame.Surface((480,270));r.draw(surface,w)
    fading=surface.copy();w.enemies[0].dead_time=.8;r.draw(surface,w)
    assert pygame.image.tobytes(fading,'RGB')!=pygame.image.tobytes(surface,'RGB')
