#!/bin/bash
compiler_path=""
NDK_MIX_VER="18"
NDK_VER_1_8="18"
NDK_SUPPORT_GCC="17"
DEST_GCC=""
DEST_LD=""
DEST_CFLAGS=""
DEST_LDFALG=""


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

function get_platform_version()
{
     meta_file="${ANDROID_NDK}/meta/platforms.json"
     version=$(string=`cat ${meta_file} | grep max`; var=${string#*:};echo ${var%%,*})
     if [ -n "$version" ]; then
        echo "$version"
        return 0
     else
        echo "failed to get platmorm version,please check file path "
     fi

     return -1
}

function set_compiler()
{
    ndk_version=$(get_ndk_version)
    pform_version=$(get_platform_version)
    if [[ -n $ndk_version && -n $pform_version ]]; then
        if [ $ndk_version -gt $NDK_VER_1_8 ]; then  
            compiler_path="${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin"
            DEST_GCC="armv7a-linux-androideabi${pform_version}-clang"
        else
            echo "do not support this ndk version at present"
            return -1
        fi
    else
        echo "failed to set compiler"
        return -1
    fi

    export PATH="${compiler_path}:${PATH}"
    return 0
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
    echo "make CC=$DEST_GCC CFLAGS=$DEST_CFLAGS LDFLAGS=$DEST_LDFALG"
    make CC=$DEST_GCC CFLAGS="$DEST_CFLAGS" LD="$DEST_LD" LDFLAGS="$DEST_LDFALG"
}


function build_32mtools()
{
    env_valid_check
    if [ $? -eq 0 ]; then
        echo "${compiler_path}/${DEST_GCC}"
        make_mtools
    fi
}


# main function, build mtools project

build_32mtools
