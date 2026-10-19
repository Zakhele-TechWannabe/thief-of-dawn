import math
import pygame
from .hud import draw_hud

class Renderer:
    def __init__(self,assets):
        self.assets=assets
        self.architecture_cache={}
        self.font=pygame.font.Font(None,14)
        self.small=pygame.font.Font(None,12)

    def prop(self,s,name,pos):
        im=self.assets.image(f'props/{name}.png')
        if im:
            s.blit(im,pos)
            return True
        return False

    def architecture(self,w):
        key=(w.level.number,tuple(''.join(row) for row in w.room.grid))
        if key not in self.architecture_cache:
            layer=pygame.Surface((480,256),pygame.SRCALPHA)
            n=w.level.number
            band=(49,35,28) if n==2 else (48,32,45) if n==3 else (39,36,49)
            edge=(92,65,40) if n==2 else (113,66,61) if n==3 else (77,69,83)
            for y,row in enumerate(w.room.grid[:-1]):
                for x,c in enumerate(row):
                    if c not in '#L' or w.room.tile(x,y+1) in '#L':continue
                    px=x*16;py=(y+1)*16
                    pygame.draw.rect(layer,band,(px,py,16,10))
                    pygame.draw.line(layer,edge,(px,py),(px+15,py),2)
                    if x%5==2:
                        bottom=y+1
                        while bottom<16 and w.room.tile(x,bottom) not in '#L':bottom+=1
                        # A short corbel on open shafts; full props only over a floor.
                        height=(bottom-y-1)*16 if bottom<16 else 14
                        pygame.draw.polygon(layer,edge,[(px+2,py),(px+14,py),(px+10,py+10),(px+6,py+10)])
                        if bottom<16 and height>=32:
                            pygame.draw.rect(layer,band,(px+5,py+8,6,height-8))
                            pygame.draw.line(layer,edge,(px+6,py+8),(px+6,py+height))
            self.architecture_cache[key]=layer
        return self.architecture_cache[key]

    def draw(self,s,w):
        a=self.assets;n=w.level.number
        s.blit(a.background(n),(0,0))
        s.blit(self.architecture(w),(0,0))
        for y,row in enumerate(w.room.grid):
            for x,c in enumerate(row):
                px,py=x*16,y*16
                if c in '#L':
                    kind='top' if not w.solid(x,y-1) else 'solid'
                    if c=='L':
                        if not self.prop(s,'loose_floor',(px,py)):
                            s.blit(a.tile(n,kind),(px,py));pygame.draw.lines(s,(26,25,32),False,[(px+5,py),(px+9,py+5),(px+6,py+9)])
                        obj=next((o for o in w.traps.loose if o.x==x and o.y==y),None)
                        if obj and obj.timer>=0:pygame.draw.line(s,(180,137,89),(px+(int(w.traps.clock*30)%3),py+2),(px+12,py+3))
                    else:s.blit(a.tile(n,kind),(px,py))
                elif c=='t':
                    torch=f'torch_{int(w.traps.clock*8)%4:02d}'
                    if not self.prop(s,torch,(px,py-16)):
                        pygame.draw.circle(s,(64,48,37),(px+8,py-5),16)
                        pygame.draw.line(s,(94,65,43),(px+8,py+10),(px+8,py),3)
                        pygame.draw.ellipse(s,(230,139,61),(px+4,py-10,8,13))
                        pygame.draw.ellipse(s,(255,219,123),(px+6,py-8+int(w.traps.clock*8)%2,4,9))
                elif c in 'hHs':
                    if c=='H' and (w.player.y>185 or abs(w.player.x-(px+8))>80):continue
                    name={'h':'potion_small','H':'potion_big','s':'sword'}[c]
                    if not self.prop(s,name,(px if c!='s' else px-8,py)):
                        if c=='s':
                            pygame.draw.line(s,(216,224,220),(px-3,py+13),(px+20,py+3),2);pygame.draw.line(s,(191,146,73),(px,py+6),(px+4,py+15),2)
                        else:
                            pygame.draw.rect(s,(210,190,159),(px+6,py+1,4,4))
                            pygame.draw.ellipse(s,(172,48,60) if c=='h' else (197,152,63),(px+3,py+5,10,10))
                            pygame.draw.line(s,(255,188,142),(px+5,py+7),(px+5,py+10))
                elif c=='^':
                    if not self.prop(s,'spikes',(px,py)):
                        for xx in range(px,px+16,4):pygame.draw.polygon(s,(167,170,177),[(xx,py+16),(xx+2,py+6),(xx+4,py+16)])
                elif c=='p':
                    if not self.prop(s,'plate',(px,py+8)):
                        pygame.draw.rect(s,(157,126,70),(px,py+13,16,3));pygame.draw.line(s,(214,184,109),(px+2,py+12),(px+14,py+12))
                elif c=='g':
                    if not w.gates.get((x,y)):
                        # Contract gate is 48px high: draw once, at its top segment.
                        if w.room.tile(x,y-1)!='g':
                            if not self.prop(s,'gate',(px,py)):
                                for xx in (px+3,px+9,px+14):pygame.draw.line(s,(131,139,145),(xx,py),(xx,py+48),2)
                                pygame.draw.rect(s,(78,86,97),(px,py,16,4))
                elif c=='|':
                    active=w.traps.slicer_active(x)
                    if not self.prop(s,'slicer',(px,py-32)):
                        pygame.draw.rect(s,(76,77,88),(px+4,py-32,8,48))
                        pygame.draw.polygon(s,(230,217,198) if active else (113,113,122),[(px+2,py-28),(px+15 if active else px+7,py-9),(px+2,py+12)])
                elif c=='e':
                    if not self.prop(s,'exit_door',(px-8,py-32)):
                        pygame.draw.rect(s,(134,119,87),(px-9,py-33,34,49),2)
                        opened=(w.room.exit_open or w.gates.get((x,y))) and (not w.room.boss_required or all(e.hp<=0 for e in w.enemies))
                        pygame.draw.rect(s,(17,20,31) if opened else (83,69,68),(px-6,py-30,28,46))
                        pygame.draw.circle(s,(222,190,112) if opened else (153,65,62),(px+8,py-20),3)
        for obj in w.traps.loose:
            if obj.falling and not obj.broken:s.blit(a.tile(n,'top'),(obj.x*16,obj.py))
        for actor,kind in [(e,e.kind) for e in w.enemies]+[(w.player,'kael')]:
            if actor.hp<=0 and kind in ('shade','morrow'):
                age=actor.dead_time
                if age>=.8:continue
                im,anchor=a.actor(kind,'hurt',100,actor.facing,True)
                faded=im.copy();faded.set_alpha(round(255*(1-age/.8)))
                s.blit(faded,(round(actor.x-anchor[0]),round(actor.y-anchor[1])))
                # Stable seeds make the shadow dissolve reproducible in captures.
                particles=pygame.Surface((480,256),pygame.SRCALPHA)
                for i in range(28):
                    phase=i*2.39996
                    x=actor.x+math.sin(phase)*(8+age*24)
                    y=actor.y-((i*17)%48)-age*(10+i%7*3)
                    color=(137,76,204,round(220*(1-age/.8)))
                    pygame.draw.rect(particles,color,(round(x),round(y),2,2))
                s.blit(particles,(0,0))
                continue
            if actor.dead_time>1.5:continue
            # Animate attacks/death from the start of their state.
            age=actor.dead_time if actor.hp<=0 else (.48-actor.attack_time) if actor.state=='attack' else actor.age
            im,anchor=a.actor(kind,actor.state,age,actor.facing,actor.sword)
            s.blit(im,(round(actor.x-anchor[0]),round(actor.y-anchor[1])))
            if actor is not w.player and actor.hp>0:
                for i in range(actor.max_hp):
                    x=int(actor.x-actor.max_hp*2+i*4)
                    pygame.draw.polygon(s,(186,132,191) if i<actor.hp else (55,42,65),[(x,int(actor.y)-57),(x+3,int(actor.y)-57),(x+1,int(actor.y)-54)])
        # Narrow floor lips read in front of the feet.
        for y,row in enumerate(w.room.grid):
            for x,c in enumerate(row):
                if c in '#L' and not w.solid(x,y-1):
                    lip=(205,159,104) if c=='L' else (218,202,171)
                    pygame.draw.line(s,lip,(x*16,y*16),(x*16+15,y*16),2)
        label=self.small.render(w.room.data['name'],False,(154,149,159));s.blit(label,(8,5))
        draw_hud(s,w,self.small)
