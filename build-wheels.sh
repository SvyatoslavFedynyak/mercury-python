#!/bin/bash

set -x

# docker run --rm -v /home/ubuntu/mercury-transition-clean:/mercury:rw quay.io/pypa/manylinux_2_28_x86_64:latest /mercury/src/cython/build-wheels.sh

PYBIN=/usr/bin/python3

function repair_wheel {
    wheel=$1
    plat=$2
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$plat" -w $MERCURY_DIR/src/cython/wheelhouse/
    fi
}

# Install a system package required by our library
#yum install -y openssl-devel make zlib-devel

# configure and make mercury
#cd $MERCURY_DIR
#make clean
#./configure
#make
#cd -

# set environment variables
FLAGS='-DSSLNEW'
export ENV_CFLAGS=${FLAGS}

# Compile wheels
for PIPBIN in /usr/bin/pip[2-3].*; do
    # clean up cython directory
    cd $MERCURY_DIR/src/cython
    make clean
    rm -r mercury_python.egg-info/
    rm -r build/
    cd -

    $PIPBIN install -r $MERCURY_DIR/src/cython/requirements.txt
    $PIPBIN wheel $MERCURY_DIR/src/cython/ --no-deps -w $MERCURY_DIR/src/cython/wheelhouse/ --only-binary “:all:”
done

# Bundle external shared libraries into the wheels
for whl in $MERCURY_DIR/src/cython/wheelhouse/*.whl; do
    repair_wheel "$whl" $1
done
