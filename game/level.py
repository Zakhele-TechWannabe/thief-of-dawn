import json
from collections import deque
from pathlib import Path
from .config import DATA_ROOT, TILE
from .physics import jump_reach

LEGEND = {'#': 'stone', '.': 'air', 'b': 'background', 'L': 'loose floor', '^': 'spikes', 'p': 'plate', 'g': 'gate', 's': 'sword', 'h': 'red potion', 'H': 'large potion', 'e': 'exit', 't': 'torch', '|': 'slicer'}

class Room:
    def __init__(self, data):
        self.data = data
        self.coord = tuple(data['coord'])
        self.grid = [list(row) for row in data['grid']]
        self.enemies = data.get('enemies', [])
        self.links = data.get('plates', {})
        self.exit_open = data.get('exit_open', True)
        self.boss_required = data.get('boss_required', False)

    def tile(self, x, y):
        if 0 <= x < 30 and 0 <= y < 16:
            return self.grid[y][x]
        return '.'

    def solid(self, x, y, gates=None):
        tile = self.tile(x, y)
        return tile in '#L' or (tile == 'g' and not (gates or {}).get((x, y), False))

    def positions(self, char):
        return [(x, y) for y, row in enumerate(self.grid) for x, value in enumerate(row) if value == char]

class Level:
    def __init__(self, number):
        self.number = number
        self.data = json.loads((DATA_ROOT / f'level{number}' / 'level.json').read_text())
        self.name = self.data['name']
        self.rooms = {tuple(r['coord']): Room(r) for r in self.data['rooms']}
        self.start_room = tuple(self.data['start']['room'])
        self.start = tuple(self.data['start']['feet'])
        self.validate()

    def validate(self):
        assert 6 <= len(self.rooms) <= 12
        assert self.start_room in self.rooms
        for room in self.rooms.values():
            assert len(room.grid) == 16 and all(len(row) == 30 for row in room.grid)
            assert all(c in LEGEND for row in room.grid for c in row)
            for key, targets in room.links.items():
                x, y = map(int, key.split(','))
                assert room.tile(x, y) == 'p'
                for target in targets:
                    at=target['at']
                    destination=self.rooms[tuple(at[:2])] if len(at)==4 else room
                    assert destination.tile(*at[-2:]) in ('g', 'e')
        assert sum(len(r.positions('e')) for r in self.rooms.values()) == 1
        return True

    def reachable(self):
        """Search a world-space support graph and return a concrete objective route.

        Each edge checks the 12x46 body against solid geometry. Ballistic arcs
        use the game's gravity and jump impulse; grabs add the 43px hand reach
        to the jump apex. Drops retain world-space height across room seams.
        Plate state and sword ownership travel with the route, rather than
        unlocking doors retroactively. Combat nodes mean 'defeat this opponent';
        combat execution and timed-run feasibility are separate simulation tests.
        """
        from .config import GRAVITY, JUMP_SPEED, RUN_SPEED, WALK_SPEED
        from functools import lru_cache
        gates=[(c,x,y) for c,r in self.rooms.items() for x,y in r.positions('g')+r.positions('e')]
        bits={key:1<<i for i,key in enumerate(gates)}
        def locate(x,y):return (x//30,y//16),x%30,y%16
        def tile(x,y):
            c,lx,ly=locate(x,y)
            return self.rooms[c].tile(lx,ly) if c in self.rooms else '.'
        def solid(x,y,mask):
            c,lx,ly=locate(x,y)
            return tile(x,y) in '#L' or tile(x,y)=='g' and not mask&bits[(c,lx,ly)]
        def clear(px,feet,mask,removed=None):
            return all(((x,y)==removed or not solid(x,y,mask)) for x in range(int((px-5.9)//16),int((px+5.9)//16)+1)
                       for y in range(int((feet-45.9)//16),int((feet-.1)//16)+1))
        supports={(c[0]*30+x,c[1]*16+y) for c,r in self.rooms.items()
                  for y,row in enumerate(r.grid) for x,t in enumerate(row) if t in '#L'}
        @lru_cache(None)
        def edges(x,y,mask):
            result=[]
            for nx in range(x-6,x+7):
                for ny in range(y-5,y+7):
                    if (nx,ny)==(x,y) or (nx,ny) not in supports or not clear(nx*16+8,ny*16,mask):continue
                    kind=None
                    if nx==x and tile(x,y)=='L' and 1<=ny-y<=6 and all(clear(nx*16+8,f,mask,(x,y)) for f in range(y*16,ny*16+1,4)):
                        kind='collapse'
                    if kind is None and abs(nx-x)==1 and 0<=ny-y<=6 and clear(nx*16+8,y*16,mask) and all(clear(nx*16+8,f,mask) for f in range(y*16,ny*16+1,4)):
                        kind='walk' if ny==y else 'drop'
                    elif kind is None and abs(nx-x)==1 and 1<=y-ny<=5 and all(clear(x*16+8,f,mask) for f in range(ny*16,y*16+1,4)):
                        # Jump beside an exposed face, catch, then pull up.
                        if (y-ny)*16 <= JUMP_SPEED**2/(2*GRAVITY)+43+10:kind='climb'
                    if kind is None:
                        rise=(y-ny)*16;disc=JUMP_SPEED**2-2*GRAVITY*rise
                        if disc>=0:
                            duration=(JUMP_SPEED+disc**.5)/GRAVITY;distance=(nx-x)*16
                            if (ny-y)*16+JUMP_SPEED**2/(2*GRAVITY)<7*16:
                                direction=1 if nx>x else -1
                                for speed,label in ((WALK_SPEED,'standing_jump'),(RUN_SPEED,'running_jump')):
                                    if speed==RUN_SPEED and (x-direction,y) not in supports:continue
                                    travel=direction*speed*duration
                                    # The feet may overlap a shelf edge by up to
                                    # the half-body width; recenter after landing.
                                    if abs(travel-distance)>10:continue
                                    if all(clear(x*16+8+travel*i/48,y*16-JUMP_SPEED*duration*i/48+GRAVITY*(duration*i/48)**2/2,mask) for i in range(1,49)):
                                        kind=label;break
                    if kind and tile(nx,ny-1)=='^':
                        if kind=='walk':kind='careful'
                        else:kind=None
                    if kind:result.append((nx,ny,kind))
            return result
        start=(self.start_room[0]*30+int(self.start[0]//16),self.start_room[1]*16+int(self.start[1]//16),self.number!=1,0)
        queue=deque([start]);parents={start:None};moves={};found=None;sword_found=self.number!=1
        while queue:
            node=queue.popleft();x,y,sword,mask=node
            c,lx,ly=locate(x,y);room=self.rooms.get(c)
            if room is None:continue
            newmask=mask
            bossbit=1<<len(gates)
            if sword and any(e['kind'] in ('vesh','morrow') and abs(e['feet'][0]/16-lx-.5)<=1.5 and abs(e['feet'][1]/16-ly)<.1 for e in room.enemies):
                newmask |= bossbit
            for oy in range(y-3,y):
                cc,xx,yy=locate(x,oy);r=self.rooms.get(cc)
                if r is None:continue
                if r.tile(xx,yy)=='s':sword=True
                if r.tile(xx,yy)=='p':
                    for target in r.links.get(f'{xx},{yy}',[]):
                        at=target['at'];tc=tuple(at[:2]) if len(at)==4 else cc
                        newmask |= bits[(tc,*at[-2:])]
                if r.tile(xx,yy)=='e' and sword and (not r.boss_required or newmask&bossbit) and (r.exit_open or newmask&bits[(cc,xx,yy)]):found=node
            sword_found |= sword
            if found:break
            for nx,ny,kind in edges(x,y,newmask):
                nxt=(nx,ny,sword,newmask)
                if nxt not in parents:
                    parents[nxt]=node;moves[nxt]=kind;queue.append(nxt)
        route=[]
        if found:
            while parents[found] is not None:
                prev=parents[found];c,x,y=locate(found[0],found[1])
                route.append({'room':list(c),'at':[x,y],'move':moves[found],
                              'vertical':prev[1]//16!=found[1]//16})
                found=prev
            route.reverse()
        return {'exit':bool(route),'sword':sword_found,'positions':len(parents),
                'gates':len(gates),'route':route,
                'reachable_nodes':sorted({(x,y) for x,y,_,_ in parents}),
                'climbs':sum(n['move']=='climb' for n in route),
                'drops':sum(n['move'] in ('drop','collapse') for n in route),
                'vertical_transitions':sum(n['vertical'] for n in route)}
