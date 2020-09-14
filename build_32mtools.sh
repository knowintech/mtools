
export PATH=$(pwd)/../standalone_toolchains32/bin/:$PATH

DEST_GCC=arm-linux-androideabi-gcc
DEST_AR=arm-linux-androideabi-ar
DEST_RANLIB=arm-linux-androideabi-ranlib
DEST_STRIP=arm-linux-androideabi-strip

DEST_HOST=arm-linux-androideabi
DEST_TARGET=arm-linux

make clean
make CC=$DEST_GCC CXX=$DEST_CXX 

