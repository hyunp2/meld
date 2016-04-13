#!/bin/bash

set -e

# Activate Holy Build Box environment
source /hbb_exe/activate

# Disable PYTHONPATH
unset PYTHONPATH

# install miniconda
curl -s -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /anaconda
PATH=/opt/rh/devtoolset-2/root/usr/bin:/opt/rh/autotools-latest/root/usr/bin:/anaconda/bin:$PATH
conda config --add channels omnia
conda install -yq conda-build jinja2 anaconda-client

# install aws
pip install awscli
yum install -y groff

# get the git revision for the version string
cd /io
export GIT_DESCRIBE=`git describe --tags --long | tr - .`
cd /

# build the meld conda package
conda-build --no-binstar-upload --python 2.7 --python 3.4 --python 3.5 /io/devtools/conda

# upload to anaconda.org
anaconda --token "$ANACONDA_TOKEN" upload --user maccallum_lab /anaconda/conda-bld/linux-64/meld*.bz2

# upload docs to S3
ls /anaconda
ls /anaconda/conda-bld
ls /anaconda/conda-bld/work
ls /anaconda/conda-bld/work/build
aws s3 sync --delete /anaconda/conda-bld/work/build/meld-api-c++/ s3://plugin-api.meldmd.org/
