#!/bin/bash -e
#
# Set up a new python virtualenv for the GWpy software stack

# get name
target=$1
[[ -z ${target} ]] && target=${HOME}/opt/gwpysoft
packagefile=$2

# -- install dependencies for virtualenv itself
# get python version
if [[ -z ${PYTHON_VERSION} ]]; then
    PYTHON_VERSION=`python -c '
import sys;
print(".".join(map(str, sys.version_info[:2])))'`
fi
if [[ -z ${PYTHON_USER_BASE} ]]; then
    PYTHON_USER_BASE=`python -c 'import site; print(site.USER_BASE)'`
fi
if [[ -z ${PYTHON_USER_SITE} ]]; then
    PYTHON_USER_SITE=`python -c 'import site; print(site.USER_SITE)'`
fi
# create local directories
mkdir -p ${PYTHON_USER_BASE} 1>/dev/null
# install pip

which pip &>/dev/null || easy_install --prefix=${PYTHON_USER_BASE} pip
# install virtualenv
pip install "virtualenv>=13.0" --user --quiet
echo "Virtualenv is now installed"

# -- create virtualenv
virtualenv $target --system-site-packages --clear
. $target/bin/activate

# install dependencies
if [[ -f ${packagefile} ]]; then
    while read package; do
        pip install $package
    done < $packagefile
fi
