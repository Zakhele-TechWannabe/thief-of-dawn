"""Design contracts and regression tests for the room seams, not art assets."""
from itertools import combinations
import pytest
from game.level import Level
from game.world import World

@pytest.fixture(scope='module')
def routes():
    return {n:Level(n).reachable() for n in range(1,6)}

@pytest.mark.parametrize('number,count',list(enumerate([8,9,10,10,10],1)))
def test_room_graph_and_main_route(number,count,routes):
    level=Level(number);route=routes[number]
    assert len(level.rooms)==count
    assert len({c[1] for c in level.rooms})>=2
    assert route['exit'] and route['sword']
    assert route['climbs']>=4,route
    assert route['drops']>=3,route
    assert route['vertical_transitions']>=3,route
    assert all(abs(a['room'][0]-b['room'][0])+abs(a['room'][1]-b['room'][1])<=1
               for a,b in zip(route['route'],route['route'][1:]))
    if number==2:assert any(step['move']=='collapse' for step in route['route'])
    if number==3:assert any(step['move']=='running_jump' for step in route['route'])


def test_all_rooms_unique():
    rooms=[(n,r) for n in range(1,6) for r in Level(n).rooms.values()]
    def cells(r):return {(x,y,t) for y,row in enumerate(r.grid) for x,t in enumerate(row) if t!='.'}
    for (na,a),(nb,b) in combinations(rooms,2):
        ca,cb=cells(a),cells(b)
        assert len(ca&cb)<=.5*min(len(ca),len(cb)),(na,a.data['name'],nb,b.data['name'])

@pytest.mark.parametrize('number',range(1,6))
def test_two_reachable_floor_heights_per_room(number,routes):
    level=Level(number)
    for coord,room in level.rooms.items():
        heights={y%16 for x,y in routes[number]['reachable_nodes'] if (x//30,y//16)==coord}
        assert len(heights)>=2,(number,coord,heights)


def test_secrets_are_side_branches(routes):
    total=0
    for number in range(1,6):
        level=Level(number)
        main={tuple(n['room']) for n in routes[number]['route']}
        for coord,room in level.rooms.items():
            total+=len(room.positions('H'))
            if room.positions('H'):assert coord not in main
    assert 2<=total<=3


def seam_world():
    w=World()
    for room in w.level.rooms.values():
        room.grid=[list('.'*30) for _ in range(16)];room.enemies=[]
    w.enter_room((1,0),168,254)
    w.player.invulnerable=0
    return w


def test_downward_transition_preserves_momentum():
    w=seam_world();p=w.player;p.vy=150;p.vx=20;p.grounded=False;p.fall_start=220
    w.update(1/60)
    assert w.coord==(1,1)
    assert p.vy==pytest.approx(150+620/60)
    assert p.fall_start==-36
    assert p.x>168
    p.hp=0
    for _ in range(65):w.update(1/60)
    assert w.coord==(1,1) and w.player.hp==3

@pytest.mark.parametrize('start,hp',[(224,2),(176,0)])
def test_fall_damage_spans_room_boundary(start,hp):
    w=seam_world();w.level.rooms[(1,1)].grid[2]=list('#'*30)
    p=w.player;p.y=240;p.fall_start=start;p.vy=200;p.grounded=False
    for _ in range(35):
        w.update(1/60)
        if p.grounded or p.hp==0:break
    assert w.coord==(1,1) and p.hp==hp


def test_climb_into_room_above():
    w=seam_world()
    for x in range(10,15):w.level.rooms[(1,0)].grid[15][x]='#'
    for x in range(10):w.level.rooms[(1,1)].grid[4][x]='#'
    w.enter_room((1,1),150,64);p=w.player;p.facing=1
    for i in range(60):w.update(1/60,{'up'},{'up'} if i==0 else ())
    assert p.hang_edge is not None,(p.x,p.y,p.state)
    for i in range(30):w.update(1/60,{'up'},{'up'} if i==0 else ())
    assert w.coord==(1,0) and p.grounded and p.y==240


def test_bottom_without_neighbour_is_death():
    w=seam_world();w.enter_room((1,3),168,254)
    p=w.player;p.vy=150;p.grounded=False;p.invulnerable=0
    w.update(1/60)
    assert p.hp==0

@pytest.mark.parametrize('number',range(1,6))
def test_cross_room_plates_are_required(number):
    level=Level(number)
    for room in level.rooms.values():room.links={}
    assert not level.reachable()['exit']

@pytest.mark.parametrize('number', [4,5])
def test_boss_objective_blocks_exit(number):
    w=World(number,(0,3));x,y=w.room.positions('e')[0]
    w.player.x=x*16+8;w.player.y=(y+1)*16
    w.gates[(x,y)]=True
    w.update(1/60)
    assert not w.completed
    for e in w.enemies:e.hp=0
    w.update(1/60)
    assert w.completed


def test_scripted_timed_run_spans_two_rooms(tmp_path):
    from game.__main__ import InputScript
    w=World(4,(0,2))
    # Clear this landing guard before starting the run, then backtrack to its plate.
    for enemy in w.enemies:enemy.hp=0
    p=w.player;p.x=264;p.y=p.fall_start=p.ground_y=208;p.grounded=True
    path=tmp_path/'run.txt'
    path.write_text('0 right down\n18 right up\n30 up down\n49 up up\n50 up down\n80 up up\n80 right down\n198 right up\n')
    script=InputScript(path);climbed=False
    for frame in range(215):
        w.update(1/60,*script.frame(frame));climbed |= p.state=='climb'
    assert w.coord==(1,2) and climbed and w.deaths==0
    assert all(w.gate_states[(1,2)].values())
    assert all(w.gate_states[(1,3)].values())
    for _ in range(490):w.update(1/60)
    assert not any(w.gate_states[(1,2)].values())
    assert all(w.gate_states[(1,3)].values())


def test_unarmed_room_visit_does_not_erase_future_guard():
    w=World(1,(1,1))
    assert not w.enemies
    w.save_room()
    w.player.sword=True
    w.enter_room((1,1),8,208)
    assert len(w.enemies)==1


def test_defeated_enemy_stays_defeated_after_vertical_move():
    w=World(3,(0,0))
    w.enemies[0].hp=0
    w.room.grid=[list('.'*30) for _ in range(16)]
    p=w.player;p.y=254;p.vy=150;p.grounded=False
    w.update(1/60)
    assert w.coord==(0,1)
    w.enter_room((0,0),40,208)
    assert not w.enemies
