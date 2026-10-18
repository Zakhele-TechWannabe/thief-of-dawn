from pathlib import Path
import pillow_bootstrap
from PIL import Image
import json
root=Path(__file__).resolve().parents[1]/'assets'
errors=[];counts={}
for p in root.rglob('*.png'):
 im=Image.open(p);rel=p.relative_to(root);kind=rel.parts[0];counts[kind]=counts.get(kind,0)+1
 if im.mode!='RGBA':errors.append(f'{rel}: not RGBA')
 if kind=='sprites' and im.getchannel('A').tobytes().count(0)<im.width*im.height*.4:errors.append(f'{rel}: background is not sufficiently transparent')
 if set(im.getchannel('A').tobytes())-{0,255}:errors.append(f'{rel}: nonbinary alpha')
 size=None
 if kind=='sprites':size=(64,64)
 elif kind=='backgrounds':size=(480,256)
 elif kind=='tiles':size=(16,48) if p.stem=='pillar' else (16,16)
 elif kind=='ui':size=(480,270) if p.stem=='title' else (32,32)
 elif kind=='props':
  name=p.stem;size=(16,32) if name.startswith('torch') or name=='lantern' else {'sword':(32,16),'exit_door':(32,48),'gate':(16,48),'plate':(16,8),'slicer':(16,48)}.get(name,(16,16))
 if im.size!=size:errors.append(f'{rel}: size {im.size}, expected {size}')
for actor in ['kael','shade','vesh','morrow']:
 p=root/'sprites'/actor/'meta.json'
 if not p.exists():errors.append(f'{actor}: no metadata');continue
 meta=json.loads(p.read_text())
 if meta.get('anchor')!=[32,60] or meta.get('frame_size')!=[64,64]:errors.append(f'{actor}: metadata contract')
 for anim,settings in meta['anims'].items():
  frames=sorted((p.parent/anim).glob('*.png'))
  if [f.name for f in frames]!=[f'{i:02}.png' for i in range(len(frames))] or not frames:errors.append(f'{actor}/{anim}: frame sequence')
  if not isinstance(settings.get('loop'),bool) or not 0<settings.get('fps',0)<=30:errors.append(f'{actor}/{anim}: invalid playback metadata')
 actual={f.parent.name for f in p.parent.glob('*/*.png')}
 if actual-set(meta['anims']):errors.append(f'{actor}: stale animation files')
 required=['idle','run','jump','fall','hang','climb','attack','block','hurt','death'] if actor=='kael' else ['idle','walk','attack','block','hurt','death']
 for name in required:
  if name not in meta['anims']:errors.append(f'{actor}/{name}: missing (engine placeholder)')
print(json.dumps({'counts':counts,'issues':errors},indent=2))
(root.parent/'art/validation.json').write_text(json.dumps({'counts':counts,'issues':errors},indent=2))
