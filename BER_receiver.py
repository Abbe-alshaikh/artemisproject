
import serial
import pandas as pd

# The baud rates to test.
baud_rates = [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600, 1000000]

# The expected data pattern (10 kByte = 10240 bytes).
expected_bytes = bytes(range(256)) * 40

# Results data
results_data = {"baud_rate": [], "ber": []}

# For each baud rate...
for _ in range(100):
    for index, baud_rate in enumerate(baud_rates):
        # Open the serial port.
        ser = serial.Serial('/dev/ttyUSB0', baud_rate, timeout=1)

        # Send a signal to the sender that we're ready to receive data.
        ack_signal = bytes([index])
        ser.write(ack_signal)

        received = b""  # Treat the received data as bytes
        total_expected_len = len(expected_bytes)

        while len(received) < total_expected_len:
            # Read available data from the serial port.
            data = ser.read(total_expected_len - len(received))
            received += data

            if not data:
                print("No more data received")
                break

        # Count the number of bit errors.
        errors = sum(el1 != el2 for el1, el2 in zip(expected_bytes, received))

        # Calculate the bit error rate.
        ber = errors / (len(expected_bytes) * 8)  # 8 bits per character

        print(f"Bit Error Rate at {baud_rate} baud: {ber}")

        # Append the results to the dictionary
        results_data["baud_rate"].append(baud_rate)
        results_data["ber"].append(ber)

        # Close the serial port.
        ser.close()

# Create a pandas DataFrame and save it to an Excel file.
df = pd.DataFrame(results_data)
df.to_excel('results_on_th_floor.xlsx', index=False)
