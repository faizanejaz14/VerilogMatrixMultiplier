import serial

ser = serial.Serial('COM3', 9600)
while True:
    a = ser.read()
    print(a)
