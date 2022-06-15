import os; os.system('') # required for conhost
from itertools import chain


eof = eol = end = reset = '\33[0m'

# * == incompatible with windows
# ** == incompatible with conhost (works in vscode terminal etc)

class Style:
    bold      = '\33[1m' # **
    italic    = '\33[3m' # **
    url       = '\33[4m'
    blink     = '\33[5m' # *
    altblink  = '\33[6m' # *
    selected  = '\33[7m'
    invisible = '\33[8m'
    strike    = '\33[9m' # **


class Foreground:
    rgb = lambda r, g, b: f'\33[38;2;{r};{g};{b}m'
    black    = '\33[30m'
    red      = '\33[31m'
    green    = '\33[32m'
    yellow   = '\33[33m'
    blue     = '\33[34m'
    violet   = '\33[35m'
    beige    = '\33[36m'
    white    = '\33[37m'
    grey     = '\33[90m'
    lred     = '\33[91m'
    lgreen   = '\33[92m'
    lyellow  = '\33[93m'
    lblue    = '\33[94m'
    lviolet  = '\33[95m'
    lbeige   = '\33[96m'
    lwhite   = '\33[97m'


class Background:
    rgb = lambda r, g, b: f'\33[48;2;{r};{g};{b}m'
    black    = '\33[40m'
    red      = '\33[41m'
    green    = '\33[42m'
    yellow   = '\33[43m'
    blue     = '\33[44m'
    violet   = '\33[45m'
    beige    = '\33[46m'
    white    = '\33[47m'
    grey     = '\33[100m'
    lred     = '\33[101m'
    lgreen   = '\33[102m'
    lyellow  = '\33[103m'
    lblue    = '\33[104m'
    lviolet  = '\33[105m'
    lbeige   = '\33[106m'
    lwhite   = '\33[107m'

# aliases
fg = Foreground
bg = Background
st = Style


def printp(text, preset: str, printend: str = '\n', **kwargs):

    """
    wrapper function for printing stuff with presets

    global params:
        text: Any - text to print (can be anything)
        preset: str - preset name
        printend: str (any) - end of line character

    rainbow params:
        density: int - how many characters to color at once
        affect: str ("fg" or "bg") - affect background or foreground

    exception params:
        msg: str (any) - message to print before exception
        extra_tb: str (any) - additional traceback to print
    """

    preset = preset.casefold()

    if preset == 'rainbow':
        print(rainbow_txt(text, **kwargs))

    elif preset == 'syntax_hl':
        print(syntax_hl(text))

    elif preset == 'warning':
        print(prfx_txt(text, 'WARNING',
                       prfx_color=fg.yellow,
                       text_color=fg.yellow),
                       end=printend)

    elif preset == 'error':
        print(prfx_txt(text, 'ERROR',
                       prfx_color=fg.red,
                       text_color=fg.lred),
                       end=printend)

    elif preset == 'success':
        print(prfx_txt(text, 'SUCCESS',
                       prfx_color=fg.lgreen,
                       text_color=fg.green),
                       end=printend)

    elif preset == 'info':
        print(prfx_txt(text, 'INFO',
                       prfx_color=fg.blue,
                       text_color=fg.white),
                       end=printend)

    elif preset == 'debug':
        print(prfx_txt(text, 'DEBUG',
                       prfx_color=fg.lyellow,
                       text_color=fg.white),
                       end=printend)

    elif preset == 'exception':
        print(format_exc(text, **kwargs), end=printend)

    else:
        print(text, end=printend)


def rainbow_txt(text: str, density=1, affect='fg') -> str:

    text = list(text)
    # split text into groups of length n (density)
    text = [text[i:i + density] for i in range(0, len(text), density)]

    if affect == 'fg': c = Foreground
    if affect == 'bg': c = Background

    for (idx, char), vals in zip(enumerate(text), gen_rainbow(len(text))):

        if len(char) > 1: # if char is a list of characters
            for i, subchar in enumerate(char):
                text[idx][i] = c.rgb(*vals) + subchar # apply the current color to each subchar

        else:
            text[idx] = c.rgb(*vals) + ''.join(char) # char can be list with 1 character

    return ''.join(chain.from_iterable(text)) + reset # flatten + reset


