from __future__ import division

import argparse
import re
import os
import scipy.io as sio

parser = argparse.ArgumentParser(description='Transform music file into an MAT file')
parser.add_argument('musicfile')
args = parser.parse_args()


def note_to_freq(note):
    match = re.match('^([b#]?[A-G])(\\d)$', note)
    assert match, 'invalid note \'%s\'' % note
    pitch, octave = match.groups()
    halfsteps_table = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2}
    halfstep_freq = 2 ** (1 / 12)
    freq = 440 * (halfstep_freq ** halfsteps_table[pitch[-1]])
    if pitch[0] == 'b':
        freq /= halfstep_freq
    elif pitch[0] == '#':
        freq *= halfstep_freq
    freq *= 2 ** (int(octave) - 4)
    return freq


instrument_options = {'guitar_waveguide': {'dampness': 0.99, 'pluck_pos': 0.2, 'pickup_pos': 0.8},
                      'guitar_ks': {'dampness': 0.99}}  # default options
musicfile = args.musicfile

with open(musicfile) as f:
    arguments = {}
    line = f.readline().strip()
    line_no = 1
    while line not in ('----', ''):
        match = re.match('^(\\S+)=(\\S+)$', line)
        assert match, 'invalid line %d' % line_no
        try:
            arguments[match.group(1)] = float(match.group(2))
        except ValueError:
            arguments[match.group(1)] = match.group(2)
        line = f.readline().strip()
        line_no += 1

    try:
        bpm = float(arguments['bpm'])
        fullnote_time = 4 / (bpm / 60)  # duration of a full note
    except:
        raise ValueError('missing or invalid BPM')
    try:
        instrument = arguments['instrument']
    except:
        raise ValueError('missing instrument')
    if instrument not in instrument_options:
        raise ValueError('invalid instrument \'%s\'' % instrument)
    options = {}
    for (key, value) in arguments.items():
        if key not in ('bpm', 'instrument'):
            if key not in instrument_options[instrument]:
                raise ValueError('invalid option \'%s\'' % key)
            options[key] = value
    for (key, value) in instrument_options[instrument].items():  # use default value for missing options
        if key not in options:
            options[key] = value

    notes = []  # list of (freq, time, duration) tuples
    curr_time = 0


    def parse_bar(line_no, curr_time):
        line = f.readline().strip()
        line_no += 1
        while line not in ('----', '--', ''):
            match = re.match('^(\\S+) (\\d+)/(\\d+)$', line)
            assert match, 'invalid line %d' % line_no
            duration = fullnote_time * (int(match.group(2)) / int(match.group(3)))
            if match.group(1) != 'R':
                notes.append((note_to_freq(match.group(1)), curr_time, duration))
            curr_time += duration
            line = f.readline().strip()
            line_no += 1
        return line, line_no, curr_time


    while line != '':
        (line, line_no, temp_time) = parse_bar(line_no, curr_time)
        while line == '--':
            (line, line_no, _) = parse_bar(line_no, curr_time)
        curr_time = temp_time

    mat = {'instrument': instrument, 'notes': notes}
    mat.update(options)

    root, ext = os.path.splitext(musicfile)
    output = root + '.mat'
    sio.savemat(output, mat)
