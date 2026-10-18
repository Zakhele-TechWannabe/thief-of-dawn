"""Best-effort asset contract reader and cached articulated fallback artwork."""
import json
import math
import pygame
from .config import ASSET_ROOT, THEMES

class Assets:
    def __init__(self,root=ASSET_ROOT):
        self.root=root
        self.images={};self.frames={};self.meta={};self.actor_cache={};self.tiles={};self.backgrounds={}

    def image(self,path):
        if path not in self.images:
            try:self.images[path]=pygame.image.load(str(self.root/path)).convert_alpha()
            except (pygame.error,OSError):self.images[path]=None
        return self.images[path]

    def actor(self,kind,state,age,facing=1,sword=True):
        if kind not in self.meta:
            try:self.meta[kind]=json.loads((self.root/f'sprites/{kind}/meta.json').read_text())
            except (OSError,ValueError):self.meta[kind]={}
        meta=self.meta[kind]
        key=(kind,state)
        if key not in self.frames:
            paths=sorted((self.root/f'sprites/{kind}/{state}').glob('*.png'))
            self.frames[key]=[im for path in paths if (im:=self.image(path.relative_to(self.root))) is not None]
        frames=self.frames[key]
        fallback={'idle_sword':'idle','crouch':'idle','walk':'run' if kind=='kael' else 'idle','jump':'idle' if kind!='kael' else 'jump','fall':'idle' if kind!='kael' else 'fall'}
        if not frames and state in fallback and fallback[state]!=state:
            fallback_key=(kind,fallback[state])
            if fallback_key not in self.frames:
                paths=sorted((self.root/f'sprites/{kind}/{fallback[state]}').glob('*.png'))
                self.frames[fallback_key]=[im for path in paths if (im:=self.image(path.relative_to(self.root))) is not None]
            if self.frames[fallback_key]:
                return self.actor(kind,fallback[state],age,facing,sword)
        anim=meta.get('anims',{}).get(state,{})
        fps=anim.get('fps',10)
        index=int(age*fps)
        if frames:
            index=index%len(frames) if anim.get('loop',state not in ('death','attack','hurt','climb')) else min(index,len(frames)-1)
            cachekey=(kind,state,index,facing)
            if cachekey not in self.actor_cache:self.actor_cache[cachekey]=pygame.transform.flip(frames[index],True,False) if facing<0 else frames[index]
            anchor=meta.get('anchor',[32,60])
            return self.actor_cache[cachekey], (frames[index].get_width()-anchor[0] if facing<0 else anchor[0],anchor[1])
        frame=int(age*10)%8
        if state=='death':frame=min(7,int(age*10))
        cachekey=(kind,state,frame,facing,sword)
        if cachekey not in self.actor_cache:
            im=self.figure(kind,state,frame,sword)
            if facing<0:im=pygame.transform.flip(im,True,False)
            self.actor_cache[cachekey]=im
        return self.actor_cache[cachekey],(32,60)

    def figure(self,kind,state,frame,sword):
        s=pygame.Surface((64,64),pygame.SRCALPHA)
        skin=(106,165,91) if kind in ('kael','vesh') else (180,163,210) if kind=='shade' else (221,218,218)
        cloth={'kael':(35,79,57),'shade':(62,41,90),'vesh':(107,121,128),'morrow':(54,34,76)}[kind]
        dark=tuple(max(0,c-22) for c in cloth)
        pose=math.sin(frame/8*math.tau)
        if state=='death' and frame<4:
            head=(33+frame*4,18+frame*9)
            pygame.draw.line(s,dark,(25,58),(30,43),6)
            pygame.draw.line(s,cloth,(37,59),(30,43),6)
            pygame.draw.line(s,cloth,(30,43),(head[0]-1,head[1]+9),11)
            pygame.draw.circle(s,skin,head,6)
            pygame.draw.line(s,skin,(head[0]-2,head[1]+12),(head[0]+8,head[1]+20),4)
            return s
        if state=='death':
            pygame.draw.ellipse(s,dark,(9,52,43,9));pygame.draw.circle(s,skin,(48,53),5)
            pygame.draw.line(s,cloth,(14,55),(36,54),7)
            return s
        bob=1 if state in ('run','walk') and frame%4<2 else 0
        head=(33,18+bob);hip=(31,42+bob)
        if state=='crouch':head=(35,31);hip=(28,47)
        if state=='hang':head=(32,22);hip=(30,43)
        if state=='climb':head=(35,14);hip=(29,37)
        if kind=='vesh':pygame.draw.polygon(s,(116,33,40),[(23,25),(30,26),(28,57),(14,54)])
        if kind=='morrow':pygame.draw.polygon(s,dark,[(25,26),(39,26),(45,60),(18,59)])
        stride=pose*8 if state in ('run','walk') else 3
        if state in ('jump','fall'):stride=9
        if state=='hang':stride=2
        pygame.draw.line(s,dark,hip,(int(27-stride),59),6)
        pygame.draw.line(s,cloth,hip,(int(35+stride),59),6)
        pygame.draw.line(s,(30,27,31),(int(27-stride),59),(int(31-stride),59),3)
        pygame.draw.line(s,(30,27,31),(int(35+stride),59),(int(39+stride),59),3)
        pygame.draw.line(s,dark,(28,28),hip,12)
        pygame.draw.line(s,cloth,(33,28),(34,41),8)
        pygame.draw.line(s,(145,111,58),(25,40),(38,40),3)
        pygame.draw.circle(s,skin,head,6)
        pygame.draw.arc(s,(20,25,28),(head[0]-6,head[1]-7,12,11),0,math.pi,4)
        pygame.draw.rect(s,(167,242,189) if kind=='kael' else (235,225,255),(head[0]+3,head[1],2,1))
        shoulder=(35,29+bob)
        hand=(42,39)
        if state in ('run','walk'):hand=(int(39-pose*6),int(37+pose*3))
        if state=='attack':hand=(50,30 if frame%8<4 else 36)
        if state=='block':hand=(43,24)
        if state=='hurt':hand=(27,34)
        if state=='hang':hand=(42,8)
        if state=='climb':hand=(43,7)
        pygame.draw.line(s,dark,(27,29),(20,38),5)
        pygame.draw.line(s,cloth,shoulder,hand,5)
        pygame.draw.circle(s,skin,hand,2)
        if sword and state not in ('hang','climb','jump','fall','run','crouch'):
            end=(61,26) if state=='attack' else (48,7) if state=='block' else (55,47)
            pygame.draw.line(s,(216,225,228),hand,end,2)
            pygame.draw.line(s,(186,146,75),(hand[0]-3,hand[1]+2),(hand[0]+3,hand[1]-2),2)
        if kind=='morrow':
            pygame.draw.rect(s,(196,155,75),(18,35,6,10),1);pygame.draw.circle(s,(250,214,112),(21,40),2)
        return s

    def tile(self,n,kind):
        key=n,kind
        if key not in self.tiles:
            im=self.image(f'tiles/level{n}/{kind}.png')
            if im is None:
                im=pygame.Surface((16,16),pygame.SRCALPHA)
                base=THEMES[n-1]
                color=tuple(min(255,c+35) for c in base)
                if kind=='bg':color=tuple(c+7 for c in base)
                im.fill(color)
                pygame.draw.line(im,tuple(max(0,c-12) for c in color),(0,15),(15,15))
                pygame.draw.line(im,tuple(max(0,c-9) for c in color),(15,0),(15,15))
                if kind=='top':
                    pygame.draw.line(im,tuple(min(255,c+40) for c in color),(0,0),(15,0),2)
                    pygame.draw.line(im,(26,25,34),(3,8),(10,11))
            self.tiles[key]=im
        return self.tiles[key]

    def background(self,n):
        if n not in self.backgrounds:
            s=pygame.Surface((480,256));base=THEMES[n-1]
            im=self.image(f'backgrounds/level{n}.png')
            if im:s.blit(im,(0,0))
            else:
                for y in range(256):pygame.draw.line(s,tuple(max(0,int(c*(.6+y/420))) for c in base),(0,y),(480,y))
                if n==3:
                    pygame.draw.circle(s,(181,190,193),(390,38),17)
                    for x in range(10,480,31):pygame.draw.circle(s,(115,130,167),(x,(x*37)%90),1)
                    for x in range(0,480,60):
                        pygame.draw.line(s,(59,46,65),(x,60),(x+60,74))
                        pygame.draw.rect(s,(189,105,65),(x+24,65,7,9))
                elif n==5:
                    for x in range(0,480,42):pygame.draw.arc(s,(67,43,91),(x-30,15,130,180),0,3.4,2)
                else:
                    for x in range(24,480,80):
                        pygame.draw.rect(s,tuple(c+10 for c in base),(x,30,12,178))
                        pygame.draw.rect(s,tuple(c+17 for c in base),(x-3,30,18,5))
                        if n==2:
                            pygame.draw.line(s,(82,60,43),(x,25),(x,208),7)
                            pygame.draw.line(s,(73,52,39),(x,25),(x+70,25),7)
                        if n==4:pygame.draw.polygon(s,(96,34,43),[(x+24,25),(x+45,25),(x+45,92),(x+35,104),(x+24,92)])
            bg=self.image(f'tiles/level{n}/bg.png')
            if bg and im is None:
                overlay=pygame.Surface((480,256),pygame.SRCALPHA)
                for y in range(0,256,16):
                    for x in range(0,480,16):overlay.blit(bg,(x,y))
                overlay.set_alpha(65);s.blit(overlay,(0,0))
            self.backgrounds[n]=s
        return self.backgrounds[n]
