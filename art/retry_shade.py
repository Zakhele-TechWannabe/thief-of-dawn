from generate import *
base=json.loads((R/'shade.json').read_text())['image']
request('shade_death_retry','animate-with-text-v3',{'first_frame':base,'action':'Side profile facing RIGHT. This same hooded violet guard staggers, bends knees, collapses sideways to the ground and lies flat motionless. Sword drops beside body. Preserve original narrow humanoid proportions and outfit. No giant blade trails, no rectangular effects, no zoom. Fixed camera and scale.','frame_count':4,'no_background':True},.025)
