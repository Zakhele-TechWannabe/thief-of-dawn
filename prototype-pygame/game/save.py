import json
import os
from pathlib import Path

SAVE_PATH=Path.home()/'.local/share/thief-of-dawn/save.json'

def save_progress(level,max_hp,time_left,path=None):
    path=Path(path) if path else SAVE_PATH
    data={'version':1,'level':level,'max_hp':max_hp,'time_left':time_left}
    try:
        path.parent.mkdir(parents=True,exist_ok=True)
        temp=path.with_suffix('.tmp')
        temp.write_text(json.dumps(data))
        os.replace(temp,path)
        return True
    except OSError:return False

def load_progress(path=None):
    try:
        data=json.loads((Path(path) if path else SAVE_PATH).read_text())
        if data.get('version')!=1 or not 1<=int(data['level'])<=5 or not 3<=int(data['max_hp'])<=30 or not 0<float(data['time_left'])<=2700:return None
        return {'level':int(data['level']),'max_hp':int(data['max_hp']),'time_left':float(data['time_left'])}
    except (OSError,ValueError,TypeError,KeyError):return None
