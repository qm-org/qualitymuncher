import re
import subprocess as sp
from math import log, sqrt
from os import path
from plugins.colors import printp

from helpers import make_even


class Video:

    def downscale(preset: int, n: int):
        return make_even(preset / (preset ** 2) / 4 * n)

    def get_res(video: str, stretch: str):

        cmd = ' '.join(('ffprobe -v error',
                        '-show_entries stream=width,height',
                        '-of default=noprint_wrappers=1:nokey=1',
                        f'"{path.abspath(video)}"'))

        o = sp.getoutput(cmd)
        if not re.match(r'\d+\n\d+', o): # check if output is valid
            printp(o, 'error')
            exit(1)

        res = [int(n) for n in o.splitlines()] # get all numbers

        if stretch:
            stretch = stretch.split(':')
            multip = float(stretch[0])

            # math to calculate stretch while preserving pixel count
            if stretch[1] == 'w':
                res[0] = sqrt(multip) * res[0]
                res[1] = 1 / sqrt(multip) * res[1]

            elif stretch[1] == 'h':
                res[0] = 1 / sqrt(multip) * res[0]
                res[1] = sqrt(multip) * res[1]

        return [make_even(n) for n in res]

    def calc_br(video: str, preset: int, stretch_res: str):

        fps = 24 - 3 * preset
        width, height = Video.get_res(video, stretch_res)

        mp = width * height / 1000000
        bpp = (1 - log(mp, 2) / 6) / 4
        video_br = int((bpp * mp + 0.5) * 100 * fps / preset)

        if preset == 7:
            p6BR = Video.calc_br(video, 6, stretch_res)[0]
            video_br = int(p6BR / 2.5)

        return video_br, fps

    def filters(args: dict):

        vf, eq_filter, scale_fltr = [], [], []

        in_w, in_h = Video.get_res(args['input'], args['stretch'])

        scaled_w, scaled_h = (Video.downscale(args['preset'], in_w),
                              Video.downscale(args['preset'], in_h))

        scale_fltr.append(f'zscale={scaled_w}:{scaled_h}:f=point') # down
        if args['stretch']: scale_fltr.append('setsar=1:1')
        scale_fltr.append(f'zscale={in_w}:{in_h}:f=point') # up
                        # f'format=yuv410p',
                        # f'unsharp=la=0:ca={qualPreset}

        for item in scale_fltr: vf.append(item)

        if args['contrast'] != 1:
            contrast_val = (args['contrast'] - 1) * 1000
            contrastFLTR = f'contrast={contrast_val}'

            eq_filter.append(contrastFLTR)

        if args['saturation'] != 1:
            if args['saturation'] > 1:
                sat_val = (args['saturation'] * 3) / 2

            else: sat_val = args['saturation']

            sat_fltr = f'saturation={round(sat_val, 3)}'
            eq_filter.append(sat_fltr)

        if args['brightness'] != 1:
            brightnessFLTR = f'brightness={args["brightness"] - 1}'
            eq_filter.append(brightnessFLTR)


        if args['speed'] != 1:
            speedFLTR = f'setpts=({1 / args["speed"]})*PTS'
            vf.append(speedFLTR)

        if eq_filter: vf.append(f'eq={":".join(eq_filter)}')

        return vf


class Audio:

    def calc_br(preset: int):
        return int(80 / preset)

    def audio_distort(args: dict):

        ad = []
        methods = list(args)

        if 'earrape' in methods:
            distsev = int(args['earrape'] * 10)
            bboost_fltr = ''.join((f"firequalizer=gain_entry='",
                                     f'entry(0,{distsev});',
                                     f'entry(600,{distsev});',
                                     f'entry(1500,{distsev});',
                                     f'entry(3000,{distsev});',
                                     f'entry(6000,{distsev});',
                                     f'entry(12000,{distsev});',
                                     f"entry(16000,{distsev})'"))
            ad.append(bboost_fltr)

        if 'delay' in methods:
            x = args['delay'] * 100
            y = args['delay'] * 10
            delay_fltr = (f'adelay={x}|{x + y}|{x + y * 2}',
                         f'channelmap=1|0')

            for item in delay_fltr: ad.append(item)

        if 'echo' in methods:
            echo_fltr = f'aecho=0.8:0.3:{args["echo"] * 2}:0.9'
            ad.append(echo_fltr)

        return ad

    def filters(args: dict):

        af = []

        if args['speed'] != 1:
            af.append(f'atempo={args["speed"]}')

        if args['audio_distort']:

            ad = Audio.audio_distort(args['audio_distort'])
            for item in ad: af.append(item)

        return af


def munch(args: dict):

    munched = {}

    munched['video_br'], munched['FPS'] = Video.calc_br(args['input'],
                                                        args['preset'],
                                                        args['stretch'])

    munched['audio_br'] = Audio.calc_br(args['preset'])

    munched['vf'] = Video.filters(args)
    munched['af'] = Audio.filters(args)

    return munched
