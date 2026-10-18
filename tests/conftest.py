import os
import sys
from pathlib import Path
os.environ['SDL_VIDEODRIVER']='dummy'
os.environ['SDL_AUDIODRIVER']='dummy'
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import pygame
import pytest

@pytest.fixture(scope='session',autouse=True)
def pygame_session():
    pygame.init();pygame.display.set_mode((480,270))
    yield
    pygame.quit()

@pytest.fixture
def world():
    from game.world import World
    w=World()
    w.room.grid=[list('.'*30) for _ in range(16)]
    w.room.grid[13]=list('#'*30)
    w.player.y=w.player.ground_y=w.player.fall_start=208
    return w
