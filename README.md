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


##### Optional arguments
`--help` / `-h`
: Show this message and exit

`--verbose` / `-v`
: Increase output verbosity

`--curdir` / `-dir`
: Open the folder in which Quality Muncher was installed

##### Input / output options

`--input` / `-i` `<PATH>`
: Specify input video path / filename
  - required

`--output` / `-o` `<PATH>`
: Specify output path / filename

##### Video options

`--preset` / `-p` `<int>`
: Specify quality preset
  - default: `1`
  - min-max: `1-10`

`--contrast` / `-c` `<float>`
: Modify video contrast
  - default: `1.0`
  - min-max: `0-2`

`--saturation` / `-s` `<float>`
: Modify video saturation
  - default: `1.0`
  - min-max: `0-2`

`--brightness` / `-b` `<float>`
: Modify video brightness
  - default: `1.0`
  - min-max: `0-2`

`--speed` / `-spd` `<float>`
: Modify video speed
  - default: `1.0`
  - min-max: `0-2`

`--stretch` / `-str` `<multiplier:(w/h)>`
: Stretch video resolution
  - multiplier can be a float
  - `w` stretches width, `h` stretches height

##### Audio options

`--audio-distort` / `-ad` `<method:strength>, ...`
: Distort audio
  - methods: `earrape`, `echo`, `delay`
  - strength: `1-10` (float)



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