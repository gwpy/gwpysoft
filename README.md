GWpySoft
========

GWpySoft is the stack of software including GWpy, GWSumm and GWpy-VET, and all dependencies.

This repository provides simple scripts to set up a virtualenv containing those packages, mainly for use on the LDG.

To install the stack, do
```
./gwpysoft-init ${HOME}/opt/gwpysoft ./packages.txt
```
Then the virtualenv can be activated by
```
source ${HOME}/opt/gwpysoft/bin/activate
```
