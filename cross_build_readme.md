linux 交叉编译mtools和测试过程
1. 下载NDK并解压, 设置NDK环境变量(如果已经设置请忽略本过程) 
   wget -c https://dl.google.com/android/repository/android-ndk-r21-linux-x86_64.zip
   export ANDROID_NDK="/opt/android-ndk-r21"
   export PATH=$PATH:$ANDROID_NDK
  
2. clone mtools工程代码 
   git clone git@github.com:knowintech/mtools.git
   cd mtools
   执行 ./build_32mtools.sh
3. push msend mreceive  到 android 系统 比如 insight
   adb push msend /system/bin
4. 到insight 中执行msend
   adb shell
   cd /system/bin
   发送测试报文
  ./msend -g 224.0.0.251 -p 5354
   在同一局域网中的其它节点执行 
   sudo tcpdump -i eno1 dst port 5354
   接收报文

   注意： 只支持android-ndk-r13b 及以上版本
