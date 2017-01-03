function y = guitar_ks(fs, f, t, d)
%GUITAR_KS Generate a single guitar note using Karplus-Strong algorithm
%   fs: sampling frequency (Hz)
%   f: frequency (Hz)
%   t: duration (s)
%   d: attenuation (lower=>damper)

N = round(fs/f); % length of the delay line

% Input
x = zeros(round(fs*t), 1);
x(1:N) = rand(N, 1);

% Filter
b = [1 zeros(1, N+1)];
a = [1 zeros(1, N-1) -d/2 -d/2];

% Output
y = filter(b, a, x);
y = y-mean(y);
y = y/max(abs(y));

end