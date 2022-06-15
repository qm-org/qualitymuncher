from getpass import getpass

class InvalidArgumentException(ValueError):
    """
    Invalid command line argument.
    """
    pass


def pause():
    getpass('Press enter to continue...')


def is_in_range(val: int, min: int, max: int):
    return val >= min and val <= max


def merge_dicts(dicts: tuple[dict, ...]):

    if len(dicts) <= 1:
        return dicts[0]

    res = {}
    for d in dicts:
        res.update(d)

    return res

def str_to_dict(string: str):

    string = string.replace(' ', '')
    pairs = string.split(',')

    d = {}
    for pair in pairs:
        key, value = pair.split(':')
        d[key.casefold()] = float(value)

    return d


def make_even(n: int):
    n = int(n)
    return n if n % 2 == 0 else n - 1