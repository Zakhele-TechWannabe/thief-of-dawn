import copy
import random
import pygame
from .level import Level
from .player import Player
from .enemy import Enemy
from .traps import Traps
from .combat import strike
from .audio import Audio

class World:
    def __init__(self,number=1,room=None,max_hp=3,time_left=2700,seed=0,audio=None):
        self.level=Level(number)
        self.coord=tuple(room) if room is not None else self.level.start_room
        if self.coord not in self.level.rooms:raise ValueError(f'No room {self.coord} in level {number}')
        feet=self.level.rooms[self.coord].data.get('entry',self.level.start) if room is not None else self.level.start
        self.player=Player(x=feet[0],y=feet[1],hp=max_hp,max_hp=max_hp,sword=number>1)
        self.time_left=time_left
        self.rng=random.Random(seed)
        self.audio=audio or Audio()
        self.room_states={}
        self.gate_states={}
        self.gate_timers={}
        self.completed=False
        self.deaths=0
        self.enter_room(self.coord,self.player.x,self.player.y)

    def enter_room(self,coord,x,y, momentum=False):
        velocity=(self.player.vx,self.player.vy)
        invulnerable=self.player.invulnerable
        offset=(self.coord[1]-coord[1])*256
        fall_start=self.player.fall_start+offset
        ground_y=self.player.ground_y+offset
        self.coord=coord
        self.room=copy.deepcopy(self.room_states.get(coord,self.level.rooms[coord]))
        self.gates=self.gate_states.setdefault(coord,{})
        self.traps=Traps(self.room)
        self.enemies=[Enemy.from_data(data) for data in self.room.enemies if self.player.sword or self.level.number>1]
        self.pending_enemies=[]
        p=self.player
        p.x=x;p.y=y;p.vx=p.vy=0;p.fall_start=y;p.ground_y=y;p.grounded=self.support_at(x,y)
        p.hang_edge=None;p.climb_time=0;p.dead_time=0;p.invulnerable=.3
        if momentum:
            p.vx,p.vy=velocity
            p.invulnerable=invulnerable
            p.fall_start=fall_start;p.ground_y=ground_y
        self.checkpoint=(copy.deepcopy(p),copy.deepcopy(self.room))
        self.checkpoint_gates=copy.deepcopy((self.gate_states,self.gate_timers))

    def restart_room(self):
        saved,room=self.checkpoint
        self.player=copy.deepcopy(saved)
        self.room=copy.deepcopy(room)
        self.gate_states,self.gate_timers=copy.deepcopy(self.checkpoint_gates)
        self.gates=self.gate_states.setdefault(self.coord,{})
        self.traps=Traps(self.room)
        self.enemies=[Enemy.from_data(data) for data in self.room.enemies if self.player.sword or self.level.number>1]
        self.pending_enemies=[]
        self.completed=False
        self.deaths+=1

    def solid(self,x,y):
        coord=(self.coord[0]+x//30,self.coord[1]+y//16)
        room=self.room if coord==self.coord else self.room_states.get(coord,self.level.rooms.get(coord))
        return bool(room and room.solid(x%30,y%16,self.gate_states.get(coord,{})))

    def activate_gate(self, target):
        at=target['at']
        coord=tuple(at[:2]) if len(at)==4 else self.coord
        key=tuple(at[-2:])
        self.gate_states.setdefault(coord,{})[key]=True
        if target.get('seconds'):
            self.gate_timers[(coord,key)]=target['seconds']

    def save_room(self):
        self.room_states[self.coord]=copy.deepcopy(self.room)
        if self.level.number==1 and not self.player.sword:return
        self.room_states[self.coord].enemies=[{'kind':e.kind,'feet':[e.x,e.y],'hp':e.hp,'max_hp':e.max_hp,'skill':e.skill,'summoned':e.summoned} for e in self.enemies if e.hp>0]


    def support_at(self,x,y):
        return self.solid(int(x//16),int((y+.5)//16))

    def collides(self,rect):
        for y in range(rect.top//16,(rect.bottom-1)//16+1):
            for x in range(rect.left//16,(rect.right-1)//16+1):
                if self.solid(x,y):return True
        return False

    def landing(self,rect,old_y,new_y):
        if new_y<old_y:return None
        for row in range(int(old_y//16),int(new_y//16)+1):
            floor=row*16
            if old_y-.01<=floor<=new_y+.01:
                if any(self.solid(col,row) for col in range(rect.left//16,(rect.right-1)//16+1)):return floor
        return None

    def grab_edge(self,p):
        hand_y=p.y-43
        for row in range(int(hand_y//16)-1,int(hand_y//16)+2):
            top=row*16
            if abs(hand_y-top)>10 or p.ground_y-top>80:continue
            col=int((p.x+p.facing*12)//16)
            if self.solid(col,row) and not self.solid(col,row-1):
                edge=col*16 if p.facing>0 else (col+1)*16
                if abs(edge-p.x)>19:continue
                if all(not self.solid(col,yy) for yy in range(row-3,row)):
                    return (edge+p.facing*7,top)
        return None

    def update(self,dt,held=(),pressed=()):
        if self.completed or self.time_left<=0:return
        self.time_left=max(0,self.time_left-dt)
        for gate in list(self.gate_timers):
            self.gate_timers[gate]-=dt
            if self.gate_timers[gate]<=0:
                coord,key=gate
                self.gate_states[coord][key]=False
                del self.gate_timers[gate]
        p=self.player
        p.en_garde=p.sword and any(e.hp>0 and abs(e.x-p.x)<100 and abs(e.y-p.y)<20 for e in self.enemies)
        p.update(dt,held,pressed,self)
        if p.hp<=0:
            if p.dead_time>=1.05:self.restart_room()
            return
        for e in self.enemies:e.update_ai(dt,self)
        self.enemies.extend(self.pending_enemies);self.pending_enemies=[]
        if p.attack_time and p.attack_time<.23 and not p.hit_done:
            for e in self.enemies:
                if (e.x-p.x)*p.facing>0:
                    result=strike(p,e,e.blocking, .1 if self.rng.random()<e.skill else .4)
                    if result!='miss':
                        self.audio.play(result)
                        p.hit_done=True
                        break
        self.traps.update(dt,self,held)
        for char in ('s','h','H'):
            for x,y in self.room.positions(char):
                if p.rect.colliderect(pygame.Rect(x*16,y*16,16,16)):
                    if char=='s':p.sword=True
                    elif char=='H':p.max_hp+=1;p.hp=p.max_hp
                    else:p.hp=min(p.max_hp,p.hp+1)
                    self.room.grid[y][x]='.';self.audio.play('pickup')
        for x,y in self.room.positions('e'):
            if abs(p.x-(x*16+8))<12 and abs(p.y-(y+1)*16)<6:
                if (self.room.exit_open or self.gates.get((x,y))) and (not self.room.boss_required or all(e.hp<=0 for e in self.enemies)):
                    if p.sword:self.completed=True
        target=None;x=p.x;y=p.y
        if p.y<0 or p.y>=256:
            direction=1 if p.y>=256 else -1
            target=(self.coord[0],self.coord[1]+direction)
            y=p.y-direction*256
            if target not in self.level.rooms:
                if direction>0:
                    p.invulnerable=0;p.hurt(99)
                target=None
        elif p.x<0 or p.x>=480:
            direction=1 if p.x>=480 else -1
            target=(self.coord[0]+direction,self.coord[1])
            x=p.x-direction*480
            if target not in self.level.rooms:
                p.x=max(7,min(473,p.x));target=None
        if target is not None:
            self.save_room()
            self.enter_room(target,x,y,momentum=True)
