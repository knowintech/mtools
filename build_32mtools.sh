
#export PATH=$(pwd)/../standalone_toolchains32/bin/:$PATH
export PATH=$ANDROID_NDK/android-ndk-r18b/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/:$PATH
echo $ANDROID_NDK
echo $PATH

DEST_GCC=aarch64-linux-android-gcc
DEST_AR=aarch64-linux-android-ar
DEST_RANLIB=aarch64-linux-android-ranlib
DEST_STRIP=aarch64-linux-android-strip

DEST_HOST=aarch64-linux-android
DEST_TARGET=aarch64-linux

make clean
make CC=$DEST_GCC CXX=$DEST_CXX 

