"""One retry per flagged boss clip, bounded by the $0.90 plan."""
from generate import *
import io
import pillow_bootstrap
from PIL import Image
from raw_images import images
from art_build import actor_clean
jobs=[('vesh','attack','Full SIDE PROFILE FACING RIGHT. Thrust the short curved sword toward the right, pull it back to guard. Preserve exact original green skin, steel armour, red cloak. No turns, no spins, no camera movement, no ground or pedestal.'),('vesh','block','Full SIDE PROFILE FACING RIGHT. Lift the short sword in front of the face to parry a strike from the right, hold the parry. Keep green skin, steel armour and red cloak exactly. No turns, no backdrop, no ground or pedestal.')]
jobs += [
 ('morrow','walk','This exact masked violet-robed scholar glides in place toward RIGHT, subtle robe and arm movement. Full SIDE PROFILE FACING RIGHT throughout, hold the small gold Lantern in forward hand. Preserve the white mask and long robe. Transparent empty background, no camera movement, no turns.'),
 ('morrow','attack','Full SIDE PROFILE FACING RIGHT. This exact pale-masked violet scholar raises the small golden Lantern toward the right, extends free hand forward and casts a small violet shadow spell, then lowers the Lantern. Preserve original robes and silhouette. No swords, no backdrop, no turns.'),
 ('morrow','block','Full SIDE PROFILE FACING RIGHT. This exact white-masked violet-robed scholar lifts the free hand in front of his face to ward off a strike from the right, gold Lantern remains in other hand. Hold that defensive pose. Preserve the original hood and mask. No backdrop, no camera movement, no turns.')]
jobs.append(('morrow','death','Morrow the Hollow rapidly dissolves into violet smoke and vanishes into dawn. His mask and robe break apart into scattered pixels, the whole body disappears. The final frame is empty transparent background. Keep side profile facing RIGHT as he fades; no camera movement.'))
jobs=[job for job in jobs if job[:2]!=('morrow','block')]
if __name__=='__main__':
 for actor,anim,action in jobs:
  review=json.loads((R.parent/'review_state.json').read_text())
  if (R/(actor+'_'+anim+'_retry.json')).exists() or actor+'_'+anim+'_retry' in review.get('rejected',{}):
   print('Reusing completed retry decision for '+actor+'/'+anim,flush=True);continue
  estimate=.032 if anim=='death' else .025
  if spent()+estimate>.90:
   print('Fix budget exhausted; leave '+actor+'/'+anim+' to placeholder',flush=True)
   p=R.parent/'review_state.json';review=json.loads(p.read_text());review.setdefault('omit',[]).append(actor+'_'+anim);p.write_text(json.dumps(review,indent=2));continue
  im=actor_clean(images(json.loads((R/(actor+'.json')).read_text()))[0],actor)
  buf=io.BytesIO();im.save(buf,format='PNG');ref={'type':'base64','base64':base64.b64encode(buf.getvalue()).decode(),'format':'png'}
  payload={'first_frame':ref,'action':action,'frame_count':8 if anim=='death' else 4,'no_background':True}
  if anim=='death':
   blank=Image.new('RGBA',im.size,(0,0,0,0));buf=io.BytesIO();blank.save(buf,format='PNG');payload['last_frame']={'type':'base64','base64':base64.b64encode(buf.getvalue()).decode(),'format':'png'}
  try:
   request(actor+'_'+anim+'_retry','animate-with-text-v3',payload,estimate)
  except Exception as error:
   print('Retry failed; placeholder for '+actor+'/'+anim+': '+str(error)[:500],flush=True)
   p=R.parent/'review_state.json';review=json.loads(p.read_text());review.setdefault('omit',[]).append(actor+'_'+anim);review.setdefault('rejected',{})[actor+'_'+anim+'_retry']='Retry failed: '+str(error)[:500];p.write_text(json.dumps(review,indent=2))

