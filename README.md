GWpySoft
========

GWpySoft is the stack of software including [GWpy](//github.com/gwpy/gwpy), [GWSumm](//github.com/gwpy/gwsumm) and [GWpy-VET](//github.com/gwpy/vet), and all dependencies (critically [numpy](http://numpy.org), [scipy](//scipy.org), [astropy](http://astropy.org), and [matplotlib](http://matplotlib.org)).

This repository provides simple scripts to set up a [virtualenv](//virtualenv.pypa.io/) containing those packages, mainly for use on the LIGO Data Grid.

Installation
------------

To install the stack, first clone the repository 
 
```bash
git clone https://github.com/gwpy/gwpysoft
cd gwpysoft
```
then run the [`gwpysoft-init`](//github.com/gwpy/gwpysoft/blob/master/gwpysoft-init) script to generate a new virtualenv

```bash
./gwpysoft-init <target-dir> ./packages.txt
```

The first argument (`<target-dir>`, e.g. `${HOME}/opt/gwpysoft`) is the target directory for the virtualenv, and can be anywhere you want.
The second argument (`./packages.txt`) is a plaintext file containing the list of packages you want; the format is that of a [pip requirements file](//pip.readthedocs.io/en/stable/user_guide/#requirements-files).

Then the virtualenv can be activated by

```
. <target-dir>/bin/activate
```

Gotchas
-------

### Basemap

The `gwpysoft-init` script will also try to install the matplotlib [basemap toolkit](//matplotlib.org/basemap/) (only if matplotlib itself was installed).
This is mainly because if you install a custom version of numpy (which in general will be true), basemap needs `geos` to be recompiled against it.

### MKL

If you have an installation of the Intel MKL (i.e. if `icc` is on the `PATH`), `gwpysoft-init` will try to build MKL-compiled versions of numpy and scipy.
These will be installed under `<target-dir>-mkl` (e.g. `${HOME}/opt/gwpysoft-mkl`) and a bash environment script will be installed under `<target-dir>-mkl/etc`.
