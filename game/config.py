from pathlib import Path
WIDTH, HEIGHT, ROOM_H = 480, 270, 256
TILE, COLS, ROWS, FPS = 16, 30, 16, 60
ROOT = Path(__file__).resolve().parent.parent
ASSET_ROOT = ROOT / 'assets'
DATA_ROOT = ROOT / 'data' / 'levels'
GRAVITY = 620.0
WALK_SPEED, RUN_SPEED, CAREFUL_SPEED = 68.0, 112.0, 28.0
JUMP_SPEED = 228.0
THEMES = [(25, 32, 55), (38, 31, 29), (20, 28, 55), (34, 39, 44), (36, 21, 55)]
NAMES = ['The Vaults of Thalor', 'The Deep Mines of Norra', 'The Rooftops of Dornis', 'The Walls of Valerion', 'The Nexus of Creation']
FATES = ['Traversa', 'Vitaria', 'Ascenda', 'Eterna', 'Enigma']
