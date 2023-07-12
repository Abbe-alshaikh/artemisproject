import json
import serial
import base64
import time

# Specify the JSON file to send back
file_path = "gateway_data.json"
eot_signal = b'END_OF_TRANSMISSION'

try:
    # Open the serial port
    ser = serial.Serial('/dev/ttyUSB0', 9600)
    ser.flushInput()  # flush any leftover input
    ser.flushOutput()  # flush any leftover output

    print("Serial port opened.")

    while True:  # Keep receiving data
        # Buffer to store received data
        bytes_data = bytearray()

        print("Waiting to receive data...")

        # Read the data
        while True:
            byte = ser.read_until(expected=eot_signal)  # read until EOT signal
            bytes_data.extend(byte)
            if eot_signal in bytes_data:  # End-of-transmission signal
                print("Received EOT signal.")
                bytes_data = bytes_data.split(eot_signal)[0]
                break

        # Decode the base64 data and convert it back to JSON
        json_data = base64.b64decode(bytes_data).decode('utf8')
        data = json.loads(json_data)

        print(f"Received data: {data}")

        print("Data received. Sending acknowledgment...")

        # Send an acknowledgment
        ser.write(eot_signal)
        print("Acknowledgment sent.")

        # Pause for a while before sending data
        time.sleep(20)

        print("Sending data...")

        # Open the file in text mode and read its contents
        with open(file_path, 'r') as f:
            print(f"File {file_path} opened.")
            json_data = f.read()

        # Convert JSON data to bytes and encode it in base64
        base64_data = base64.b64encode(json_data.encode('utf8'))

        # Send data
        ser.write(base64_data)
        print("Data sent. Sending EOT signal...")

        # Send a special end-of-transmission string
        ser.write(eot_signal)
        print("EOT signal sent.")
        
        print("Finished sending data. Waiting for acknowledgment...")

        # Wait for acknowledgment
        while True:
            bytes_data = ser.read_until(expected=eot_signal)  # read until EOT signal
            if eot_signal in bytes_data:  # Acknowledgment signal
                print("Received acknowledgment.")
                break

        # Pause for a while before the next receiving
        time.sleep(20)

    # Close the serial port
    ser.close()

    print("Serial port closed.")

except serial.SerialException as e:
    print(f"Failed to open serial port: {e}")
except FileNotFoundError as e:
    print(f"Failed to open file: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
