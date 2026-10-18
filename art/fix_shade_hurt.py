"""Use the explicitly reserved fix allowance for one late review defect."""
from generate import *
name='shade_hurt_retry'
if (R/(name+'.json')).exists():
 print('Reusing shade hurt retry',flush=True)
elif (R/(name+'.request.json')).exists():
 raise RuntimeError('The one permitted shade hurt retry was already submitted; recover its job with poll/get instead of submitting again')
else:
 before=spent();print(f'Before reserved fix {name}: ${before:.5f}',flush=True)
 if before+.035>.98:raise RuntimeError('Reserved fix would leave insufficient margin under hard $1 cap')
 payload={'first_frame':json.loads((R/'shade.json').read_text())['image'],'action':'The EXACT same narrow hooded violet guard FLINCHES slightly backwards from a hit coming from the RIGHT, then regains his footing. Keep SIDE PROFILE FACING RIGHT throughout. Preserve the original hood, pale face, dark violet outfit and small curved sword. Sword remains still. No sword trails, no white rectangles, no bright effects, no new objects. Fixed camera and scale, transparent background.','frame_count':4,'no_background':True}
 (R/(name+'.request.json')).write_text(json.dumps({'endpoint':'animate-with-text-v3','payload':payload,'est_usd':.035,'reserved_fix':True,'spent_before_usd':before},indent=2))
 result=call('animate-with-text-v3',payload,est_usd=.035,note=name)
 (R/(name+'.json')).write_text(json.dumps(result))
 print('Reserved fix completed; spend',spent(),flush=True)
