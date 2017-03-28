#!/bin/bash -e
#
# Library functions for managing a virtualenv for the GWpy software stack

find_pypi_version() {
    local package=$1
    local name=`echo $package | awk -F '[><=]' '{print $1}'`
    pip search $package | grep "^$name " | awk -F '[()]' '{print $2}'
}

pip_installed() {
    local piplist_="$TMPDIR/pip-list-$RANDOM.txt"
    pip list installed --local --format=columns > ${piplist_}
    grep -q $1 ${piplist_} && echo true || echo false
}

has_mkl() {
    [ -z ${MKLROOT} ] && echo false || echo true
}

# -- installers ---------------------------------------------------------------

install_package() {
    local package=$1
    local target=$2
    shift 2

    if `has_mkl` && [[ ${package} =~ ^numpy ]]; then
        install_mkl_numpy $package $target
    elif `has_mkl` && [[ ${package} =~ ^scipy ]]; then
        install_mkl_scipy $package $target
    elif [[ ${package} =~ ^(git\+https://git|https://git) ]]; then
        name=`basename $package`
        pip uninstall $name --yes --quiet || true
        pip install $package $@
    else
        pip install --quiet $package $@
    fi
    if [[ ${package} =~ ^matplotlib ]] && `pip_installed matplotlib`; then
        install_mpl_basemap $target
    fi
}


install_mkl_numpy() {
    local package=$1
    local target=$2

    if [[ ${package} =~ ^numpy== ]]; then
        NUMPY_VERSION=`echo $package | cut -d= -f3`
    else
        NUMPY_VERSION=`find_pypi_version $package`
    fi

    # install cython
    pip install --quiet Cython

    # download numpy source tarball for this version
    wget https://github.com/numpy/numpy/archive/v${NUMPY_VERSION}.tar.gz \
        --quiet --output-document numpy-${NUMPY_VERSION}.tar.gz
    tar -zxf numpy-${NUMPY_VERSION}.tar.gz
    rm -f ./numpy-${NUMPY_VERSION}.tar.gz
    cd numpy-${NUMPY_VERSION}

    # set MKL variables for build
    echo "[mkl]
library_dirs = ${MKLROOT}/lib/intel64/
include_dirs = ${MKLROOT}/include/
mkl_libs = mkl_rt
lapack_libs = 
" > site.cfg

    # replace openmp flag with qopenmp flag
    sed -i 's/-openmp/-qopenmp/g' numpy/distutils/intelccompiler.py
    sed -i 's/-openmp/-qopenmp/g' numpy/distutils/fcompiler/intel.py

    # build and install
    python setup.py --quiet \
        config --quiet --compiler=intelem --fcompiler=intelem \
        build_clib --quiet --compiler=intelem --fcompiler=intelem \
        build_ext --quiet --compiler=intelem --fcompiler=intelem \
        install --quiet --prefix $target
    cd - 1>/dev/null
    rm -rf numpy-${NUMPY_VERSION}/
}


install_mkl_scipy() {
    local package=$1
    local target=$2

    # get scipy version number
    if [[ ${package} =~ ^numpy== ]]; then
        SCIPY_VERSION=`echo $package | cut -d= -f3`
    else
        SCIPY_VERSION=`find_pypi_version $package`
    fi

    # download source tarball
    wget https://github.com/scipy/scipy/archive/v${SCIPY_VERSION}.tar.gz \
        --quiet --output-document scipy-${SCIPY_VERSION}.tar.gz
    tar -zxf scipy-${SCIPY_VERSION}.tar.gz
    rm -f ./scipy-${SCIPY_VERSION}.tar.gz
    cd scipy-${SCIPY_VERSION}

    # build and install
    python setup.py --quiet \
        config --quiet --compiler=intelem --fcompiler=intelem \
        build_clib --quiet --compiler=intelem --fcompiler=intelem \
        build_ext --quiet --compiler=intelem --fcompiler=intelem \
        install --quiet --prefix $target
    cd - 1>/dev/null
    rm -rf scipy-${SCIPY_VERSION}/
}


install_mpl_basemap() {
    # get basemap version from pypi.python.org
    BASEMAP_VERSION=`find_pypi_version basemap`

    # download source tarball
    wget http://downloads.sourceforge.net/project/matplotlib/matplotlib-toolkits/basemap-${BASEMAP_VERSION}/basemap-${BASEMAP_VERSION}.tar.gz \
        --quiet --output-document basemap-${BASEMAP_VERSION}.tar.gz
    tar -zxf basemap-${BASEMAP_VERSION}.tar.gz
    rm -f basemap-${BASEMAP_VERSION}.tar.gz
    cd basemap-${BASEMAP_VERSION}

    # build geos
    export GEOS_DIR=${target}
    cd geos-*
    ./configure --prefix=${GEOS_DIR} --quiet 1>/dev/null
    make 1> /dev/null
    make install 1> /dev/null

    # install basemap
    cd ../
    python setup.py --quiet install
    cd ../
    rm -rf basemap-1.0.7
}
