"""Menus, verbatim story cards and the play-session state machine."""
import re
import pygame
from .config import ROOT, FATES, THEMES
from .world import World
from .save import save_progress,load_progress

CONTROLS=['Arrows: move   Up: jump / climb','Down: crouch / drop / descend to hang','Shift: careful step / grab (safe on spikes)','Z / Space: attack   X: block','Esc: pause   F11: fullscreen   M: mute']
GAME_OVER='The Lantern goes dark. The past forgets itself.'

def story_cards():
    text=(ROOT/'STORY.md').read_text()
    return {name:' '.join(body.split()) for name,body in re.findall(r'\*\*(Intro|After [1-4]|Ending)\.\*\* \*(.*?)\*(?:\n|$)',text,re.S)}

class Scenes:
    def __init__(self,assets,audio,seed=0,save_enabled=True):
        self.assets=assets;self.audio=audio;self.seed=seed;self.save_enabled=save_enabled
        self.state='title';self.selection=0;self.world=None
        self.cards=story_cards();self.card='Intro';self.card_age=0;self.revealed=False
        self.font=pygame.font.Font(None,19);self.small=pygame.font.Font(None,15);self.title=pygame.font.Font(None,43)
        self.veil=pygame.Surface((480,270),pygame.SRCALPHA);self.veil.fill((7,9,18,220))
        self.running=True;self.show_controls=False

    def start(self,level=1,room=None,max_hp=3,time_left=2700):
        self.world=World(level,room,max_hp,time_left,self.seed,self.audio)
        self.state='play'
        if self.save_enabled:save_progress(level,max_hp,time_left)

    def show_card(self,name):
        self.card=name;self.card_age=0;self.revealed=False;self.state='card'

    def update(self,dt,held,pressed):
        if 'm' in pressed:self.audio.muted=not self.audio.muted
        if self.state=='play':
            if 'escape' in pressed:
                self.state='pause';self.selection=0;return
            self.world.update(dt,held,pressed)
            if self.world.time_left<=0:self.state='gameover'
            elif self.world.completed:
                p=self.world.player;p.max_hp+=1;p.hp=p.max_hp
                self.show_card(f'After {self.world.level.number}' if self.world.level.number<5 else 'Ending')
            return
        if self.state=='card':
            self.card_age+=dt
            if pressed:
                if not self.revealed and self.card_age*35<len(self.cards[self.card]):self.revealed=True
                elif self.card=='Intro':self.start()
                elif self.card=='Ending':self.state='title';self.selection=0
                else:
                    w=self.world;self.start(w.level.number+1,max_hp=w.player.max_hp,time_left=w.time_left)
            return
        if self.state=='gameover':
            if pressed:self.state='title';self.selection=0
            return
        if self.state=='pause' and 'escape' in pressed:
            if self.show_controls:self.show_controls=False
            else:self.state='play'
            return
        if self.show_controls:
            if pressed:self.show_controls=False
            return
        options=3 if self.state=='title' else 4
        if 'up' in pressed:self.selection=(self.selection-1)%options
        if 'down' in pressed:self.selection=(self.selection+1)%options
        if not pressed.intersection({'return','space','z'}):return
        if self.state=='title':
            if self.selection==0:self.show_card('Intro')
            elif self.selection==1:
                saved=load_progress()
                if saved:self.start(**saved)
            else:self.running=False
        else:
            if self.selection==0:self.state='play'
            elif self.selection==1:self.world.restart_room();self.state='play'
            elif self.selection==2:self.show_controls=True
            else:self.state='title';self.selection=0

    def text(self,s,text,y,font=None,color=(218,209,182),center=True,x=30):
        im=(font or self.font).render(text,False,color)
        s.blit(im,((480-im.get_width())//2 if center else x,y))

    def wrapped(self,s,text,y,font=None,width=416):
        font=font or self.font
        line=''
        for word in text.split():
            candidate=f'{line} {word}'.strip()
            if font.size(candidate)[0]>width and line:
                self.text(s,line,y,font,center=False);y+=21;line=word
            else:line=candidate
        self.text(s,line,y,font,center=False)
        return y+21

    def draw(self,s,renderer):
        if self.world and self.state in ('play','pause'):
            renderer.draw(s,self.world)
            if self.state=='play':
                if self.world.player.hp<=0:self.text(s,'The shadow takes you…',110)
                return
            s.blit(self.veil,(0,0))
        else:s.blit(self.assets.background(self.world.level.number if self.world else 1),(0,0))
        if self.state=='title':
            title=self.assets.image('ui/title.png')
            if title:s.blit(title,(0,0));s.blit(self.veil,(0,0))
            self.text(s,'THIEF OF DAWN',27,self.title,(232,205,136))
            self.text(s,'a tale of the Umbraverse',65,self.small)
            for i,item in enumerate(['New Game','Continue' if load_progress() else 'Continue (no save)','Quit']):self.text(s,('> ' if i==self.selection else '  ')+item,95+i*23)
            for i,line in enumerate(CONTROLS):self.text(s,line,184+i*14,self.small,(155,164,173))
        elif self.state=='pause':
            self.text(s,'PAUSED',24,self.title)
            if not self.show_controls:
                for i,item in enumerate(['Resume','Restart room','Controls','Quit to title']):self.text(s,('> ' if i==self.selection else '  ')+item,78+i*24)
            else:
                for i,line in enumerate(CONTROLS):self.text(s,line,88+i*20,self.small)
                self.text(s,'Any key to return',225,self.small)
        elif self.state=='card':
            if self.card!='Intro':
                index=4 if self.card=='Ending' else int(self.card[-1])-1
                fate=FATES[index]
                im=self.assets.image(f'ui/mark_{fate.lower()}.png')
                if im:s.blit(im,(224,13))
                else:
                    pygame.draw.polygon(s,(208,171,89),[(240,10),(254,26),(240,42),(226,26)],2)
                    pygame.draw.circle(s,(232,205,130),(240,26),5,1)
                self.text(s,f'Mark of {fate} — +1 maximum health',49,self.font,(232,205,136))
            else:self.text(s,'The Grand Festival',28,self.title,(232,205,136))
            text=self.cards[self.card]
            visible=text if self.revealed else text[:int(self.card_age*35)]
            self.wrapped(s,visible,83,self.font)
            self.text(s,'Any key: reveal / continue',248,self.small,(151,155,165))
        elif self.state=='gameover':
            self.wrapped(s,GAME_OVER,102)
            self.text(s,'Any key to return',215,self.small)
