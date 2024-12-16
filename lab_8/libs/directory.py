import os

DATA_DIR = "data"

def create_dir(dirname=DATA_DIR):
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    return dirname
