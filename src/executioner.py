import subprocess as sp
from os import path, get_terminal_size
from helpers import make_even

from muncher import munch
from plugins.colors import *


def build_n_run(args: dict):

    video = args['input']

    if args['output']:
        output = args['output']

    else:
        if args['verbose']: suffix = f'QM - preset {args["preset"]}'
        else: suffix = 'Munched'

        filepath = path.splitext(video)[0]
        output = path.join(filepath + f' ({suffix})' + '.mp4')

        count = 2
        while path.exists(output):
            output = path.join(filepath + f' ({suffix})' + f' [{count}]' + '.mp4')
            count += 1

    ext = path.splitext(output)[1]

    munched = munch(args)

    if ext == '.gif':
        enc = f'-an -map 0:0 -f gif'

    else:
        enc = ' '.join((f'-c:v libx264 -b:v {munched["video_br"]}k -preset slower',
                      # f'-maxrate {munched["video_br"]}k -minrate {munched["video_br"]}k -bufsize 1',
                        f'-c:a aac -b:a {munched["audio_br"]}k',
                        f'-x264-params partitions=p4x4,i4x4'))

    video_filters = '-vf ' + ','.join(munched['vf'])
    audio_filters = '-af ' + ','.join(munched['af']) if munched['af'] else ''

    overwrite = '-y' if args['y'] else ''

    main_cmd = ' '.join(('ffmpeg -loglevel error -stats',
                        f'-i "{path.abspath(video)}"',
                        f'{video_filters} {audio_filters}',
                        f'-r {int(munched["FPS"])} {enc}'
                         ' -stats_period 0.05',
                        f' "{path.abspath(output)}"'
                        f' {overwrite}'))

    # print(main_cmd)

    if args['verbose']:

        verb = { 'infile' : path.abspath(video),
                 'outfile': path.abspath(output),
                 'videobr': munched['video_br'],
                 'audiobr': munched['audio_br'],
                 'fps'    : munched['FPS'],
                 'vf'     : munched['vf'] }

        # if af isn't empty add it to verb, else add 'None'
        verb['af'] = munched['af'] if munched['af'] else ['None']

        print_verb(verb)

    dur_cmd = ' '.join((f'ffprobe -v error',
                         '-of default=noprint_wrappers=1:nokey=1',
                         '-select_streams v:0',
                         '-show_entries format=duration',
                         f'"{path.abspath(video)}"'))

    firstrun = True
    error = None

    duration_output = sp.getoutput(dur_cmd)

    try:
        duration = float(duration_output)
    except ValueError:
        error = duration_output

    process = sp.Popen(main_cmd, stdout=sp.PIPE, stderr=sp.STDOUT, universal_newlines=True)

    def continue_without_bar(line: str, firstrun: bool):
        # this function only exists because i wanted to avoid duplicate code
        if firstrun: printp('Failed to print progress bar, skipping...', 'warning')
        print('\033[2K' + line, end='\033[1A') # keep ffmpeg stats on the same line
        firstrun = False

    for line in process.stdout:

        if not line.startswith('frame='): # if ffmpeg fails
            error = line

        elif error is None: # if duration didnt fail
            try:
                h, m, s = line[line.index('t'):line.index('b')].split('=')[1].split(':')
                secsdone = int(h) * 3600 + int(m) * 60 + float(s)

                columns = get_terminal_size().columns
                barsize = int(columns / 2)
                percentage = round(secsdone / duration * 100)
                if percentage > 100: percentage = 100
                progress = round(percentage / 100 * barsize)

                bar =  f'{fg.lwhite}╭[{fg.rgb(246, 85, 218)}{"■" * progress}►'
                bar += f'{fg.lwhite}{" " * (barsize - progress)}]╯'

                # raise Exception('lol')

                pad = 3 - len(str(percentage))

                print(f'\033[0K', end='') # clear the line

                # prints out " [x%] {bar}" with respective colors
                print(f'{fg.lwhite:>6}[{fg.rgb(221, 153, 204)}{percentage}%{fg.lwhite}] {" " * pad}{bar}', end='\r')

            except Exception as e:
                error = e
                continue_without_bar(line, firstrun)
                firstrun = False

        else: # if duration failed (not required for ffmpeg to run)
            continue_without_bar(line, firstrun)
            firstrun = False

    if error is not None:

        errortype = type(error).__name__
        if errortype == 'str': errortype = 'Error' # if it's not an exception

        msg = f'{fg.yellow}{errortype}{fg.white} occurred while printing progress bar, printing traceback...'

        print()
        if isinstance(error, Exception): errortype = 'exception' # printp only recognizes 'exception'
        printp(error, errortype, msg=msg)

        print('\n' + prfx_txt('EOF\n', 'QM', prfx_color=fg.yellow, text_color=fg.yellow) + '\n')

    else:
        print('\n')
        printp('Finished munching!\n', 'success')
        print()

def print_verb(verb: dict):

    pad = ' ' * 3
    smallpad = ' '

    vf_items = '\n'.join(f'{syntax_hl(pad + "|> " + item)}' for item in verb['vf'])
    af_items = '\n'.join(f'{syntax_hl(pad + "|> " + item)}' for item in verb['af'])
    nl = '\n' # SyntaxError: f-string expression part cannot include a backslash

    v = f"""
{prfx_txt(nl, 'MISC', prfx_color=fg.rgb(155, 183, 255), separator='')}

{pad}{st.url}{fg.rgb(170, 178, 252)}Input file{reset}{fg.white}: {verb["infile"]}
{pad}{st.url}{fg.rgb(199, 167, 240)}Output file{reset}{fg.white}: {verb["outfile"]}

{prfx_txt(nl, 'VIDEO', prfx_color=fg.rgb(211, 161, 231), separator='')}

{pad}{st.url}{fg.rgb(223, 156, 221)}Calculated bitrate{reset}{fg.white}: {verb["videobr"]}kb/s
{pad}{st.url}{fg.rgb(240, 146, 198)}Output framerate{reset}{fg.white}: {verb["fps"]}FPS

{smallpad + prfx_txt(nl, 'FILTERS', prfx_color=fg.rgb(245, 143, 185), separator='')}

{vf_items}

{prfx_txt(nl, 'AUDIO', prfx_color=fg.rgb(249, 140, 171), separator='')}

{pad}{st.url}{fg.rgb(251, 138, 156)}Calculated bitrate{reset}{fg.white}: {verb["audiobr"]}kb/s

{smallpad + prfx_txt(nl, 'FILTERS', prfx_color=fg.rgb(249, 140, 145), separator='')}

{af_items}
"""
    print(v)