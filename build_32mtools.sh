#!/bin/bash
compiler_path=""
NDK_MIX_VER="13"
NDK_VER_1_8="18"
NDK_SUPPORT_GCC="17"
DEST_GCC=""
DEST_LD=""
DEST_CFLAGS=""
DEST_LDFALG=""
#DEST_LOCAL_CFLAG+="-pie -fPIE"
#export LOCAL_CFLAGS+="-pie -fPIE"
#export LOCAL_LDFLAGS+="-pie -fPIE"

function get_ndk_version()
{
    version_file="${ANDROID_NDK}/source.properties"
    if [ -n $version_file ]; then
        version=$(string=`cat ${version_file} | grep Pkg.Revisio`; var=${string#*=};echo ${var%%.*})
        echo $version
        return 0
    fi

    return -1
}

function find_platform_max_ver()
{
    max="0"
    ver=""
    for tmp in `ls ${ANDROID_NDK}/platforms| grep android`
    do
         ver=${tmp#*-}
         if [ "$ver" -gt "$max" ]; then
            max=$ver
         fi
    done
    echo $max
}

function get_platform_version()
{
    meta_file="${ANDROID_NDK}/meta/platforms.json"
    if [ -f $meta_file ]; then
        version=$(string=`cat ${meta_file} | grep max`; var=${string#*:};echo ${var%%,*})
    else
        version=$(find_platform_max_ver)
    fi

    if [ -n "$version" ]; then
        echo "$version"
        return 0
    else
        echo "failed to get platmorm version,please check file path "
    fi

     return -1
}

function set_compiler_clang()
{
	pform_version=$(get_platform_version)
	if [ -z $pform_version ]; then
		echo "failed set compiler clang"
		return -1
	fi
    compiler_path="${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin"
    DEST_GCC="armv7a-linux-androideabi${pform_version}-clang"
    export PATH="${compiler_path}:${PATH}"
    return 0
}

function set_compiler_standalone()
{
	pform_version=$(get_platform_version)
    if [ -z $pform_version ]; then
        echo "failed set compiler standalone"
        return -1
    fi

	if [ ! -d "${ANDROID_NDK}/standalone_toolchains32" ]; then
        echo "creating cross compilation tool chains"
    	${ANDROID_NDK}/build/tools/make_standalone_toolchain.py --arch arm --api $pform_version --install-dir ${ANDROID_NDK}/standalone_toolchains32 --force
        echo "finished creating cross compile tool chains"
	fi
	
    if [ $? -ne 0 ]; then
        echo "failed to check ndk env var"
        return -1
    fi
	compiler_path="${ANDROID_NDK}/standalone_toolchains32/bin"
	DEST_GCC=arm-linux-androideabi-gcc
    ndk_version=$(get_ndk_version)
    
    if [ $ndk_version -lt $NDK_VER_1_8 ]; then
        DEST_CFLAGS+="-pie -fPIE"
    fi

	export PATH=${ANDROID_NDK}/standalone_toolchains32/bin/:$PATH
	return 0
}

function set_compiler()
{
    ndk_version=$(get_ndk_version)
    pform_version=$(get_platform_version)
    if [[ -n $ndk_version && -n $pform_version ]]; then
        if [ $ndk_version -gt $NDK_VER_1_8 ]; then  
            set_compiler_clang
        else
            set_compiler_standalone
        fi
    else
            echo "failed to set compiler."
            return -1
    fi

    return $?
}


function check_env_var()
{
    if [ ! -d "$ANDROID_NDK" ]; then
        echo "please set env var ANDROID_NDK for ndk root directory"
        return -1
    fi

    if [ ! -d "${ANDROID_NDK}/toolchains" ]; then
        echo "env var  ANDROID_NDK is set wrong directory, e.g. /opt/ndk/android-ndk-r21"
        return -1
    fi

    return 0
}

function check_toolchains()
{
    compiler="${compiler_path}/${DEST_GCC}"
    if [ ! -f "$compiler" ]; then
        echo "ndk compiler does not exsit, please check ndk version or path ${compiler}"
        return -1
    fi

    return 0
}

function check_ndk_version()
{
    ver=$(get_ndk_version)
    if [ "$ver" -lt "$NDK_MIX_VER" ]; then
        echo "ndk version must be greater or equal than $NDK_MIX_VER"
        return -1
    fi

    return 0
}

function env_valid_check()
{
    check_env_var
    if [ $? -ne 0 ]; then
        echo "failed to check ndk env var"
        return -1
    fi
    
    check_ndk_version
    if [ $? -ne 0 ]; then
         echo "failed to check ndk version"
         return -1
    fi
    
    set_compiler
    if [ $? -ne 0 ]; then
        echo "failed to check ndk version"
        return -1
    else
        check_toolchains
        if [ $? -ne 0 ]; then
            echo "failed to check ndk build tool chains"
            return -1
        fi
    fi

    return 0
}

function make_mtools()
{
    make clean
    make CC=$DEST_GCC CFLAGS="$DEST_CFLAGS"  LD="$DEST_LD" LDFLAGS="$DEST_LDFALG"
}


# main function, build mtools project
function build_32mtools()
{
    env_valid_check
    if [ $? -eq 0 ]; then
        make_mtools
    fi
}


if [ -n "$1" ]; then
   echo "help:"
   echo "   please set env var ANDROID_NDK for NDK root directory first"
   echo "   e.g. export ANDROID_NDK="/opt/ndk/android-ndk-r21""
   echo "   and run ./build_32mtools.sh"
   exit 0
fi

build_32mtools

