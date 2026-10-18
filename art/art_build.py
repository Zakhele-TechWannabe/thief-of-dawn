"""Offline build: PYTHONPATH=/tmp/thief-art-python python -B art/art_build.py
Requires Pillow. Reads only art/raw; writes assets and art review outputs.
"""
from pathlib import Path
import sys,json,math
import pillow_bootstrap
from PIL import Image,ImageEnhance,ImageDraw,ImageFont,ImageOps
from raw_images import images
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from tools.art_build import fit_actor
ROOT=Path(__file__).resolve().parents[1]; RAW=ROOT/'art/raw'; OUT=ROOT/'assets'
NN=Image.Resampling.NEAREST
records=[]
def save(im,path):
 path=OUT/path;path.parent.mkdir(parents=True,exist_ok=True)
 im=im.convert('RGBA'); a=im.getchannel('A').point(lambda v:255 if v>=128 else 0);im.putalpha(a)
 temporary=path.with_name(path.name+'.tmp');im.save(temporary,format='PNG');temporary.replace(path);records.append((str(path.relative_to(OUT)),im.copy()))
def load(name):
 p=RAW/(name+'.json')
 return images(json.loads(p.read_text())) if p.exists() else []
def clean(im):
 im=im.convert('RGBA');im.putalpha(im.getchannel('A').point(lambda v:255 if v>=128 else 0));return im
def actor_clean(im,actor):
 im=clean(im)
 if actor=='vesh':
  px=im.load()
  for y in range(45,min(64,im.height)):
   brown=sum(1 for x in range(im.width) if (lambda c:c[3]>127 and c[0]>c[1]*1.1 and c[1]>c[2]*1.1)(px[x,y]))
   if brown>=16:
    for yy in range(max(0,y-1),im.height):
     for xx in range(im.width):
      r,g,b,a=px[xx,yy]
      if r>g*1.1 and g>b*1.1:px[xx,yy]=(0,0,0,0)
    # Drop isolated remnants of the floor without cutting a fallen body in half.
    seen=set();components=[]
    for yy in range(im.height):
     for xx in range(im.width):
      if (xx,yy) in seen or px[xx,yy][3]==0:continue
      pending=[(xx,yy)];component=[];seen.add((xx,yy))
      while pending:
       ax,ay=pending.pop();component.append((ax,ay))
       for dx,dy in ((-1,-1),(0,-1),(1,-1),(-1,0),(1,0),(-1,1),(0,1),(1,1)):
        bx,by=ax+dx,ay+dy
        if 0<=bx<im.width and 0<=by<im.height and (bx,by) not in seen and px[bx,by][3]:seen.add((bx,by));pending.append((bx,by))
      components.append(component)
    if components:
     keep=set(max(components,key=len))
     for component in components:
      if component and component[0] not in keep:
       for xx,yy in component:px[xx,yy]=(0,0,0,0)
    break
 return im

def sprites(actor):
 base=load(actor)
 if not base:return
 meta={'frame_size':[64,64],'anchor':[32,60],'anims':{}}
 for anim in (['idle','run','jump','fall','hang','climb','attack','block','hurt','death'] if actor=='kael' else ['idle','walk','attack','block','hurt','death']):
  review=json.loads((ROOT/'art/review_state.json').read_text()) if (ROOT/'art/review_state.json').exists() else {}
  recipe=review.get('frames',{}).get(actor+'_'+anim)
  frames=load(recipe['source']) if recipe else load(actor+'_'+anim)
  if recipe:frames=[frames[i] for i in recipe['indices']]
  if actor+'_'+anim in review.get('omit',[]) or (actor+'_'+anim in review.get('pending_retry',[]) and not (RAW/(actor+'_'+anim+'_retry.json')).exists()):
   omitted=OUT/'sprites'/actor/anim
   if omitted.exists():
    for stale in omitted.glob('*.png'):stale.unlink()
   continue
  if actor+'_'+anim in review.get('prefer_retry',[]) and (RAW/(actor+'_'+anim+'_retry.json')).exists():frames=load(actor+'_'+anim+'_retry')
  if not frames:
   if anim=='idle':frames=base
   else:
    missing=OUT/'sprites'/actor/anim
    if missing.exists():
     for stale in missing.glob('*.png'):stale.unlink()
    continue
  animdir=OUT/'sprites'/actor/anim
  if animdir.exists():
   for old in animdir.glob('*.png'):old.unlink()
  for i,im in enumerate(frames):
   if recipe and i in recipe.get('mirror',[]):im=ImageOps.mirror(im)
   im=actor_clean(im,actor)
   canvas=fit_actor(im,actor,anim)
   save(canvas,Path('sprites')/actor/anim/f'{i:02}.png')
  meta['anims'][anim]={'fps':{'idle':6,'run':12,'walk':8,'attack':12,'death':7}.get(anim,8),'loop':anim in ['idle','run','walk','hang','fall','block']}
 metapath=OUT/'sprites'/actor/'meta.json';temporary=metapath.with_suffix('.json.tmp');temporary.write_text(json.dumps(meta,indent=2));temporary.replace(metapath)

