# Quality Muncher

## About
This branch contains the Python version of Quality Muncher, it is still in
development so if you have any bugs, issues, questions, or suggestions join our discord server: https://discord.gg/9tRZ6C7tYz

# Installation

## Install via Scoop
Run the following block of code in PowerShell:

```powershell
iex(irm get.scoop.sh)
scoop bucket add utils
scoop install utils/qm-py
```
This will:
1. Install [Scoop](https://scoop.sh), a convenient and easy-to-use package manager for Windows
2. Add the [utils](https://github.com/couleur-tweak-tips/utils) bucket
3. Download and install Quality Muncher


## Manual installation / Linux
> NOTE: LINUX IS NOT FULLY SUPPORTED YET, SOME FEATURES MAY NOT WORK

1. Install Python >= 3.10
2. Download the `.zip` from releases
3. Add the folder to `PATH`

# Usage
> Please report any issues!

This version of Quality Muncher is used via the command line, `qm -h` should get you started

### Arguments
Text inside following characters **is not literal**: `<` `>` `(` `)`
`...` means the argument takes multiple values of the same format

| Name                        | Explanation                                                         | Format                   | Default value | Possible values                                     | Example               | Required |
| --------------------------- | ------------------------------------------------------------------- | ------------------------ | ------------- | --------------------------------------------------- | --------------------- | -------- |
| `--help` / `-h`             | Show this message and exit                                          |                          |               |                                                     | `-h`                  |          |
| `--verbose` /        `-v`   | Increase output verbosity                                           |                          |               |                                                     | `-v`                  |          |
| `--curdir` /         `-dir` | Open the folder in which Quality Muncher was installed              |                          |               |                                                     | `-dir`                |          |
| `--input` /         `-i`    | Specify input video path / filename                                 | `<PATH>`                 |               |                                                     | `-i cutedog.mp4`      | True     |
| `--output` /        `-o`    | Specify output path / filename                                      | `<PATH>`                 |               |                                                     | `-o munched.mp4`      |          |
| `--preset` /        `-p`    | Specify quality preset                                              | `<preset>`               | 1             | 1-7                                                 | `-p 5`                |          |
| `--contrast` /      `-c`    | Modify video contrast                                               | `<amount>`               | 1.0           | 0-2                                                 | `-c 1.1`              |          |
| `--saturation` /    `-s`    | Modify video saturation                                             | `<amount>`               | 1.0           | 0-2                                                 | `-s 1.2`              |          |
| `--brightness` /    `-b`    | Modify video brightness                                             | `<amount>`               | 1.0           | 0-2                                                 | `-b 1.3`              |          |
| `--speed` /         `-spd`  | Modify video speed                                                  | `<multiplier>`           | 1.0           |                                                     | `-spd 1.5`            |          |
| `--stretch` /       `-str`  | Stretch video resolution, `w` stretches width, `h` stretches height | `<multip:(w/h)>`         |               |                                                     | `-str 2:w`            |          |
| `--audio-distort` / `-ad`   | Distort audio                                                       | `<method:strength>, ...` |               | methods: `earrape`, `echo`, `delay`; strength: 1-10 | `-ad echo:5,delay:10` |          |

### Examples
The most basic usage, it will use the default preset and output to the same folder as the input
```
qm -i video.mp4
```

Munch using preset 5 with verbose output enabled
```
qm -i video.mp4 -p 5 -v
```

Munch with every setting set to 10 (or their maximum value)
```
qm -i video.mp4 -p 7 -c 2 -s 2 -b 2 -spd 10 -str 10:w -ad earrape:10,echo:10,delay:10 -v
```