import scipy.io as sio import serial

print("loading file...")
# load file containing the signal in a .mat file b = sio.loadmat('signalFile.mat')
print("file loaded")
# set up the serial port for exporting data
arduino = serial.Serial(port='COM3', baudrate=115200)

# move the data from the file into a variable of integers c = b['qS'].astype(int)
pack = []
print("Sending bytes...")

i = 0 print(len(c[0])/100)
# while loop that reads out the data from the variable and loads it to the serial port
while i < len(c[0])/50:
# the serial port can not hold all the data at once so data is sent in blocks of 10 characters
# when the arduino board has read some the data back which the computer reads to send the next
# 10 characters
if i == 0 or arduino.read() == b'A':
# convert 10 integers to characters as bits to be sent over the serial
port
num = c[0, i*10:(i+1)*10-1].tobytes()
 
# the tobytes() function adds buffers which are unwanted so this loop removes them
for j in range(int(len(num)/4)): pack.append(num[j*4])
# write the data to the serial port arduino.write(pack)
pack = [] i += 1


print("bytes sent")
# send final character to the arduino to turn off the shutters arduino.write((36).to_bytes(1, byteorder='big'))
# close the serial port arduino.close()
