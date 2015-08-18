#!/bin/bash -e

package=$1
. ~/opt/gwpysoft/bin/activate
# uninstall
pip uninstall $package --yes
# install new version from git
pip install --quiet git+https://github.com/gwpy/$package.git
deactivate
