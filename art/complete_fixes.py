import sys,subprocess,time,json
from pathlib import Path
sys.dont_write_bytecode=True
A=Path(__file__).resolve().parent
while not (A/'ART_REPORT.md').exists():time.sleep(3)
subprocess.run([sys.executable,'-B',str(A/'fix_bosses.py')],check=True)
sys.path.insert(0,str(A.parent))
from tools.pixellab import spent
(A/'spend.json').write_text(json.dumps({'spent_usd':spent()},indent=2))
for script in ['art_build.py','validate.py','report.py']:
 subprocess.run([sys.executable,'-B',str(A/script)],check=True)
