from generate import *
k=json.loads((R/'kael.json').read_text())['image']
request('kael_run','animate-with-text-v3',{'first_frame':k,'action':'Run in place toward the right, full side profile, athletic realistic stride, same green skin black ponytail dark green tunic brown boots and ochre sash, empty hands, fixed camera and consistent scale.','frame_count':4,'no_background':True},.05)
print('Measured animation spend',spent(),flush=True)
print((R.parent/'ledger.json').read_text(),flush=True)
