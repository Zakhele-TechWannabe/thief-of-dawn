"""Decode locally archived API image payloads; no network."""
import base64,io,json
from pathlib import Path
import pillow_bootstrap
from PIL import Image

def images(x):
 out=[]
 if isinstance(x,dict):
  if isinstance(x.get('base64'),str):
   out.append(Image.open(io.BytesIO(base64.b64decode(x['base64'].split(',')[-1]))).convert('RGBA'))
  else:
   for k,v in x.items():
    if k in ('image_data','image_base64') and isinstance(v,str) and not v.startswith('http'):
     out.append(Image.open(io.BytesIO(base64.b64decode(v.split(',')[-1]))).convert('RGBA'))
    else:out.extend(images(v))
 elif isinstance(x,str) and x.startswith('data:image/'):
  out.append(Image.open(io.BytesIO(base64.b64decode(x.split(',')[-1]))).convert('RGBA'))
 elif isinstance(x,list):
  for v in x:out.extend(images(v))
 return out
if __name__=='__main__':
 import sys
 p=Path(sys.argv[1]); im=images(json.loads(p.read_text()))
 for i,x in enumerate(im): x.save(p.with_suffix('') .with_name(p.stem+f'_{i:02}.png'))
 print([(x.size) for x in im])
