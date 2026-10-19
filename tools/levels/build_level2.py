"""The Deep Mines of Norra: three mandatory wall-jump shafts and a crumbling haul bridge."""
from pathlib import Path

W, H = 180, 40
g = [["#"] * W for _ in range(H)]


def fill(c0, c1, r0, r1, ch="."):
    for r in range(r0, r1 + 1):
        for c in range(c0, c1 + 1):
            g[r][c] = ch


def put(c, r, ch):
    g[r][c] = ch


# Switchback mine route. Each shaft rises 12 tiles: beyond an ordinary jump/ledge grab.
# Four-tile width lets Kael cross wall to wall without exhausting jump height.
fill(2, 27, 29, 36)                  # lamp room / first teaching tunnel
fill(24, 27, 17, 36)                 # shaft I (exit right at y=25)
fill(28, 66, 17, 24)                 # ore gallery
fill(63, 66, 5, 24)                  # shaft II (exit right at y=13)
fill(67, 104, 5, 12)                 # high haul bridge
# A catch gallery under the bridge: collapse is survivable, and leads onward.
fill(76, 104, 13, 24)
fill(78, 96, 13, 13, "L")
fill(105, 126, 5, 36)                # wet descent, to the second shrine
fill(127, 148, 29, 36)               # deep sump / archer tunnel
fill(145, 148, 17, 36)               # shaft III
fill(149, 177, 17, 24)               # final timber gallery

# Optional narrow side chimney, deliberately offset from the main shaft II.
fill(48, 51, 7, 24)
fill(43, 51, 5, 8)
put(45, 8, "H")
fill(43, 47, 9, 9, "#")

# The high bridge has solid abutments; broken slabs drop into a rough catch tunnel.
fill(76, 77, 13, 13, "#")
fill(97, 104, 13, 13, "#")
fill(80, 84, 24, 24, "^")
fill(91, 94, 24, 24, "^")
# Two low steps soften the wet drop without offering a way around any shaft.
fill(111, 118, 22, 22, "=")
fill(119, 125, 29, 29, "=")

put(5, 36, "@"); put(12, 36, "1"); put(22, 36, "2")
put(35, 24, "k"); put(40, 24, "3")
put(47, 24, "s"); put(58, 24, "a")
put(72, 12, "4"); put(75, 12, "s")
put(102, 12, "a")
put(114, 36, "k"); put(124, 36, "5")
put(133, 36, "s"); put(141, 36, "a")
put(156, 24, "s"); put(168, 24, "s"); put(175, 24, "E")
put(69, 12, "h"); put(129, 36, "h"); put(151, 24, "h")

# Timber sets, lanterns, candles and ore, placed irregularly (seeded) so the galleries don't look stamped.
import random
rng = random.Random(2)

def air(c, r):
    return 0 <= r < H and 0 <= c < W and g[r][c] == "."

def solid(c, r):
    return 0 <= r < H and 0 <= c < W and g[r][c] == "#"

for left, right, ceiling, floor in [(3, 23, 29, 37), (29, 62, 17, 25),
                                   (68, 103, 5, 13), (106, 125, 29, 37),
                                   (128, 144, 29, 37), (150, 176, 17, 25)]:
    c = left + rng.randint(1, 4)
    while c < right - 1:
        if air(c, ceiling):
            put(c, ceiling, "T")
            if rng.random() < 0.55 and air(c + 1, ceiling + 1):
                put(c + 1, ceiling + 1, "l")
        if rng.random() < 0.45 and air(c + rng.randint(-2, 2), floor - 1):
            put(c + rng.randint(-2, 2), floor - 1, "c") if air(c, floor - 1) else None
        c += rng.randint(5, 11)
    # ore seams only where they touch rock: along the ceiling and the side walls
    for _ in range((right - left) // 6):
        oc = rng.randint(left, right)
        if air(oc, ceiling) and solid(oc, ceiling - 1):
            put(oc, ceiling, "o")
    for wall_c in (left, right):
        for _ in range(2):
            orow = rng.randint(ceiling + 1, floor - 2)
            if air(wall_c, orow) and (solid(wall_c - 1, orow) or solid(wall_c + 1, orow)):
                put(wall_c, orow, "o")
    for _ in range(max(1, (right - left) // 14)):
        rc = rng.randint(left + 2, right - 2)
        if air(rc, ceiling + 1):
            put(rc, ceiling + 1, "r")
for x, low, high in [(25, 36, 17), (64, 24, 5), (146, 36, 17)]:
    for r in range(high + 2, low, 5):
        put(x, r, "t")
        if air(x + 3, r - 2):
            put(x + 3, r - 2, "o")
# Tall timber sets and wet seams give the descent depth above the sump.
for c in (108, 116, 124):
    put(c, 6, "T")
for c, r in [(110, 8), (123, 13), (108, 18), (123, 24)]:
    put(c - 1, r - 1, "r")
for c, r in [(109, 10), (121, 16), (109, 25), (120, 32), (82, 18), (95, 19), (49, 12), (44, 6)]:
    if g[r][c] == ".":
        put(c, r, "t")

header = """name: The Deep Mines of Norra
theme: 2
darkness: #42485f
stone: #cdbcb4
hint1: Traversa's Mark: hold toward a wall and press JUMP again to leap off it.
hint2: Climb the shaft: alternate walls and fresh jumps. UP also climbs a grabbed ledge.
hint3: Violet glint: an archer draws for a moment. Roll through, jump over, or face it and tap V to return its bolt.
hint4: Cracked stone shakes, then falls. Keep moving! The lower gallery catches you.
hint5: The flame remembers. The last shaft leads toward Dornis; ore above hides another path.
map:
"""
out = Path(__file__).resolve().parents[2] / "levels" / "level2.txt"
out.write_text(header + "\n".join("".join(row) for row in g) + "\n")
print("wrote", out)
