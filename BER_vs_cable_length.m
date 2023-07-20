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
% Define range of cable lengths and initialize BER array
cableLengths = 1:100;  % Cable lengths from 1 to 100 meters
BERs = zeros(size(cableLengths));  % Initialize BER array
for i = 1:length(cableLengths)
    % Initialize bit error counter
    bitErrors = 0;
    cableLength = cableLengths(i);
    noiseFactor = cableLength * 0.0001; % Noise factor
    for frame = 1:numFrames
        % Generate data bits for this frame
        sensorData = randi([0 1], 1, dataBitsPerFrame);
        % Frame the data with start bit, data bits, parity bit, and stop bit
        framedData = zeros(1, dataBitsPerFrame + 2 + useParity);
        framedData(1) = startBit;
        framedData(2 : 1 + dataBitsPerFrame) = sensorData;
        % Add parity bit if enabled
        if useParity
            parityBit = mod(sum(sensorData), 2);
            framedData(1 + dataBitsPerFrame + 1) = parityBit;
end
        framedData(1 + dataBitsPerFrame + 1 + useParity) = stopBit;
        % Retrieve the full frame from the received data and add noise based
 on cable length
        receivedFrame = framedData;
        noise = rand(1,length(receivedFrame)) < noiseFactor;
        receivedFrame = xor(receivedFrame, noise);
        % Decode the data bits from the received frame
        decodedData((frame-1)*dataBitsPerFrame + 1 : frame*dataBitsPerFrame) =
 receivedFrame(2 : 1 + dataBitsPerFrame);
        % Check the parity bit if enabled
if useParity
            parityBitReceived = receivedFrame(1 + dataBitsPerFrame + 1);  %
 Retrieve the received parity bit
            parityBitExpected = mod(sum(receivedFrame(2 : 1 +
 dataBitsPerFrame)), 2);  % Calculate the expected parity bit
            % If parity bit is incorrect, increment bit error counter
            if parityBitReceived ~= parityBitExpected
                bitErrors = bitErrors + 1;
end end
end
    % Calculate and store the Bit Error Rate (BER) for this cable length
    BERs(i) = bitErrors / numFrames;
end
% Plot the results
figure;
plot(cableLengths, BERs);
xlabel('Cable Length (m)');
ylabel('Bit Error Rate');
title('Bit Error Rate vs. Cable Length');
