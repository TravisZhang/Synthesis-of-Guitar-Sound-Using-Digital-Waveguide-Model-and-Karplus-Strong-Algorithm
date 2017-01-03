function y = guitar_waveguide(fs, f, t, d, pl, pu)
%GUITAR_WAVEGUIDE Generate a single guitar note using waveguide model
%   fs: sampling frequency (Hz)
%   f: frequency (Hz)
%   t: duration (s)
%   d: attenuation (lower=>damper)
%   pl: pluck position, [0 1]
%   pu: pickup position, [0 1]

N = round(fs/f); % length of the delay line
if mod(N,2) == 1
    N = N+1;
end
M = N/2;

pl = round(pl*M);
pu = round(pu*M);

initial = [linspace(0,0.5,pl) linspace(0.5,0,M-pl)]; % initial condition
line = [initial initial];
ptr = 0;
y = zeros(round(fs*t),1);

prev1 = 0;
prev2 = 0;

for i = 1:length(y)
    y(i) = line(mod(ptr+pu,N)+1) + line(mod(ptr-pu,N)+1);
    
    tmp = line(ptr+1);
    line(ptr+1) = -(line(ptr+1)+prev1)/2*d;
    prev1 = tmp;
    
    tmp = line(mod(ptr+M,N)+1);
    line(mod(ptr+M,N)+1) = -(line(mod(ptr+M,N)+1)+prev2)/2*d;
    prev2 = tmp;
    
    ptr = mod(ptr+1,N);
end

y = y-mean(y);
y = y/max(abs(y));

end