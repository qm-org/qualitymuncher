import sys
import re
import argparse as ap
import subprocess as sp
from os import path

from helpers import *
from plugins.colors import printp
from executioner import build_n_run


def get_args():

    global parser
    parser = ap.ArgumentParser(description='Quality Muncher | "The best worst quality"',
                               prog='qm',
                               usage='%(prog)s -i <file> [options]',
                               formatter_class=ap.RawDescriptionHelpFormatter,
                               add_help=False)

    no = ap.SUPPRESS

    opt = parser.add_argument_group('Optional arguments',
    description="""
    --help,    -h,   - Show this message and exit
    --verbose, -v,   - Increase output verbosity
    --curdir,  -dir  - Open the folder in which Quality Muncher was installed
    """)

    opt.add_argument('--help', '-h',
                     default=no,
                     action='help',
                     help=no)

    opt.add_argument('--curdir', '-dir',
                     action='store_true',
                     help=no)

    opt.add_argument('--verbose', '-v',
                     action='store_true',
                     help=no)


    io = parser.add_argument_group(title='Input/output options',
    description="""
    --input,  -i   <PATH>  - Specify input video path / filename
    --output, -o   <PATH>  - Specify output path / filename (OPTIONAL)
    """)

    io.add_argument('--input', '-i',
                    metavar='PATH',
                    action='store',
                    type=str,
                    help=no)

    io.add_argument('--output', '-o',
                    metavar='PATH',
                    action='store',
                    type=str,
                    help=no)


    v = parser.add_argument_group(title='Video options',                        # wanted to avoid the newline
    description="""                                                                   [min-max] [default]
    --preset,     -p    <preset>        - Specify quality preset       1-7        1
    --contrast,   -c    <amount>        - Modify video contrast        0-2       1.0
    --saturation, -s    <amount>        - Modify video saturation      0-2       1.0
    --brightness, -b    <amount>        - Modify video brightness      0-2       1.0
    --speed,      -spd  <multiplier>    - Modify video speed           Any       1.0
    --stretch,    -str  <multip:w/h>    - Stretch video resolution     Any        -
    """)

    v.add_argument('--preset', '-p',
                   default='1',
                   type=int,
                   help=no)
    v.add_argument('--speed', '-spd',
                   default='1',
                   type=float,
                   help=no)
    v.add_argument('--saturation', '-s',
                   default='1',
                   type=float,
                   help=no)
    v.add_argument('--contrast', '-c',
                   default='1',
                   type=float,
                   help=no)
    v.add_argument('--brightness', '-b',
                   default='1',
                   type=float,
                   help=no)
    v.add_argument('--stretch', '-str',
                   help=no)
    v.add_argument('-y',                # overwrite output file if it exists
                   action='store_true', # (same as -y in ffmpeg so no help needed)
                   help=no) 

  # v.add_argument('--text', '-t'
  #                help=no)

    a = parser.add_argument_group(title='Audio options',                              # same deal here :c
    description="""                                                                   [min-max] [default]
    --audio-distort, -ad  <method:strength>, ...  - Distort audio     1-10       -
    """)

    a.add_argument('--audio-distort','-ad',
                   nargs='+',
                   type=str, # parsing is handled later (type=dict doesn't work lol)
                   help=no)

    n = 1
    if len(sys.argv) > n: # https://github.com/Aetopia/Onefile-Python-Interpreter#workarounds
        if sys.argv[0] == sys.argv[1]: n = 2

    return parser.parse_args(sys.argv[n:])


args = vars(get_args()) # makes args a dict


def main():

    if args['curdir']:
        sp.run(f'explorer {sys.path[0]}'); sys.exit(0)

    if not args['input']:
        parser.print_help()
        pause(); sys.exit(0)

    if not path.exists(args['input']):
        printp(FileNotFoundError(f'Path does not exist: {args["input"]}'),
               'exception'); sys.exit(1)

    for arg in ('saturation', 'contrast', 'brightness'):
        if not is_in_range(args[arg], 0, 2):
            printp(ValueError(f'{arg.capitalize()} must be between 0 and 2, got "{args[arg]}"'),
                   'exception'); sys.exit(1)

    if not is_in_range(args['preset'], 0, 7):
        printp(ValueError(f'Preset must be between 0 and 7, got "{args["preset"]}"'),
               'exception'); sys.exit(1)

    if stretch := args['stretch']:
        if not re.match(r'\d+:\d+', stretch):
            printp(InvalidArgumentException(
                   f'Stretch must be in format "multiplier:w/h", got "{stretch}"'),
                   'exception'); sys.exit(1)

    if args['audio_distort']:

        joined = ''.join(args['audio_distort'])

        if ':' not in joined:
            printp(InvalidArgumentException(
                   f'Audio distortion must be in format "method:strength", got "{joined}"'),
                   'exception'); sys.exit(1)

        # parse into dict (audio_distort is a list)
        args['audio_distort'] = str_to_dict(joined)

        for arg in args['audio_distort'].items():

            if arg[0] not in ('earrape', 'delay', 'echo'):
                printp(InvalidArgumentException(
                       f'"{arg[0]}" is not a valid audio distortion method'),
                       'exception'); sys.exit(1)


            if not is_in_range(arg[1], 1, 10):
                printp(ValueError(f'{arg[0].casefold()} must be between 1 and 10, got "{arg[1]}"'),
                       'exception'); sys.exit(1)

    build_n_run(args)


if __name__ == '__main__':
    main()
