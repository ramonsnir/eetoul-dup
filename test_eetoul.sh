#!/bin/bash

set -e

export MIX_ENV="test"
export LIBRARY_PATH="/opt/libgit2/lib:/usr/lib/erlang/lib"
export LD_LIBRARY_PATH="/opt/libgit2/lib:/usr/lib/erlang/lib"
export C_INCLUDE_PATH="/opt/libgit2/include:/usr/lib/erlang/usr/include"

cd /opt
wget https://github.com/ramonsnir/eetoul/archive/master.zip
unzip master.zip
mv eetoul-master eetoul
cd eetoul
mkdir deps
git clone https://github.com/ramonsnir/geef.git deps/geef
cd deps/geef
make
mix
cd -

yes Y | mix do deps.get, deps.compile, compile
mix test
