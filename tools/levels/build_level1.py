"""Writes levels/level1.txt (The Vaults of Thalor). Edit here, re-run, keep the txt in git."""
from pathlib import Path

W, H = 184, 34
g = [["." for _ in range(W)] for _ in range(H)]

def fill(c0, c1, r0, r1, ch="#"):
    for r in range(r0, r1 + 1):
        for c in range(c0, c1 + 1):
            g[r][c] = ch

def put(c, r, ch):
    g[r][c] = ch

# shell
fill(0, W - 1, 0, 2); fill(0, W - 1, 31, 33); fill(0, 1, 0, H - 1); fill(W - 2, W - 1, 0, H - 1)

# A — the sealed vault (cols 0-26): low ceiling, a step, then a wall you must grab
fill(0, 26, 3, 12)
fill(12, 15, 29, 30)                     # step: first jump
fill(27, 46, 24, 30)                     # 7-tile wall: first ledge grab
for c in range(3, 11):
    for r in (15, 16, 18, 19, 21, 22):
        put(c, r, "b")                   # bookshelves
for c in range(18, 25):
    for r in (16, 17, 19, 20):
        put(c, r, "b")
put(4, 30, "@"); put(7, 30, "1"); put(23, 30, "2")
put(9, 25, "t"); put(24, 23, "t"); put(16, 13, "w")

# B — the galleries (cols 27-75): spike gap, planks up to an alcove
fill(27, 100, 3, 8)
put(48, 9, "l")
fill(47, 52, 30, 30, "^")                # spikes at the bottom of the gap
fill(53, 99, 24, 30)                     # far side of the gap: the hall floor
fill(32, 36, 20, 20, "="); fill(38, 42, 16, 16, "=")
put(40, 15, "h")
fill(37, 43, 9, 11, "#")                 # alcove ceiling
for c in (30, 58, 66, 90):
    put(c, 9, "|")
put(34, 21, "t"); put(44, 18, "t")

# C — Whisper Hall (cols 53-99): checkpoint, first shade
put(56, 23, "k"); put(61, 23, "3"); put(76, 23, "s")
put(68, 9, "l"); put(84, 9, "l"); put(72, 10, "w"); put(94, 10, "w")
for c in range(62, 72):
    for r in (13, 14, 16, 17):
        put(c, r, "b")
put(64, 20, "t"); put(88, 20, "t")

# D — the crypt (cols 100-140): drop down a shaft into a low corridor, two shades
fill(107, 140, 3, 25)                    # crypt ceiling: a low, tight corridor
fill(101, 105, 27, 27, "=")              # plank to break the drop
put(103, 30, "4"); put(118, 30, "s"); put(132, 30, "s")
put(112, 27, "t"); put(126, 27, "t"); put(138, 30, "H")

# E — the climbing chamber (cols 141-162): three rising pillars
fill(141, 181, 3, 8)
fill(145, 148, 26, 30); fill(152, 155, 21, 30); fill(159, 181, 16, 30)
put(150, 10, "w"); put(143, 22, "t"); put(157, 15, "t"); put(149, 30, "h")

# F — the scriptorium door (cols 159-181)
put(170, 15, "s"); put(176, 15, "5"); put(179, 15, "E")
put(165, 9, "l"); put(174, 9, "l")
for c in range(161, 169):
    for r in (11, 12, 14):
        put(c, r, "b")
put(172, 12, "t")

for c, r in [(10, 30), (21, 30), (30, 23), (44, 23), (58, 23), (70, 23), (92, 23), (108, 30), (124, 30), (136, 30),
             (150, 30), (157, 20), (162, 15), (167, 15), (178, 15)]:
    if g[r][c] == ".":
        put(c, r, "c")

header = """name: The Vaults of Thalor
theme: 1
darkness: #4a4e68
hint1: The vault is sealed. Find another way out.
hint2: Jump at a high ledge and hold toward it to grab on. UP to climb.
hint3: A shade. Its eyes flare before it strikes: V to parry, then X to punish.
hint4: C to dodge-roll. Nothing can touch you mid-roll.
hint5: UP at the door to leave the vaults.
map:
"""
out = Path(__file__).resolve().parents[2] / "levels" / "level1.txt"
out.write_text(header + "\n".join("".join(row) for row in g) + "\n")
print("wrote", out)
