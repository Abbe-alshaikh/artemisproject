import serial
import time

# The baud rates to test.
baud_rates = [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600, 1000000]

# The data to send.
data = bytes(range(256)) * 40  # This will give you 10240 bytes (10 kByte or 80 kbit)

for _ in range(100):
    for index, baud_rate in enumerate(baud_rates):
        # Open the serial port with the current baud rate.
        ser = serial.Serial('/dev/cu.usbserial-0001', baud_rate)

        # Wait for acknowledgment from the receiver that it's ready to receive data.
        ack_signal = bytes([index])
        ready = ser.read(1)

        if ready == ack_signal:
            # If ready, send the data.
            ser.write(data)
            print(f"Data sent at {baud_rate} baud.")
        else:
            print(f"No readiness signal received at {baud_rate} baud.")

        # Close the serial port.
        ser.close()
