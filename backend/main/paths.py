from pathlib import Path

# Gives a universal uri to the "/backend" directory
# Fixes a whole mess with the paths

PROJECT_MAIN = Path(__file__).resolve().parent
PROJECT_ROOT = PROJECT_MAIN.parent