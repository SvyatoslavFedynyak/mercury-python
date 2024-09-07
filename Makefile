# Makefile for cython interface to mercury
#

openssl_newer = yes
is_macos_arm = yes

ifeq ($(openssl_newer),yes)
	FLAGS = -DSSLNEW
endif

ifeq ($(is_macos_arm),yes)
CFLAGS = -I/opt/homebrew/include ${CLFAGS}
CXXFLAGS = -I/opt/homebrew/include ${CXXFLAGS}
LDFLAGS += -L/opt/homebrew/lib ${LDFLAGS}
endif

UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
    FLAGS += -mmacos-version-min=10.13
endif

export ENV_CFLAGS=${FLAGS}

all:
	CC=g++ CXX=g++ python3 setup.py build_ext --inplace

wheel:
	CC=g++ CXX=g++ python3 setup.py bdist_wheel

clean:
	rm -f mercury.*.so mercury.cpp

# EOF
