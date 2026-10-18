import argparse
import os
from pathlib import Path

def arguments():
    p=argparse.ArgumentParser(description='Thief of Dawn — a tale of the Umbraverse')
    p.add_argument('--room-sheet',nargs=2,metavar=('LEVEL','OUT'))
    p.add_argument('--level',type=int,choices=range(1,6))
    p.add_argument('--room',type=lambda s:tuple(map(int,s.split(','))))
    p.add_argument('--scale',type=int,default=3)
    p.add_argument('--headless-frames',type=int,default=0)
    p.add_argument('--screenshot',type=Path)
    p.add_argument('--inputs',type=Path)
    p.add_argument('--seed',type=int,default=0)
    return p.parse_args()

class InputScript:
    def __init__(self,path=None):
        self.events={};self.held=set()
        if path:
            for number,line in enumerate(Path(path).read_text().splitlines(),1):
                line=line.split('#',1)[0].strip()
                if not line:continue
                parts=line.lower().split()
                if len(parts)!=3 or parts[2] not in ('down','up'):raise ValueError(f'Invalid input script line {number}')
                frame,key,action=parts
                self.events.setdefault(int(frame),[]).append((key,action))

    def frame(self,index):
        pressed=set()
        for key,action in self.events.get(index,[]):
            if action=='down':
                if key not in self.held:pressed.add(key)
                self.held.add(key)
            else:self.held.discard(key)
        return set(self.held),pressed

def main():
    args=arguments()
    if args.scale<1 or args.headless_frames<0:raise SystemExit('Scale must be positive; frame count must be nonnegative.')
    if args.headless_frames or args.room_sheet:
        os.environ['SDL_VIDEODRIVER']='dummy';os.environ['SDL_AUDIODRIVER']='dummy'
    import pygame
    from .assets import Assets
    from .audio import Audio
    from .scenes import Scenes
    from .render import Renderer
    pygame.mixer.pre_init(22050,-16,1,256)
    pygame.init()
    if args.room_sheet:
        from .world import World
        from .level import Level
        number=int(args.room_sheet[0].removeprefix('level'))
        level=Level(number)
        pygame.display.set_mode((480,270))
        renderer=Renderer(Assets())
        xs=[c[0] for c in level.rooms];ys=[c[1] for c in level.rooms]
        sheet=pygame.Surface(((max(xs)-min(xs)+1)*480,(max(ys)-min(ys)+1)*290))
        sheet.fill((9,10,19));font=pygame.font.Font(None,18)
        for coord,room in level.rooms.items():
            world=World(number,coord);world.player.sword=True
            floors=[(x,y) for y,row in enumerate(room.grid) for x,t in enumerate(row) if t in '#L' and all(room.tile(x,yy)=='.' for yy in range(y-3,y))]
            px,py=min(floors,key=lambda f:abs(f[0]-2)+abs(f[1]-13))
            world.enter_room(coord,px*16+8,py*16)
            canvas=pygame.Surface((480,270));renderer.draw(canvas,world)
            x=(coord[0]-min(xs))*480;y=(coord[1]-min(ys))*290
            sheet.blit(canvas,(x,y+20))
            sheet.blit(font.render(f'{coord}: {room.data["name"]}',True,(230,225,204)),(x+8,y+2))
        path=Path(args.room_sheet[1]);path.parent.mkdir(parents=True,exist_ok=True)
        pygame.image.save(sheet,str(path));pygame.quit();return
    size=(480*args.scale,270*args.scale)
    window=pygame.display.set_mode((480,270) if args.headless_frames else size)
    pygame.display.set_caption('Thief of Dawn — a tale of the Umbraverse')
    canvas=pygame.Surface((480,270));scaled=pygame.Surface(size) if not args.headless_frames else None
    assets=Assets();audio=Audio();scenes=Scenes(assets,audio,args.seed,save_enabled=not bool(args.headless_frames))
    renderer=Renderer(assets)
    if args.level or args.room or args.headless_frames:scenes.start(args.level or 1,args.room)
    script=InputScript(args.inputs)
    clock=pygame.time.Clock();frame=0;physical=set();fullscreen=False
    keynames={pygame.K_LSHIFT:'shift',pygame.K_RSHIFT:'shift',pygame.K_SPACE:'space',pygame.K_ESCAPE:'escape',pygame.K_RETURN:'return'}
    while scenes.running and (not args.headless_frames or frame<args.headless_frames):
        pressed=set()
        for event in pygame.event.get():
            if event.type==pygame.QUIT:scenes.running=False
            elif event.type in (pygame.KEYDOWN,pygame.KEYUP):
                key=keynames.get(event.key,pygame.key.name(event.key))
                if event.type==pygame.KEYDOWN:
                    if key not in physical:pressed.add(key)
                    physical.add(key)
                    if event.key==pygame.K_F11 and not args.headless_frames:
                        fullscreen=not fullscreen
                        window=pygame.display.set_mode(size,pygame.FULLSCREEN if fullscreen else 0)
                else:physical.discard(key)
            elif event.type==pygame.WINDOWFOCUSLOST:physical.clear()
        held_script,pressed_script=script.frame(frame)
        scenes.update(1/60,physical|held_script,pressed|pressed_script)
        # Headless validation runs all simulation frames but renders just its final frame.
        if not args.headless_frames or frame==args.headless_frames-1:
            scenes.draw(canvas,renderer)
            if not args.headless_frames:
                pygame.transform.scale(canvas,size,scaled);window.blit(scaled,(0,0));pygame.display.flip()
        frame+=1
        if not args.headless_frames:clock.tick(60)
    if args.screenshot:
        args.screenshot.parent.mkdir(parents=True,exist_ok=True)
        pygame.image.save(canvas,str(args.screenshot))
    if args.headless_frames:
        w=scenes.world
        print(f'frames={frame} level={w.level.number} room={w.coord} feet=({w.player.x:.1f},{w.player.y:.1f}) hp={w.player.hp} deaths={w.deaths} time={w.time_left:.2f}')
    pygame.quit()

if __name__=='__main__':main()
