def id_input(io_message):
    return int_input(io_message)

def int_input(io_message):
    try:
        num = int(input(io_message))
    except:
        num = -1

    return num