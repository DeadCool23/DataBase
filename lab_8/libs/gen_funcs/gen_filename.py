from datetime import datetime

def gen_filename(tablename, filenum):
    timestamp = datetime.now().strftime("%d.%m.%Y_%H-%M")
    filename = f"{tablename}_{timestamp}_number-{filenum}.csv"
    return filename