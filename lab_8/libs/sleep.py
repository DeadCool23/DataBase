import time

SLEEP_MINUTES = 5
SLEEP_SECONDS = SLEEP_MINUTES * 60

def delay(delay_time=SLEEP_SECONDS):
    time.sleep(delay_time)