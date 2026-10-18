"""Verify deterministic offline assets and contact sheet without any API imports."""
from pathlib import Path
import hashlib,json,subprocess,sys
root=Path(__file__).resolve().parents[1]
def hashes():
 paths=sorted((root/'assets').rglob('*.png'))+sorted((root/'assets').rglob('meta.json'))+[root/'art/contact_sheet.png']
 return {str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
before=hashes()
subprocess.run([sys.executable,'-B',str(root/'tools/art_build.py')],check=True)
after=hashes();changed=sorted(k for k in before.keys()|after.keys() if before.get(k)!=after.get(k))
result={'network_used':False,'files_checked':len(after),'identical':not changed,'changed_files':changed}
(root/'art/rebuild_check.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
if changed:raise SystemExit(1)
