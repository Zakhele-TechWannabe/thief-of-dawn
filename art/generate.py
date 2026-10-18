import sys,json,base64
from pathlib import Path
sys.dont_write_bytecode=True
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from tools.pixellab import call,poll,get,spent
R=Path(__file__).resolve().parent/'raw'
def request(name,endpoint,payload,estimate):
 cached=R/(name+'.json')
 if cached.exists():
  print('Reusing archived '+name,flush=True)
  return json.loads(cached.read_text())
 print(f'Before batch {name}: ${spent():.5f}',flush=True)
 (R/(name+'.request.json')).write_text(json.dumps({'endpoint':endpoint,'payload':payload,'est_usd':estimate},indent=2))
 if spent()+estimate>.90: raise RuntimeError('Planning ceiling reached')
 result=call(endpoint,payload,est_usd=estimate,note=name)
 if endpoint=='create-tileset-sidescroller':
  detail=result.get('last_response') or result
  tid=detail.get('tileset_id') or result.get('tileset_id')
  if tid:result['retrieved_tileset']=get('tilesets-sidescroller/'+tid)
 (R/(name+'.json')).write_text(json.dumps(result))
 print(name,'result shape',str(shape(result))[:600],flush=True)
 return result
def shape(x):
 if isinstance(x,dict): return {k:shape(v) for k,v in x.items()}
 if isinstance(x,list):return [shape(v) for v in x[:2]]
 if isinstance(x,str) and len(x)>220:return x[:100]+'...'
 return x
if __name__=='__main__':
 request('kael','create-image-pixflux',{'description':'Full body side profile facing RIGHT, lean adult green-skinned Valerin youth, black hair tied back, emerald eye, dark green tunic, brown leather bracers boots and ochre sash. Empty hands, agile swordsman standing idle. Prince of Persia cinematic pixel art, realistic slender proportions, 48 pixels tall centered on 64 canvas, crisp pixels, transparent background, no shadow.','image_size':{'width':64,'height':64},'view':'side','direction':'east','no_background':True},.015)
