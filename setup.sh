#!/bin/bash

MC_SETUP=1
. "`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`/include/environment.sh"

git submodule init
git submodule update || exit $?

#pushd "$MC_S3CMD_FOLDER"
s3cmd --configure  || exit $?
#popd

