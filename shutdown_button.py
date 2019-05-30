import RPi.GPIO as GPIO
from subprocess import call

def shutdown(pin):
   call(['shutdown', '-h', 'now'], shell=False)

GPIO.setmode(GPIO.BOARD)
GPIO.setup(5, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.add_event_detect(5, GPIO.FALLING, callback=shutdown)

while True:
   pass