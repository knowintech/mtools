linux 交叉编译mtools和测试过程
1. 编译工程前首先搭建好NDK交叉编译环境，
### 编译工具链
  
使用`Android NDK`工具来交叉编译目标应用。
代码目录里的`build_toolchain.sh`脚本用于下载NDK工具，并生成`standalone`交叉工具链。
以arm32为例介绍编译过程
2. 如果工具链搭建OK clone mtools 项目到 工具链standalone_toolchains32 同级目录
   git clone git@github.com:knowintech/mtools.git
   布局 如下：
   standalone_toolchains32
   mtools
   然后进入mtools 目录
   cd mtools
   执行 build_32mtools.sh
   即可执行编译
3. push msend 到 insight
   adb push msend /system/bin
4. 到insight 中执行msend
   adb shell
   cd /system/bin
   发送测试报文
  ./msend -g 224.0.0.251 -p 5354
   在同一局域网中的其它节点执行 
   sudo tcpdump -i eno1 dst port 5354
   接收报文
