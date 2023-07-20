% Define the sensor data
numBits = 80000;  % Total number of bits
dataBitsPerFrame = 8; % Number of data bits per frame
numFrames = numBits / dataBitsPerFrame;  % Total number of frames
% Define the UART parameters
startBit = 0; % Start bit value
stopBit = 1; % Stop bit value
useParity = true; % Whether to use parity
% Initialize the decoded data array
decodedData = zeros(1, numBits);
% Initialize the bit error count
numErrors = 0;
for frame = 1:numFrames
    % Generate data bits for this frame
    sensorData = randi([0 1], 1, dataBitsPerFrame);
    disp("Sensor data for frame " + frame + ": ");
    disp(sensorData);
    % Frame the data with start bit, data bits, parity bit, and stop bit
    framedData = zeros(1, dataBitsPerFrame + 2 + useParity);
    % Add start bit
    framedData(1) = startBit;
    % Add data bits
    framedData(2 : 1 + dataBitsPerFrame) = sensorData;
    % Add parity bit if enabled
    if useParity
        parityBit = mod(sum(sensorData), 2);
        framedData(1 + dataBitsPerFrame + 1) = parityBit;
end
% Add stop bit
    framedData(1 + dataBitsPerFrame + 1 + useParity) = stopBit;
    disp("Framed data for frame " + frame + ": ");
    disp(framedData);
    % At the receiver, decode the data and check parity bit
    % Retrieve the full frame from the received data
    receivedFrame = framedData;
    disp("Received framed data for frame " + frame + ": ");
disp(receivedFrame);
    % Decode the data bits from the received frame
    decodedData((frame-1)*dataBitsPerFrame + 1 : frame*dataBitsPerFrame) =
 receivedFrame(2 : 1 + dataBitsPerFrame);
    disp("Decoded data for frame " + frame + ": ");
    disp(decodedData((frame-1)*dataBitsPerFrame + 1 :
 frame*dataBitsPerFrame));
    % Check the parity bit if enabled
    if useParity
        parityBitReceived = receivedFrame(1 + dataBitsPerFrame + 1);  %
 Retrieve the received parity bit
        parityBitExpected = mod(sum(receivedFrame(2 : 1 + dataBitsPerFrame)),
 2);  % Calculate the expected parity bit
        % If parity bit is incorrect, print a warning
        if parityBitReceived ~= parityBitExpected
            disp('Warning: Parity bit check failed for frame ' + frame + '.');
end end
    % Compare the decoded data with the original data and count bit errors
    errors = sum(decodedData((frame-1)*dataBitsPerFrame + 1 :
 frame*dataBitsPerFrame) ~= sensorData);
    numErrors = numErrors + errors;
    disp('---------------------------------------');
end
% Calculate and display the Bit Error Rate (BER)
BER = numErrors / numBits;
disp("Bit Error Rate (BER): " + BER);

