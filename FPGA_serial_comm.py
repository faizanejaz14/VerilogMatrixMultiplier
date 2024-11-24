import serial
import time

ser = serial.Serial('COM7', 9600)
ser.write(b'a')
time.sleep(2)

ser.write(b'b')
time.sleep(2)

ser.write(b'c')
time.sleep(2)

ser.write(b'd')
ser.close()
