import json
import random
import subprocess
from pathlib import Path
import pytest
from game.config import ROOT
from game.level import Level
from game.physics import fall_damage,jump_reach
from game.player import Player
from game.enemy import Enemy
from game.combat import strike
from game.world import World
from game.save import save_progress,load_progress
from game.__main__ import InputScript
from game.scenes import story_cards,Scenes,GAME_OVER
from game.assets import Assets
from game.render import Renderer


def tick(w,frames,held=(),pressed=()):
    for i in range(frames):w.update(1/60,set(held),set(pressed) if i==0 else set())

@pytest.mark.parametrize('number',range(1,6))
def test_levels_load_and_reachable(number):
    level=Level(number)
    assert level.validate()
    route=level.reachable()
    assert route['exit'],route
    assert route['sword']

@pytest.mark.parametrize('speed,lo,hi',[(68,2,3.3),(112,4.5,5.5)])
def test_jump_distance_real_simulation(world,speed,lo,hi):
    p=world.player;p.x=100;p.vx=speed
    p.jump(speed>78)
    for i in range(120):
        world.update(1/60,set(),set())
        if p.grounded:break
    assert lo*16<=p.x-100<=hi*16


def test_jump_up_height(world):
    p=world.player;p.x=100
    start=p.y;minimum=start
    p.jump()
    for _ in range(60):
        world.update(1/60,{'up'},set());minimum=min(minimum,p.y)
    assert 38<=start-minimum<=44

@pytest.mark.parametrize('tiles,expected',[(0,0),(3,0),(3.99,0),(4,1),(6,1),(6.99,1),(7,99),(10,99)])
def test_fall_thresholds(tiles,expected):assert fall_damage(tiles*16)==expected

@pytest.mark.parametrize('tiles,hp',[(3,3),(4,2),(6,2),(7,0)])
def test_real_fall(world,tiles,hp):
    p=world.player;p.x=100;p.y=208-tiles*16;p.fall_start=p.y;p.grounded=False;p.invulnerable=0
    for _ in range(120):
        world.update(1/60,set(),set())
        if p.grounded:break
    assert p.hp==hp


def test_careful_stops_at_edge(world):
    for x in range(8,30):
        for y in range(13,16):world.room.grid[y][x]='.'
    world.player.x=100
    tick(world,180,{'right','shift'})
    assert world.player.x<128 and world.player.grounded


def test_ledge_grab_and_climb_three_tiles(world):
    # A 3-tile rise, approached from just outside its exposed face.
    for x in range(10,15):world.room.grid[10][x]='#'
    p=world.player;p.x=150;p.facing=1
    tick(world,60,{'up'},{'up'})
    assert p.state=='hang',(p.x,p.y,p.state)
    tick(world,30,{'up'},{'up'})
    assert p.grounded and p.y==160


def test_drop_to_hang(world):
    for x in range(10,30):
        for y in range(13,16):world.room.grid[y][x]='.'
    p=world.player;p.x=149;p.vx=112
    # Down is a deliberate ledge descent, even while forward momentum dissipates.
    tick(world,8,{'right','down'})
    assert p.state=='hang'
    tick(world,1,{'down'},{'down'})
    assert p.hang_edge is None


def test_spikes_careful_and_lethal(world):
    world.room.grid[12][13]='^';p=world.player;p.x=216;p.invulnerable=0
    world.traps.update(1/60,world,{'shift'})
    assert p.hp==3
    world.traps.update(1/60,world,set())
    assert p.hp==0


def test_loose_floor_falls_and_breaks():
    w=World(2,(1,0));p=w.player;p.x=28*16+8;p.y=p.ground_y=p.fall_start=240
    tick(w,32)
    assert w.room.tile(28,15)=='.'
    tick(w,50)
    assert w.coord==(1,1)


def test_pressure_gate_timer():
    w=World(4,(0,2));x,y=w.room.positions('p')[0]
    w.player.x=x*16+8;w.player.y=(y+1)*16
    tick(w,1)
    assert all(w.gate_states[(1,2)].values())
    w.enter_room((1,2),40,208)
    tick(w,490)
    assert not any(w.gate_states[(1,2)].values())


def test_combat_parry_block_damage_death():
    p=Player(x=100,sword=True);e=Enemy(x=128,hp=2,max_hp=2,facing=-1)
    assert strike(p,e,True,.1)=='parry' and p.stun>.5 and e.hp==2
    assert strike(p,e,True,.4)=='block' and e.hp==2
    assert strike(p,e)=='hit' and e.hp==1
    e.invulnerable=0
    assert strike(p,e)=='hit' and e.hp==0


def test_checkpoint_restores_room_and_timer():
    w=World(3,(0,0));initial=w.time_left
    w.player.hp=0;w.enemies[0].hp=0
    tick(w,70)
    assert w.deaths==1 and w.player.hp==3 and w.enemies[0].hp>0
    assert w.time_left<initial-1


def test_sword_pickup_and_level_one_guard_order(world):
    assert not world.enemies and not world.player.sword
    r=world.level.rooms[(2,0)];x,y=r.positions('s')[0]
    world.enter_room((2,0),x*16+8,(y+1)*16)
    tick(world,1)
    assert world.player.sword
    world.enter_room((1,1),8,208)
    assert world.enemies


