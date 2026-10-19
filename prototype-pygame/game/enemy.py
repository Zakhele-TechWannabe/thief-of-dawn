from dataclasses import dataclass
from .player import Player
from .combat import strike
from .config import GRAVITY

@dataclass
class Enemy(Player):
    kind: str = 'shade'
    skill: float = .3
    cooldown: float = .8
    blocking: bool = False
    summoned: bool = False
    teleport_timer: float = 3.5
    combo: int = 0

    @classmethod
    def from_data(cls,data):
        return cls(x=data['feet'][0], y=data['feet'][1], hp=data['hp'],max_hp=data.get('max_hp',data['hp']),sword=True,kind=data['kind'],skill=data['skill'],summoned=data.get('summoned',False))

    def update_ai(self,dt,world):
        self.age+=dt
        self.invulnerable=max(0,self.invulnerable-dt)
        self.stun=max(0,self.stun-dt)
        self.cooldown-=dt
        p=world.player
        if self.hp<=0:
            self.dead_time+=dt;self.state='death';return
        self.facing=1 if p.x>self.x else -1
        if self.kind=='morrow':
            self.teleport_timer-=dt
            if self.teleport_timer<=0 and not self.stun:
                destination=p.x-self.facing*76
                if 25<destination<455 and world.support_at(destination,self.y):
                    self.x=destination
                    self.teleport_timer=4
                    world.audio.play('shadow')
            if not self.summoned and self.hp<=self.max_hp/2:
                self.summoned=True
                spawn_x=max(25,min(455,p.x-95))
                world.pending_enemies.append(Enemy(x=spawn_x,y=self.y,hp=2,max_hp=2,sword=True,skill=.35))
        distance=abs(p.x-self.x)
        self.blocking=False
        if not self.stun and p.hp>0 and abs(p.y-self.y)<20 and p.sword:
            if p.attack_time and distance<48 and not self.attack_time:
                self.blocking=world.rng.random()<self.skill
            if distance>31 and distance<190:
                self.vx=self.facing*38
            else:self.vx=0
            if distance<40 and self.cooldown<=0 and not self.attack_time and not self.blocking:
                self.attack_time=.55 if self.kind!='vesh' else .40
                self.hit_done=False
                self.combo+=1
                self.cooldown=(.60 if self.kind=='vesh' and self.combo%3 else 1.25) + world.rng.random()*.5
        else:self.vx*=.85
        ox=self.x
        self.x+=self.vx*dt
        if world.collides(self.rect):self.x=ox
        self.x=max(7,min(473,self.x))
        oy=self.y
        self.vy+=GRAVITY*dt;self.y+=self.vy*dt
        floor=world.landing(self.rect,oy,self.y)
        if floor is not None:self.y=floor;self.vy=0
        if self.y>=256:
            self.invulnerable=0;self.hurt(99)
        if self.attack_time:
            self.attack_time=max(0,self.attack_time-dt)
            if self.attack_time<.25 and not self.hit_done:
                result=strike(self,p,p.state=='block',p.block_time)
                self.hit_done=True
                if result!='miss':world.audio.play(result)
        self.state='hurt' if self.stun else 'attack' if self.attack_time else 'block' if self.blocking else 'walk' if abs(self.vx)>2 else 'idle'
