# maketests

Make system tests with GNU Make and GNU Bash

## 1. Downloading

Up-to-date *maketests* source code can be
[cloned](https://github.com/ktalik/maketests.git)
as git repository or downloaded as
[tarball](https://github.com/ktalik/maketests/archive/master.tar.gz)
or
[zip](https://github.com/ktalik/maketests/archive/master.zip)
from GitHub.

## 2. Dependencies

System dependencies are GNU Make, GNU Bash and Git (optional for diff).

## 3. Description

*maketests* performs black-box, system tests based on lightweight configuration
and input-output files. Current features include printing a descriptive colored
diffs of failed tests and returning a non-zero status code at the end of make
process if any of the tests has failed. 

## 4. Installation

### 4.1. `make tests` running

There are several ways to incorporate *maketests* in your own project.

You can `include` the source code inside your own `Makefile`.

For example, if you cloned the git repository to `maketests` directory, you can
then `include` the source code like this:

```make
include maketests/tests.mk
```

`make tests` command is then available from within your `Makefile` directory.

Another option is to rename `tests.mk` to recognisable `Makefile` or
`GNUmakefile` and then modify it.

After installing *maketests* you should be able to perform `make tests` command
from an apropriate directory.

If you are creating a complex build process, you can `make tests` from within
any makefile recipe like this:

```make
build:
    @echo 'Make...'
    make
    @echo 'Make tests...'
    make tests --silent
```

Use `--silent` option to avoid unnecessary output such as working directory
changes.

### 4.2. Parameters

*maketests* needs some parameters. You can read about them
by running `make tests_help`:

```
In order to `make tests', set up following variables:
 TEXEC                   target executable

Optional parameters (with default values)
 TDDIR=tests             tests default dir
 TPARAMS="[INPUT_FILE]"  executable params for all tests
 TINPUT=TDDIR            input files root directory
 TOUTPUT=TDDIR           expected outputs root directory
 TACTUAL=TDDIR           actual outputs root directory
 TIN=.in                 test input extension (start with dot if present)
 TOUT=.out               expected outputs extension
 TACT=.act               actual outputs extension
```

Parameters should have been defined just before *maketests* source code,
for example:

```make
TEXEC=./myexecutable
TDDIR=tests/system
include maketests/tests.mk
```

### 4.3. Aliases

Default value of `TPARAMS` parameter is `[INPUT_FILE]` -- this
is actually an alias, which will be dynamically replaced with input file name
when running tests. That means for example `TPARAMS=-i [INPUT_FILE]`
with `test1.in` and `test2.in` input files will run executable two times with
parameters `-i test1.in` and `-i test2.in`. Aliases are available only in
`TPARAMS` parameter. You can read about them by running `make tests_help`:

```
Available TPARAMS aliases with their meanings (see README.md):
 [INPUT_FILE]            full test input file name
 [FILE_STEM]             test input/output file stem (name without extension)
```

`[FILE_STEM]` makes available to pass any input twin file, especially
output file, for example: `TPARAMS=-i [INPUT_FILE] -o [FILE_STEM].out`.

## 5. License

Copyright Konrad Talik <konrad.talik@slimak.matinf.uj.edu.pl>

This software is free; you can redistribute it and/or modify it under the terms
of the GNU General Public License as published by the Free Software Foundation;
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation,
Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
