
if [ ! -d "$ANDROID_NDK" ]; then
	  echo "please set env var ANDROID_NDK for ndk directory"
	  exit 1
fi

export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/:$PATH

DEST_GCC=armv7a-linux-androideabi29-clang

make clean
make CC=$DEST_GCC 