def test_morrow_summons_once_and_teleports():
    w=World(5,(0,3));m=w.enemies[0];m.hp=3;w.player.x=230;m.teleport_timer=0
    tick(w,1)
    assert m.summoned and len(w.enemies)==2 and m.teleport_timer>0
    tick(w,20)
    assert len(w.enemies)==2


def test_save_load(tmp_path):
    path=tmp_path/'save.json'
    assert save_progress(3,5,1800,path)
    assert load_progress(path)=={'level':3,'max_hp':5,'time_left':1800}
    path.write_text('{broken')
    assert load_progress(path) is None
    path.write_text(json.dumps({'version':1,'level':9,'max_hp':3,'time_left':5}))
    assert load_progress(path) is None


def test_scripted_first_room_exit(tmp_path):
    world=World()
    path=tmp_path/'script.txt';path.write_text(FIRST_ROOM_SCRIPT)
    script=InputScript(path);climbs=0;last=''
    for frame in range(443):
        world.update(1/60,*script.frame(frame))
        if world.player.state=='climb' and last!='climb':climbs+=1
        last=world.player.state
    assert world.coord==(1,0) and climbs==2 and world.deaths==0


def test_cli_script_screenshot(tmp_path):
    script=tmp_path/'input.txt';script.write_text(FIRST_ROOM_SCRIPT)
    image=tmp_path/'shot.png'
    result=subprocess.run([str(ROOT/'.venv/bin/python'),'-m','game','--headless-frames','443','--inputs',str(script),'--screenshot',str(image)],capture_output=True,text=True,cwd=ROOT)
    assert result.returncode==0,result.stderr
    assert 'room=(1, 0)' in result.stdout and image.exists()


def test_verbatim_story_and_fate_flow():
    cards=story_cards()
    assert len(cards)==6 and 'Sarai of Sarath' in cards['Intro']
    scene=Scenes(Assets(),World().audio,save_enabled=False)
    scene.start();scene.world.completed=True
    scene.update(1/60,set(),set())
    assert scene.state=='card' and scene.world.player.max_hp==4
    scene.revealed=True;scene.update(1/60,set(),{'return'})
    assert scene.world.level.number==2 and scene.world.player.max_hp==4
    scene.world.time_left=.001;scene.update(1/60,set(),set())
    assert scene.state=='gameover' and GAME_OVER=='The Lantern goes dark. The past forgets itself.'

@pytest.mark.parametrize('number',range(1,6))
def test_3000_random_frames(number):
    w=World(number,seed=number);rng=random.Random(number)
    held=set()
    for frame in range(3000):
        pressed=set()
        if frame%18==0:
            held={key for key in ['left','right','up','down','shift','z','x'] if rng.random()<.25}
            pressed=held.copy()
        w.update(1/60,held,pressed)
        assert w.player.hp>=0 and w.time_left>=0


def test_missing_and_partial_assets(tmp_path):
    import pygame
    a=Assets(tmp_path)
    for actor in ['kael','shade','vesh','morrow']:
        for pose in ['idle','run','hang','attack','block','death']:
            image,anchor=a.actor(actor,pose,.1,-1)
            assert image.get_size()==(64,64) and anchor==(32,60)
    (tmp_path/'props').mkdir();(tmp_path/'props/sword.png').write_bytes(b'incomplete')
    assert a.image('props/sword.png') is None
    for n in range(1,6):
        w=World(n);Renderer(a).draw(pygame.Surface((480,270)),w)


def test_unopenable_gate_blocks_route():
    level=Level(1)
    level.rooms[(0,0)].links={}
    assert not level.reachable()['exit']


def test_missing_sword_blocks_level_one_exit():
    level=Level(1);room=level.rooms[(2,0)]
    for x,y in room.positions('s'):room.grid[y][x]='.'
    route=level.reachable()
    assert not route['exit'] and not route['sword']


def test_crouch_bypasses_secret_shelf(world):
    for x in range(10,15):world.room.grid[10][x]='#'
    world.player.x=140
    tick(world,250,{'right','down'})
    assert world.player.x>245 and world.player.max_hp==3


def test_landing_on_spikes_is_lethal_even_holding_shift(world):
    world.room.grid[12][13]='^';p=world.player;p.x=216;p.y=175;p.grounded=False;p.fall_start=175;p.invulnerable=0
    tick(world,20,{'shift'})
    assert p.hp==0


def test_six_tile_grab_is_out_of_reach(world):
    for x in range(10,15):world.room.grid[7][x]='#'
    world.player.x=150
    tick(world,60,{'up'},{'up'})
    assert world.player.hang_edge is None


def test_fast_spike_landing_cannot_be_made_safe_by_shift(world):
    world.room.grid[12][13]='^';p=world.player;p.x=216;p.y=198;p.vy=600;p.grounded=False;p.invulnerable=0
    tick(world,1,{'shift'})
    assert p.hp==0


def test_room_entry_checkpoint_coordinates_and_inventory(world):
    world.player.sword=True
    world.enter_room((1,1),8,208)
    tick(world,20,{'right'})
    world.player.hurt(99)
    tick(world,70)
    assert world.coord==(1,1) and world.player.x==8 and world.player.sword

FIRST_ROOM_SCRIPT = """0 right down
50 right up
60 up down
100 up up
101 up down
132 up up
132 right down
160 right up
170 up down
210 up up
211 up down
242 up up
242 right down
"""
