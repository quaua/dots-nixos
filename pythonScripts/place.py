import json
import sys
import os
import path

os.makedirs(os.path.dirname(path.CONFIG_PATH), exist_ok=True)
with open(path.CONFIG_PATH, 'w') as f:
    json.dump({'city': sys.argv[1], 'country': sys.argv[2]}, f)