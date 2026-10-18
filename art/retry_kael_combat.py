from generate import *
base=json.loads((R/'kael.json').read_text())['image']
for name,action in [('attack','Draw a small curved short sword and slash forward toward RIGHT, then return to guard. Full SIDE PROFILE FACING RIGHT the whole time. Keep exactly the original dark green tunic, brown bracers, black ponytail and green skin. No giant white swoosh effects, no camera movement.'),('death','This same green-skinned swordsman in his dark green tunic staggers, knees buckle, collapses SIDEWAYS onto the ground, ends lying horizontally motionless. Keep exact original outfit and scale. SIDE PROFILE FACING RIGHT, no recovery to standing, no camera rotation.')]:
 request('kael_'+name+'_retry','animate-with-text-v3',{'first_frame':base,'action':action,'frame_count':4,'no_background':True},.025)
