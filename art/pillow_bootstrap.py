"""Use installed Pillow, or the archived local dependency; never accesses network."""
import importlib.util
import sys
from pathlib import Path
if importlib.util.find_spec('PIL') is None:
    sys.path.insert(0,str(Path(__file__).resolve().parent/'raw/python_deps'))
