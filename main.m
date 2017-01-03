function [y, fs] = main(filename)
%MAIN Read MAT file and generate WAV file

fs = 44100;
music = load(filename);
instrument = music.instrument;
notes = music.notes;
duration = max(notes(:,2)+notes(:,3))+0.05;
y = zeros(round(duration*fs), 1);
if strcmp(instrument, 'guitar_waveguide')
    dampness = music.dampness;
    pluck_pos = music.pluck_pos;
    pickup_pos = music.pickup_pos;
    for i = 1:length(notes)
        start = round(notes(i,2)*fs);
        note = guitar_waveguide(fs, notes(i,1), notes(i,3), ...
                                dampness, pluck_pos, pickup_pos);
        note = note*log(notes(i,1));
        y(start+1:start+length(note)) = ...
            y(start+1:start+length(note)) + note;
    end
elseif strcmp(instrument, 'guitar_ks')
    dampness = music.dampness;
    for i = 1:length(notes)
        start = round(notes(i,2)*fs);
        note = guitar_ks(fs, notes(i,1), notes(i,3), dampness);
        note = note*log(notes(i,1));
        y(start+1:start+length(note)) = ...
            y(start+1:start+length(note)) + note;
    end
end
y = y-mean(y);
y = y/max(abs(y));

[pathstr, name, ~] = fileparts(filename);
output = [pathstr name '.wav'];
audiowrite(output, y, fs);

end