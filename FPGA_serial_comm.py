import serial
import time
import numpy as np

def complete_uart(mat_size):
    ser = serial.Serial('COM3', 9600)

    matrixA = np.random.randint(10, size=mat_size**2)
    print(matrixA)

    for num in matrixA:
        time.sleep(0.01)
        ser.write(chr(num).encode())
        ser.flush()

    x = input("Waiting for switch to be flipped!!")
    matrixB = np.random.randint(10, size=mat_size**2)
    print(matrixB)
               
    for num1 in matrixB:
        time.sleep(0.01)
        ser.write(chr(num1).encode())
        ser.flush()

    counter = 0
    FPGA_mat = []
    while counter < mat_size**2:
        a = ser.read()
        FPGA_mat.append(int.from_bytes(a))
        counter += 1
    ser.close()

    matrixA = np.array(matrixA).reshape(mat_size, mat_size)
    matrixB = np.array(matrixB).reshape(mat_size, mat_size)
    print("FPGA Output: ", np.array(FPGA_mat).reshape(mat_size, mat_size))
    print("Actual Output: ", np.matmul(matrixA, matrixB))
