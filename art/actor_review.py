from pathlib import Path
import sys,json
import pillow_bootstrap
from PIL import Image,ImageDraw
from raw_images import images
raw=Path(__file__).resolve().parent/'raw';actor=sys.argv[1];rows=[]
for anim in ['idle','walk','run','jump','fall','hang','climb','attack','block','hurt','death']:
 p=raw/((actor if anim=='idle' else actor+'_'+anim)+'.json')
 if not p.exists():continue
 frames=images(json.loads(p.read_text()));scale=2 if len(frames)>6 else 3
 rows.append((anim,frames,scale))
height=sum(64*s+24 for _,_,s in rows);out=Image.new('RGB',(1200,height),(25,27,38));d=ImageDraw.Draw(out);y=0
for anim,frames,s in rows:
 d.text((0,y),actor+'/'+anim,fill='white');y+=20
 for i,f in enumerate(frames):
  f=f.resize((64*s,64*s),Image.Resampling.NEAREST);out.paste(f,(i*64*s,y),f)
 y+=64*s+4
out.save(raw/(actor+'_review.png'))