def variants():
 for actor in ['vesh','morrow']:
  if load(actor):continue
  src=OUT/'sprites/shade'
  if not src.exists():continue
  target=OUT/'sprites'/actor
  if target.exists():
   for stale in target.glob('*/*.png'):stale.unlink()
  for p in sorted(src.glob('*/*.png')):
   im=Image.open(p).convert('RGBA');px=im.load()
   for y in range(64):
    for x in range(64):
     r,g,b,a=px[x,y]
     if not a:continue
     lum=int(.25*r+.45*g+.3*b)
     if actor=='vesh':
      if 26<y<53 and x<29: c=(min(210,lum*2+40),lum//3+12,lum//3+22)
      elif 14<y<25 and x>31 and lum>50: c=(min(150,lum+35),min(210,lum*2+55),lum+24)
      else:c=(min(220,lum+50),min(225,lum+55),min(235,lum+66))
     else:
      c=(min(240,lum+110),min(240,lum+108),min(255,lum+120)) if y<23 else (lum//2+30,lum//2+22,min(160,lum+56))
     px[x,y]=(*c,a)
   if actor=='morrow':
    # Taller pale scholar silhouette, retaining inherited motion. Fill robe only on upright poses.
    if p.parent.name!='death':
     d=ImageDraw.Draw(im);d.polygon([(27,30),(36,30),(41,56),(23,56)],fill=(44,32,66,255));d.line([(31,34),(30,55)],fill=(76,55,95),width=1)
    # Stretch vertically about the feet by 4 pixels while preserving 64 canvas.
    stretched=im.resize((64,69),NN);im=Image.new('RGBA',(64,64));im.alpha_composite(stretched,(0,-5))
   save(im,Path('sprites')/actor/p.relative_to(src))
  dst=OUT/'sprites'/actor;dst.mkdir(parents=True,exist_ok=True);(dst/'meta.json').write_text((src/'meta.json').read_text())

def world():
 for n in range(1,6):
  ims=load('tiles'+str(n))
  if ims:
   if max(im.width for im in ims)<=32:
    unique=list({im.tobytes():im for im in ims}.values());sheet=Image.new('RGBA',(16*4,16*math.ceil(len(unique)/4)))
    for i,t in enumerate(unique):sheet.alpha_composite(t.resize((16,16),NN),((i%4)*16,(i//4)*16))
   else:sheet=max(ims,key=lambda im:im.width*im.height)
   sheet.save(RAW/f'tiles{n}_sheet.png')
   # API Wang sheet: choose full opaque interior and an upper walkable surface by occupancy.
   tiles=[sheet.crop((x,y,x+16,y+16)) for y in range(0,sheet.height-15,16) for x in range(0,sheet.width-15,16)]
   opaque=sorted(tiles,key=lambda t:sum(t.getchannel('A').point(lambda a:1 if a>127 else 0).tobytes()),reverse=True)
   solid=opaque[0]; candidates=[t for t in tiles if sum(t.getchannel('A').crop((0,8,16,16)).tobytes())>16*8*200]
   top=min(candidates,key=lambda t:sum(t.getchannel('A').crop((0,0,16,4)).tobytes())) if candidates else solid
   rawmeta=json.loads((RAW/f'tiles{n}.json').read_text())
   named=rawmeta.get('retrieved_tileset',{}).get('tileset',{}).get('tiles',[])
   for item in named:
    corners=item.get('corners',{});decoded=images(item)
    if not decoded:continue
    if all(corners.get(k)=='lower' for k in ('NW','NE','SW','SE')):solid=decoded[0].resize((16,16),NN)
    if corners=={'NW':'upper','NE':'upper','SW':'lower','SE':'lower'}:top=decoded[0].resize((16,16),NN)
   # Collision surface is the tile's top edge, so remove empty padding above the cap.
   bounds=top.getbbox()
   if bounds and bounds[1]>0:
    aligned=solid.copy();aligned.alpha_composite(top,(0,-bounds[1]));top=aligned
   save(solid,Path(f'tiles/level{n}/solid.png'));save(top,Path(f'tiles/level{n}/top.png'))
   save(ImageEnhance.Brightness(solid).enhance(.40),Path(f'tiles/level{n}/bg.png'))
   # Pillar and window assembled from generated masonry, no network.
   pillar=Image.new('RGBA',(16,48));
   for y in range(0,48,16):pillar.alpha_composite(solid,(0,y))
   d=ImageDraw.Draw(pillar);d.rectangle((0,0,2,47),fill=(16,17,30));d.line((13,0,13,47),fill=(99,91,111));save(pillar,Path(f'tiles/level{n}/pillar.png'))
   window=solid.copy();d=ImageDraw.Draw(window);d.rectangle((4,3,11,14),fill=(12,14,31));d.arc((4,0,11,8),180,360,fill=(110,98,125));save(window,Path(f'tiles/level{n}/window.png'))
  ims=load('background'+str(n))
  if ims:save(ImageEnhance.Brightness(ims[0].resize((480,256),NN)).enhance(.68),Path(f'backgrounds/level{n}.png'))
 sizes={'torch':(16,32),'potion_small':(16,16),'potion_big':(16,16),'sword':(32,16),'lantern':(16,32),'exit_door':(32,48),'gate':(16,48),'spikes':(16,16),'loose_floor':(16,16),'plate':(16,8),'slicer':(16,48)}
 for name,size in sizes.items():
  ims=load('prop_'+name)
  if not ims:continue
  im=clean(ims[0].resize(size,NN))
  if name in ('gate','spikes','slicer'):im=ImageEnhance.Brightness(im).enhance(1.5)
  if name in ('spikes','plate','loose_floor') and im.getbbox():
   cut=im.crop(im.getbbox()); target={'spikes':(14,14),'plate':(16,5),'loose_floor':(16,16)}[name]
   cut=cut.resize(target,NN);im=Image.new('RGBA',size);im.alpha_composite(cut,((size[0]-target[0])//2,size[1]-target[1]))
  if name=='torch':
   for i in range(3):
    frame=im.copy()
    if i:
     flame=frame.crop((0,0,16,14));frame.paste((0,0,0,0),(0,0,16,14));frame.alpha_composite(ImageEnhance.Brightness(flame).enhance(1+i*.10),(i%2,0))
    save(frame,Path(f'props/torch_{i:02}.png'))
  else:save(im,Path('props')/(name+'.png'))
 for fate in ['traversa','vitaria','ascenda','eterna','enigma']:
  ims=load('mark_'+fate)
  if ims:save(ims[0].resize((32,32),NN),Path(f'ui/mark_{fate}.png'))
 ims=load('title')
 if ims:
  title=ims[0].resize((480,272),NN).crop((0,1,480,271))
  font=ImageFont.load_default(size=13);text='THIEF OF DAWN'
  mask=Image.new('1',(240,25));d=ImageDraw.Draw(mask);bb=d.textbbox((0,0),text,font=font);x=(240-bb[2])//2
  d.text((x,2),text,font=font,fill=1)
  mask=mask.resize((480,50),NN).convert('L')
  title.paste((10,10,23),(2,27,482,77),mask);title.paste((239,201,124),(0,25,480,75),mask)
  save(title,Path('ui/title.png'))

def contact():
 groups=[]; grouped={}
 for label,im in records:
  if label.startswith('sprites/'):
   key='/'.join(label.split('/')[:3]);grouped.setdefault(key,[]).append(im)
  else:groups.append((label,im))
 character_groups=[]
 for key,frames in grouped.items():
  strip=Image.new('RGBA',(64*len(frames),64))
  for i,f in enumerate(frames):strip.alpha_composite(f,(i*64,0))
  character_groups.append((key,strip))
 groups=character_groups+groups
 for level in range(1,6):
  atlas=RAW/f'tiles{level}_sheet.png'
  if atlas.exists():groups.append((f'RAW complete level{level} Wang tileset',Image.open(atlas).convert('RGBA')))
 review=json.loads((ROOT/'art/review_state.json').read_text()) if (ROOT/'art/review_state.json').exists() else {}
 for key in sorted(review.get('rejected',{})):
  frames=load(key)
  if not frames:continue
  strip=Image.new('RGBA',(64*len(frames),64))
  for i,f in enumerate(frames):strip.alpha_composite(f.resize((64,64),NN),(i*64,0))
  groups.append(('REJECTED attempt: '+key,strip))
 width=1800;rows=[];x=y=12;rowh=0;font=ImageFont.load_default()
 for label,im in groups:
  im=im.resize((im.width*2,im.height*2),NN)
  box=font.getbbox(label);cellwidth=max(im.width,box[2]-box[0]+8)
  if x+cellwidth+12>width:x=12;y+=rowh+12;rowh=0
  rows.append((label,im,x,y));x+=cellwidth+16;rowh=max(rowh,im.height+24)
 sheet=Image.new('RGB',(width,y+rowh+12),(25,27,38));d=ImageDraw.Draw(sheet)
 for label,im,x,y in rows:
  d.text((x,y),label,fill=(230,220,190))
  if label.startswith('sprites/'):
   baseline=y+20+120;d.line((x,baseline,x+im.width,baseline),fill=(52,58,72))
   for offset in range(64,im.width,128):d.line((x+offset,baseline-3,x+offset,baseline+3),fill=(91,103,122))
  sheet.paste(im,(x,y+20),im)
 target=ROOT/'art/contact_sheet.png';temporary=target.with_suffix('.png.tmp');sheet.save(temporary,format='PNG');temporary.replace(target)
if __name__=='__main__':
 for a in ['kael','shade','vesh','morrow']:sprites(a)
 variants();world();contact();print(f'Built {len(records)} PNG assets')