def prfx_txt(text   : str,
             prefix : str,
             prfx_color=fg.lwhite, prfx_style=st.url,
             text_color=fg.white,  text_style='',
             separator=' >>> ') -> str:

    """
    add a prefix to string

    "text" -> f"[{prefix}] >>> text"
    """

    fmt_prefix = fg.white + '[' + prfx_color + prfx_style + prefix + reset + fg.white + ']'

    if len(t := text.strip().splitlines()) > 1: # if multiline string
        s = fmt_prefix + '\n'
        for line in t:
            s += separator + text_color + text_style + line + '\n' + reset
    else:
        s = fmt_prefix + separator + text_color + text_style + text

    return s.rstrip(reset + '\n') + reset # strip last newline


def format_exc(exc: Exception, msg: str = None, extra_tb: str = None) -> str:
    """
    pip-style exception formatting
    """
    import traceback

    if msg is None:
        msg = f'{fg.yellow}{type(exc).__name__}{fg.white} occurred, printing traceback...'

    formatted = []

    if extra_tb is not None:
        formatted += ''.join(extra_tb).splitlines()

    formatted += ''.join(traceback.format_exception(exc)).splitlines()

    pad = ' ' * 4 # hardcoded pad because f-string padding refused to work

    result = f"""
{fg.red}×{reset} {msg}
{fg.red}╰─> {fg.white}[{fg.red}{len(formatted)} line(s) of output{fg.white}]\n
"""
    for line in formatted: result += pad + line + '\n'

    result += f'\n{pad}[{fg.red}end of output{fg.white}]'

    return result + '\n'


def syntax_hl(text: str) -> str:

    """
    highlight special characters in text
    pink theme :3
    """

    parens = ('(', ')', '{', '}', '[', ']')

    ops = ('+', '-', '/', '\\',
           '%', '=', '&', '$',
           '@', '?', '|', '<',
           '>', '*', '!', '~', '^')

    delims = (',', '.', ':', ';')

    default = '\033[38;5;189m'

    fmt = lambda char, *rgbvals: fg.rgb(*rgbvals) + char + reset

    hl = list(text)

    for idx, char in enumerate(hl):

        if char.isdigit():   hl[idx] = fmt(char, 255, 168, 227)
        elif char in parens: hl[idx] = fmt(char, 140, 190, 178)
        elif char in ops:    hl[idx] = fmt(char, 195, 117, 243)
        elif char in delims: hl[idx] = fmt(char, 156, 191, 255)

        else: hl[idx] = default + char + reset

    return ''.join(hl) + reset


def hsv_to_rgb(h: float, s: float, v: float) -> tuple[int, int, int]:

    if s == 0.0: return (v, v, v)

    i = int(h * 6)
    f = h * 6 - i

    p = int(255 * (v * (1 - s )))
    q = int(255 * (v * (1 - s * f)))
    t = int(255 * (v * (1 - s * (1 - f))))

    v *= 255

    i %= 6

    if i == 0: return (v, t, p)
    if i == 1: return (q, v, p)
    if i == 2: return (p, v, t)
    if i == 3: return (p, q, v)
    if i == 4: return (t, p, v)
    if i == 5: return (v, p, q)


def gen_rainbow(steps: int):
    for h in _nrange(0, 360, steps):
        yield hsv_to_rgb(h / 360, 1, 1)


### private methods ###

def _nrange(x: int | float,
            y: int | float,
            n: int):

    assert n > 1, 'n must be greater than 1'
    step = (y - x) / (n - 1)
    for i in range(n):
        yield x + i * step