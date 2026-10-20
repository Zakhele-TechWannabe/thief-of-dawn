"""Authored two-storey holding cells, drain, yard, and compact lower roofs."""
from pathlib import Path
W,H=154,40
rows=[list('.'*W) for _ in range(H)]
def rect(x,y,w,h,ch='#'):
    for r in range(y,y+h):
        for c in range(x,x+w): rows[r][c]=ch
def put(x,y,ch): rows[y][x]=ch
rect(0,0,1,H); rect(W-1,0,1,H)
rect(0,24,90,16)
# Holding-cell climbing furniture and upper guard walk.
rect(11,21,3,3); rect(15,18,3,6)
rect(11,22,7,2,".")
rect(20,16,38,1); rect(20,17,1,5)
# Drain: 32 px choke beneath a solid separating floor; crouch/slide required.
rect(21,21,34,1)
put(5,23,'@'); put(8,23,'o'); put(13,20,'q')
put(20,15,'v'); put(20,23,'d')
put(28,15,'p'); put(34,15,'g'); put(46,15,'n')
put(27,12,'l'); put(40,12,'l'); put(53,12,'l')
put(31,23,'r'); put(46,23,'r'); put(54,23,'p')
put(57,23,'u'); put(60,23,'o'); put(61,23,'g')
# Drying beams over the yard: an unlit way past the watchman. Reachable with a jump from the yard floor
# or by dropping off the end of the guard walk; they end behind Hadrik.
rect(58,20,8,1,'=')
put(67,23,'B'); put(69,23,'R'); put(59,23,'k')
put(71,19,'l'); put(74,20,'t')
# Lower roofs: steps, jumps, drop recoveries. Ground is safe until the final roof gap.
rect(73,21,3,3); rect(78,18,3,6); rect(83,15,9,1)
rect(96,15,12,1); rect(112,13,9,1); rect(125,15,12,1); rect(141,15,12,1)
# Catch platforms under roof gaps, avoiding a long reset for a missed jump.
rect(90,22,63,2); rect(91,19,4,1,'='); rect(108,18,4,1,'='); rect(121,18,4,1,'='); rect(137,19,4,1,'=')
put(87,14,'k'); put(99,14,'u'); put(102,14,'o'); put(105,11,'l')
put(116,12,'g'); put(119,10,'l'); put(129,14,'u'); put(132,11,'l'); put(149,14,'E')
# The holding house: a tall roof over the cell and the guard walk, so both read as rooms.
# (Ceiling heights keep every jump in the routes clear: apex head height is ~6 tiles above the feet.)
rect(1,5,57,2)
put(9,9,'w')   # barred window high in the cell: cold moonlight, the only light Renn wakes to
header='''name: Slateford — Behind the Door / The Lower Roofs
theme: 2
darkness: #9aabc8
stone: #89858a
interior: 1,7,57,23
patrol_34_15: 34,15;42,15
patrol_61_23: 61,23;57,23
patrol_67_23: 67,23;68,23
patrol_116_12: 116,12;119,12
map:
'''
Path('levels/chapter1.txt').write_text(header+'\n'.join(''.join(r) for r in rows)+'\n')
