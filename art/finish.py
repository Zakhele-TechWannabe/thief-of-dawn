"""Resume orchestration; paid requests remain serialized through the guarded wrapper."""
import time,subprocess,sys,os,json
from pathlib import Path
sys.dont_write_bytecode=True
A=Path(__file__).resolve().parent
while not (A/'raw/shade_death.json').exists():time.sleep(4)
for script in ['retry_kael.py','generate_world.py']:
 subprocess.run([sys.executable,'-B',str(A/script)],check=True)
sys.path.insert(0,str(A.parent))
from tools.pixellab import spent
(A/'spend.json').write_text(json.dumps({'spent_usd':spent()},indent=2))
for script in ['art_build.py','validate.py','report.py']:
 subprocess.run([sys.executable,'-B',str(A/script)],check=True)
