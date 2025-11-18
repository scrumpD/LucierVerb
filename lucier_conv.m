pkg load signal
set(0, 'DefaultFigureVisible', 'off');

% LOAD SIGNAL, you can replace it with anything:
[signal, sampleRate] = audioread('myVoice.wav');
signal = mean(signal, 2);

maxSamples = min(length(signal), 20 * sampleRate);
signal = signal(1:maxSamples);

% BUILD RESONANT IR
M = 4500;
t = (0:M-1)' / sampleRate;

% change the modal frequencies as you wish:
modes = [180, 340, 520, 780, 1150, 1900, 2500];

% MODE RANDOMIZER for FUN!
#{
numModes = 12;
modes = 100 + rand(1, numModes)*2400;
#}

ir = zeros(M,1);
for f = modes
    decay = 1.5;
    ir += exp(-decay * t) .* sin(2*pi*f*t);
end

ir = ir / max(abs(ir));

% MEMORY-SAFE CONVOLUTION
function y = smallconv(x, h)
    y = conv(x, h);
    y = y(1:length(x));
end

% FIRST
lucierVerb = smallconv(signal, ir);

% SECONDARY
step1 = smallconv(signal, ir);
step2 = smallconv(step1, ir);

% ADJUST ITERATIONS
out = signal;
for k = 1:10
    out = smallconv(out, ir);
    out = out / max(abs(out));
end

% SAVE AUDIO TO PROJECT FOLDER

% FILE PATH FROM ROOT DIRECTORY GOES HERE:
base = '';

audiowrite([base 'lucierVerb.wav'],       lucierVerb / max(abs(lucierVerb)), sampleRate);
audiowrite([base 'lucierFeedback1.wav'],  step2 / max(abs(step2)), sampleRate);
audiowrite([base 'lucierFeedback10.wav'], out  / max(abs(out)), sampleRate);

disp("DONE — WAV files saved to [BLANK] folder.");

