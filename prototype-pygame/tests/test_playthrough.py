"""Real input-path regressions: no warps, damage injection or physics mocks."""
from pathlib import Path
import pytest
from game.__main__ import InputScript
from game.world import World


def combat_policy(w,previous):
    p=w.player
    living=[e for e in w.enemies if e.hp>0 and abs(e.y-p.y)<20]
    if not living:return set()
    enemy=min(living,key=lambda e:abs(e.x-p.x))
    if enemy.attack_time and not enemy.hit_done and enemy.attack_time<.42:
        return {'x'}
    if enemy.stun>.12 and not p.attack_time:return {'z'}
    if abs(enemy.x-p.x)>33:return {'left' if enemy.x<p.x else 'right'}
    return set()


def write_inputs(path,sequence):
    held=set();lines=[]
    for frame,keys in enumerate(sequence):
        lines.extend(f'{frame} {k} up' for k in sorted(held-keys))
        lines.extend(f'{frame} {k} down' for k in sorted(keys-held))
        held=set(keys)
    path.write_text('\n'.join(lines)+'\n')


def arena(number):
    coord=(1,1) if number==1 else (0,3)
    w=World(number,coord,seed=0)
    w.player.sword=True
    w.enter_room(coord,w.player.x,w.player.y)
    # Arrange the initial duel on the arena's actual floor, using its real enemy.
    enemy=w.enemies[0];p=w.player
    p.x=enemy.x+32;p.y=p.fall_start=p.ground_y=enemy.y
    p.grounded=True;p.facing=-1
    return w


@pytest.mark.parametrize('number',[1,4])
def test_scripted_parry_policy_beats_guard_and_vesh(number,tmp_path):
    w=arena(number);sequence=[];held=set();parries=0
    for frame in range(3600):
        keys=combat_policy(w,held);sequence.append(keys)
        before=w.enemies[0].stun
        w.update(1/60,keys,keys-held);held=keys
        parries+=w.enemies[0].stun>before
        if w.enemies[0].hp<=0:break
    assert frame<3599 and w.enemies[0].hp==0
    assert parries>=2 and w.deaths==0
    path=tmp_path/'duel.inputs';write_inputs(path,sequence)
    replay=arena(number);script=InputScript(path)
    for frame in range(len(sequence)):replay.update(1/60,*script.frame(frame))
    assert replay.enemies[0].hp==0 and replay.player.hp>0 and replay.deaths==0


def test_level_one_full_input_playthrough():
    path=Path(__file__).parent/'inputs/level1.txt'
    script=InputScript(path);w=World(seed=0)
    saw_sword=False;visited={w.coord}
    for frame in range(max(script.events)+120):
        w.update(1/60,*script.frame(frame))
        saw_sword |= w.player.sword;visited.add(w.coord)
        if w.completed:break
    assert saw_sword and w.completed
    assert w.level.number==1 and w.coord==(1,3)
    assert w.deaths==0
    assert len(visited)>=6
    assert w.enemies and all(e.hp==0 for e in w.enemies)
    assert any(key=='x' for events in script.events.values() for key,action in events)
