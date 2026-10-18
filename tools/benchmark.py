"""Measure actual update + render, including every headless frame."""
import os
os.environ.setdefault('SDL_VIDEODRIVER','dummy')
os.environ.setdefault('SDL_AUDIODRIVER','dummy')
import sys,time,json
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import pygame
from game.world import World
from game.assets import Assets
from game.render import Renderer

def benchmark():
    pygame.init();pygame.display.set_mode((480,270))
    canvas=pygame.Surface((480,270));renderer=Renderer(Assets());result={}
    for n in (3,5):
        w=World(n);w.audio.muted=True
        renderer.draw(canvas,w)
        start=time.perf_counter()
        for _ in range(1200):
            w.update(1/60);renderer.draw(canvas,w)
        result[n]=(time.perf_counter()-start)*1000/1200
    pygame.quit()
    return result

if __name__=='__main__':print(json.dumps(benchmark(),indent=2))
