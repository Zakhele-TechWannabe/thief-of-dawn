from dataclasses import dataclass, field
import pygame
from .config import *
from .physics import approach, fall_damage

@dataclass
class Player:
    x: float = 40
    y: float = 208
    vx: float = 0
    vy: float = 0
    hp: int = 3
    max_hp: int = 3
    sword: bool = False
    facing: int = 1
    grounded: bool = True
    landed: bool = False
    state: str = 'idle'
    age: float = 0
    ground_y: float = 208
    fall_start: float = 208
    coyote: float = 0
    jump_buffer: float = 0
    stun: float = 0
    invulnerable: float = 0
    attack_time: float = 0
    block_time: float = 0
    hit_done: bool = False
    hang_edge: tuple | None = None
    climb_time: float = 0
    dead_time: float = 0
    en_garde: bool = False

    @property
    def rect(self):
        height=30 if self.state=='crouch' and self.grounded else 46
        return pygame.Rect(round(self.x-6),round(self.y-height),12,height)

    def hurt(self, amount=1, knock=0):
        if self.hp <= 0 or self.invulnerable > 0:
            return False
        self.hp=max(0,self.hp-amount)
        self.invulnerable=.65
        self.stun=.35
        self.vx=knock
        self.state='death' if not self.hp else 'hurt'
        return True

    def jump(self, running=False):
        self.vy=-JUMP_SPEED
        self.vx=self.facing*(RUN_SPEED if running else WALK_SPEED) if self.vx else 0
        self.grounded=False
        self.coyote=0
        self.fall_start=self.y
        self.state='jump'

    def update(self, dt, held, pressed, world):
        was_grounded=self.grounded
        self.landed=False
        self.age+=dt
        self.invulnerable=max(0,self.invulnerable-dt)
        self.stun=max(0,self.stun-dt)
        self.attack_time=max(0,self.attack_time-dt)
        self.block_time=self.block_time+dt if 'x' in held else 0
        if self.hp<=0:
            self.dead_time+=dt
            self.state='death'
            return
        if self.climb_time>0:
            self.climb_time-=dt
            self.state='climb'
            if self.climb_time<=0:
                self.x,self.y=self.hang_edge
                self.hang_edge=None
                self.grounded=True
                self.ground_y=self.y
                self.fall_start=self.y
            return
        if self.hang_edge:
            self.state='hang'
            self.vx=self.vy=0
            if 'up' in pressed:
                self.climb_time=.42
            elif 'down' in pressed:
                self.hang_edge=None
                self.y+=9
                self.fall_start=self.y
                self.stun=.15
            return
        crouching = self.grounded and ('down' in held or (self.state=='crouch' and world.collides(pygame.Rect(round(self.x-6),round(self.y-46),12,46))))
        if crouching:self.state='crouch'
        if 'up' in pressed and not crouching:
            self.jump_buffer=.10
        else:self.jump_buffer=max(0,self.jump_buffer-dt)
        self.coyote=.07 if self.grounded else max(0,self.coyote-dt)
        direction=int('right' in held)-int('left' in held)
        careful='shift' in held
        if direction:self.facing=direction
        if self.sword and ('z' in pressed or 'space' in pressed) and not self.attack_time and not self.stun:
            self.attack_time=.48
            self.hit_done=False
            world.audio.play('sword')
        speed=CAREFUL_SPEED if careful else WALK_SPEED if self.en_garde else RUN_SPEED
        if self.grounded:
            target=direction*(CAREFUL_SPEED if crouching else speed) if not self.stun and not self.attack_time and 'x' not in held else 0
            self.vx=approach(self.vx,target,dt*(560 if target else 720))
        if self.jump_buffer and self.coyote and not self.stun:
            self.jump(abs(self.vx)>78)
            self.jump_buffer=0
            world.audio.play('jump')
        old_x,old_y=self.x,self.y
        nx=self.x+self.vx*dt
        if self.grounded and not world.support_at(nx+self.facing*6,self.y):
            if careful:
                nx=self.x;self.vx=0
            elif 'down' in held:
                edge_x=(int((self.x+self.facing*7)//16)+(0 if self.facing>0 else 1))*16
                self.hang_edge=(edge_x-self.facing*7,self.y)
                self.x=edge_x+self.facing*6
                self.y+=44
                self.grounded=False
                self.state='hang'
                return
        self.x=nx
        if world.collides(self.rect):
            self.x=old_x;self.vx=0
        self.vy+=GRAVITY*dt
        self.y+=self.vy*dt
        self.fall_start=min(self.fall_start,self.y)
        self.grounded=False
        if self.vy>=0:
            floor=world.landing(self.rect,old_y,self.y)
            if floor is not None:
                self.y=floor;self.vy=0;self.grounded=True;self.ground_y=floor;self.landed=not was_grounded
                damage=fall_damage(self.y-self.fall_start)
                if damage:self.hurt(damage);world.audio.play('hurt')
                self.fall_start=self.y
        elif world.collides(self.rect):
            self.y=old_y;self.vy=0
        if not self.grounded and ('up' in held or careful) and self.stun<=0:
            edge=world.grab_edge(self)
            if edge:
                self.hang_edge=edge
                self.x=edge[0]-self.facing*12
                self.y=edge[1]+44
                self.vx=self.vy=0
                self.state='hang'
                return
        if self.y>ROOM_H+64:self.hurt(99)
        if self.hp<=0:self.state='death'
        elif self.stun:self.state='hurt'
        elif self.attack_time:self.state='attack'
        elif self.sword and 'x' in held:self.state='block'
        elif not self.grounded:self.state='jump' if self.vy<0 else 'fall'
        elif crouching:self.state='crouch'
        elif abs(self.vx)>4:self.state='run'
        else:self.state='idle_sword' if self.sword else 'idle'
