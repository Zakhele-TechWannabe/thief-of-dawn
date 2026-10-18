from dataclasses import dataclass
import pygame
from .config import GRAVITY

@dataclass
class LooseFloor:
    x: int
    y: int
    timer: float = -1
    falling: bool = False
    py: float = 0
    vy: float = 0
    broken: bool = False

    def update(self,dt,world):
        if self.broken:return
        if self.timer<0:
            if any(a.hp>0 and abs(a.x-(self.x*16+8))<13 and abs(a.y-self.y*16)<2 for a in [world.player]+world.enemies):
                self.timer=.5
        elif not self.falling:
            self.timer-=dt
            if self.timer<=0:
                self.falling=True;self.py=self.y*16
                world.room.grid[self.y][self.x]='.'
                world.audio.play('crumble')
        else:
            self.vy+=GRAVITY*dt
            old=self.py;self.py+=self.vy*dt
            for actor in [world.player]+world.enemies:
                if abs(actor.x-(self.x*16+8))<14 and old<=actor.y-28<=self.py+8:
                    actor.hurt(1)
            if self.py>256 or world.room.solid(self.x,int((self.py+8)//16),world.gates):self.broken=True

class Traps:
    def __init__(self,room):
        self.loose=[LooseFloor(x,y) for x,y in room.positions('L')]
        self.timers={}
        self.clock=0

    def update(self,dt,world,held):
        self.clock+=dt
        for obj in self.loose:obj.update(dt,world)
        for x,y in world.room.positions('p'):
            if any(a.hp>0 and abs(a.x-(x*16+8))<14 and abs(a.y-(y+1)*16)<3 for a in [world.player]+world.enemies):
                for target in world.room.links.get(f'{x},{y}',[]):
                    world.activate_gate(target)
        for actor in [world.player]+world.enemies:
            if actor.hp<=0:continue
            for x,y in world.room.positions('^'):
                box=pygame.Rect(x*16+2,y*16+7,12,9)
                if actor.rect.colliderect(box):
                    safe=actor is world.player and 'shift' in held and actor.grounded and not actor.landed and abs(actor.vx)<=29
                    if not safe:actor.hurt(99)
            for x,y in world.room.positions('|'):
                if self.slicer_active(x) and actor.rect.colliderect(pygame.Rect(x*16+5,(y-2)*16,6,48)):
                    actor.hurt(99)

    def slicer_active(self,x):
        return (self.clock+x*.19)%2.4<.42
