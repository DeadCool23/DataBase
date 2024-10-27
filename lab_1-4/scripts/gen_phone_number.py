import random

def generate_phone_number():
    area_code = '7'
    prefix = f'{random.randint(900, 999)}'
    line_number = f'{random.randint(1000000, 9999999)}'
    return f'+{area_code} ({prefix}) {line_number[:3]} {line_number[3:5]}-{line_number[5:]}'