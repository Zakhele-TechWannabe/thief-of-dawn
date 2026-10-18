"""Tiny cached mono sounds from signed raw sample buffers; no numpy required."""
import math
from array import array
import pygame

class Audio:
    def __init__(self):
        self.muted=False
        self.sounds={}
        try:
            if not pygame.mixer.get_init():pygame.mixer.init(22050,-16,1,256)
            rate,_,channels=pygame.mixer.get_init()
            for name,freq in [('jump',310),('hurt',110),('sword',650),('hit',150),('parry',950),('block',540),('pickup',780),('crumble',75),('shadow',190)]:
                samples=array('h')
                for i in range(int(rate*.12)):
                    value=int(3300*(1-i/(rate*.12))*math.sin(2*math.pi*freq*i/rate))
                    samples.extend([value]*channels)
                self.sounds[name]=pygame.mixer.Sound(buffer=samples.tobytes())
        except (pygame.error,ValueError):pass

    def play(self,name):
        if not self.muted and name in self.sounds:
            try:self.sounds[name].play()
            except pygame.error:pass
