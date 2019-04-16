在创建一个逆向工程项目时，如何让工程使用起来更加便捷和易于扩展，以及编译器识别，能够大大提升我们日常的开发效率以及代码的质量。本文主要描述了，如果使用Theos的tweak工程，创建一个可以被Xcode编译器识别的项目工程，以及工程中常用的配置。

## 搭建逆向环境
https://www.jianshu.com/p/100e34a043e3

搭建好环境之后，创建对应的tweak工程项目

## 创建Xcode项目

根据前面创建好的tweak项目名称，创建一个Xcode静态库项目，然后将tweak和创建的Xcode项目混合到一起

![](https://upload-images.jianshu.io/upload_images/1216462-d602af3788b41a13.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


在Xcode项目里面创建一个Config文件夹（New Group Without Folder），将Makefile、对应的plist文件、control配置文件，不要copy放到此目录下。 然后在Xcode里面，创建对应的文件夹，然后将生成的`.xm`文件的后缀名，全部替换为`.xmi` ，并且放到项目的最外层，作为唯一的入口类

设置Tweak.xmi在Xcode编译器识别类型为`Objective-C++`

![](https://upload-images.jianshu.io/upload_images/1216462-e6a4fa8809716f16.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1216462-6b7965fe33f1717f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

设置XcodeTheos头文件，让编译器识别logos语法，对应的头文件的地址：[https://github.com/onezens/Xcode-Theos](https://github.com/onezens/Xcode-Theos)，导入项目之后，创建一个全局头文件，并且到该头文件放到`tweak.xmi`里面，发现里面的代码是黑色的，没有被编译器识别，这时候，关闭项目重新打开后发现会被Xcode重新识别了

接着设置`XcodeTheos`的宏，让Xcode识别logos宏
![](https://upload-images.jianshu.io/upload_images/1216462-e0e0023f295f139f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

一起设置好之后，开始写logos的hook代码，一切正常的话，你会发现Xcode写起logos代码超级顺畅，并且编译Xcode提示成功

![](https://upload-images.jianshu.io/upload_images/1216462-7fc24c32765286fa.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 将Xcode的配置和Makefile进行同步

**首先修改Makefile的编译文件**
在以后创建对应的logos语法的文件时，始终命名为xmi文件，并且写入Makefile里面

```
WeChatBot_FILES = Tweak.xm
=> 修改为：
WeChatBot_FILES = Tweak.xmi
```
**在项目中头文件引用路径问题，导致编译失败**

```
➜  WeChatBot git:(master) ✗ make
> Making all for tweak WeChatBot…
==> Preprocessing Tweak.xmi…
Tweak.xmi:2:9: fatal error: 'wechatbot-prefix-header.h' file not found
#import "wechatbot-prefix-header.h"
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~
1 error generated.
make[3]: *** [/Users/wz/Documents/GitHub/WeChatBot/.theos/obj/debug/armv7/Tweak.mii] Error 1
make[2]: *** [/Users/wz/Documents/GitHub/WeChatBot/.theos/obj/debug/armv7/WeChatBot.dylib] Error 2
make[1]: *** [internal-library-all_] Error 2
make: *** [WeChatBot.all.tweak.variables] Error 2
```
发现是头文件，引入的原因，Makefile里面设置头文件目录

```
#头文件
WeChatBot_OBJCFLAGS += -I./WeChatBot/Headers/wechatHeaders/ 
WeChatBot_OBJCFLAGS += -I./WeChatBot/Headers/
```
**如果使用最新版的theos，我们会发现编译`.xmi` 文件会包下面的错误**

```
➜  WeChatBot git:(master) ✗ make
> Making all for tweak WeChatBot…
==> Preprocessing Tweak.xmi…
==> Compiling Tweak.xmi (arm64)…
Tweak.xmi:18:104: error: use of undeclared identifier 'MSHookMessageEx'
{Class _logos_class$_ungrouped$MicroMessengerAppDelegate = objc_getClass("MicroMessengerAppDelegate"); MSHookMessageEx(_logos_class$_ungro...
                                                                                                       ^
1 error generated.
make[3]: *** [/Users/wz/Documents/GitHub/WeChatBot/.theos/obj/debug/arm64/Tweak.xmi.ca6fefe9.o] Error 1
make[2]: *** [/Users/wz/Documents/GitHub/WeChatBot/.theos/obj/debug/arm64/WeChatBot.dylib] Error 2
make[1]: *** [internal-library-all_] Error 2
make: *** [WeChatBot.all.tweak.variables] Error 2
```
解决办法：
1. 将所有的`.xmi`更改为`.xi`文件， 并且导入头文件 `#include <substrate.h>`
2. 使用老版本的theos: `https://github.com/onezens/theos.git` 替换原版进行编译


**解决编译警告，导致报错的问题**

```
➜  WeChatBot git:(master) ✗ make
> Making all for tweak WeChatBot…
==> Preprocessing Tweak.xmi…
==> Compiling Tweak.xmi (arm64)…
Tweak.xmi:8:4: error: 'UIAlertView' is deprecated: first deprecated in iOS 9.0 - UIAlertView is deprecated. Use UIAlertController with a preferredStyle
      of UIAlertControllerStyleAlert instead [-Werror,-Wdeprecated-declarations]
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Works for hook" message:__null delegate:__null cancelButtonTitle:@"cancel" otherBu...
   ^
/opt/theos/sdks/iPhoneOS11.2.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIAlertView.h:26:12: note: 'UIAlertView' has been explicitly marked
      deprecated here
@interface UIAlertView : UIView
           ^
Tweak.xmi:8:27: error: 'UIAlertView' is deprecated: first deprecated in iOS 9.0 - UIAlertView is deprecated. Use UIAlertController with a
      preferredStyle of UIAlertControllerStyleAlert instead [-Werror,-Wdeprecated-declarations]
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Works for hook" message:__null delegate:__null cancelButtonTitle:@"cancel" otherBu...
                          ^
/opt/theos/sdks/iPhoneOS11.2.sdk/System/Library/Frameworks/UIKit.framework/Headers/UIAlertView.h:26:12: note: 'UIAlertView' has been explicitly marked
      deprecated here
@interface UIAlertView : UIView
           ^
2 errors generated.
make[3]: *** [/Users/wz/Documents/GitHub/WeChatBot/.theos/obj/debug/arm64/Tweak.xmi.6c3ff448.o] Error 1
make[2]: *** [/Users/wz/Documents/GitHub/WeChatBot/.theos/obj/debug/arm64/WeChatBot.dylib] Error 2
make[1]: *** [internal-library-all_] Error 2
make: *** [WeChatBot.all.tweak.variables] Error 2
```
解决办法：
1. 将Makefile里面的版本号降低：`TARGET = iphone:11.2:7.0`
2. Makefile里面设置忽略方法过期警告：
 
```
#忽略OC警告
WeChatBot_OBJCFLAGS +=  -Wno-deprecated-declarations
```

## 项目中动态和静态库的配置

### 系统库

```
#导入系统的frameworks
WeChatBot_FRAMEWORKS = Foundation UIKit

#导入系统库
WeChatBot_LIBRARIES = stdc++ c++
```
### 配置第三库

```
#导入第三方Frameworks, 动态库需特殊处理
WeChatBot_LDFLAGS += -F./Libraries/dynamic -F./Libraries/static   # 识别的库实现
WeChatBot_CFLAGS  += -F./Libraries/dynamic -F./Libraries/static   # 头文件识别
WeChatBot_FRAMEWORKS += WCBFWStatic WCBFWDynamic

#导入第三方lib
WeChatBot_LDFLAGS += -L./Libraries/dynamic -L./Libraries/static 	# 识别的库实现
WeChatBot_CFLAGS  += -I./Libraries/include  						# 头文件识别
WeChatBot_LIBRARIES += WCBStatic WCBDyLib 
```

### 对应的本地文件夹说明
include 放置所有的.a和.dylib库的头文件
dynamic 放置所有的动态库的文件夹，动态库放一起，方便脚本处理
static 防止所有的静态库的文件夹

### 动态库问题
当我们把，动态库加入的项目中，我们发现运行我们的tweak插件，在宿主APP中不起作用，通过log提示信息为：

```
Apr 9 15:55:28 wz5 WeChat[5329] <Error>: MS:Error: dlopen(/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib, 9): Library not loaded: @rpath/WCBFWDynamic.framework/WCBFWDynamic
	  Referenced from: /Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib
	  Reason: image not found
```
该日志信息中可以看出，宿主在自己的bundle里面，没有加载到我们的动态库，所以导致我们整个插件的功能不生效

查看生成的动态库：

```
➜  WeChatBot git:(master) ✗ otool -L .theos/_/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib
.theos/_/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib:
	/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1450.14.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1450.14.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3698.33.6)
	@rpath/WCBFWDynamic.framework/WCBFWDynamic (compatibility version 1.0.0, current version 1.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.1)
	@rpath/libWCBDyLib.dylib (compatibility version 0.0.0, current version 0.0.0)
	/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.0.0)
```
我们发现tweak项目的动态库，依赖都是rpath，是宿主的bundle路径，所以我们要更改这个路径

解决办法，通过脚本,更改动态库依赖路径：

```
TWEAK_NAME=WeChatBot
cydiaLibPath=/Library/MobileSubstrate/DynamicLibraries/$TWEAK_NAME
dylibPath=Libraries/dynamic
oriDylibPath=$dylibPath/ori
tweakLayoutPath=layout$cydiaLibPath
echo $tweakLayoutPath
if [[ ! -d $oriDylibPath ]]; then
	mkdir $oriDylibPath
fi

if [[ ! -d $tweakLayoutPath ]]; then
	mkdir $tweakLayoutPath
fi

checkDylibID() {
	path=$1
	libFullPath=$2
	ckLibId=$(otool -L $path | grep rpath)
	if [[ -n $ckLibId ]]; then
		cp -r $libFullPath $oriDylibPath
		ckLibId=${ckLibId%' ('*}
		ckLibId=${ckLibId#*/}
		install_name_tool -id $cydiaLibPath/$ckLibId $path
		otool -L $path
	fi
	cp -r $libFullPath $tweakLayoutPath
}

for file in $dylibPath/*; do
	if [[ $file =~ ".dylib" ]]; then
		checkDylibID $file $file
	elif [[ $file =~ ".framework" ]]; then
		name=${file##*/}
		name=${name%.*}
		checkDylibID $file/$name $file
	fi
done
```

在每次package之前，运行此脚本，打包完成后查看信息：

```
➜  WeChatBot git:(master) ✗ otool -L .theos/_/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib
.theos/_/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib:
	/Library/MobileSubstrate/DynamicLibraries/WeChatBot.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1450.14.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1450.14.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3698.33.6)
	/Library/MobileSubstrate/DynamicLibraries/WeChatBot/WCBFWDynamic.framework/WCBFWDynamic (compatibility version 1.0.0, current version 1.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.1)
	/Library/MobileSubstrate/DynamicLibraries/WeChatBot/libWCBDyLib.dylib (compatibility version 0.0.0, current version 0.0.0)
	/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.0.0)
```



## 常用的编译命令配置

简化常用命令，提高日常开发效率

```
before-package::
	sh bin/check_dynamic_lib.sh  #动态库处理脚本
	cp ./bin/postinst .theos/_/DEBIAN/
	cp ./bin/postrm .theos/_/DEBIAN/
	chmod 755 .theos/_/DEBIAN/postinst
	chmod 755 .theos/_/DEBIAN/postrm
after-install::
	install.exec "killall -9 SpringBoard"
p::
	make package
c::
	make clean
i::
	make
	make p
	make install
```

## 常用的脚本说明

postinst 脚本是每次deb包安装之前执行的脚本
postrm 脚本是每次deb包安装完成后执行的脚本

注意：打包前需要修改这两个的执行权限

```
chmod 755 .theos/_/DEBIAN/postinst
chmod 755 .theos/_/DEBIAN/postrm
```
相关的脚本描述：[http://iphonedevwiki.net/index.php/Packaging](http://iphonedevwiki.net/index.php/Packaging)

**应用场景：在Cydia中安装插件，并且显示返回按钮**
postrm脚本 & 删除control的depend依赖：

```
#!/bin/bash
declare -a cydia
cydia=($CYDIA)
if [[ ${CYDIA+@} ]]; then
    eval "echo 'finish:open' >&${cydia[0]}"
else
    echo "uninstall wk completed!"
    echo ""
fi
killall -9 WeChat
exit 0
```

参数说明：

```
Acceptable parameters for finish
# return - normal behaviour (return to cydia)
# reopen - exit cydia
# restart - reload springboard
# reload - reload springboard
# reboot - reboot device
```

## 资源文件的导入

通过项目根目录中的layout目录，映射文件到手机设备当中，然后读取资源文件

```
#define kWCBImgSrcPath @"/Library/AppSupport/WeChatBot/imgs"

UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/wcb_icon.png", kWCBImgSrcPath]];
NSLog(@"[WeChatBot] img: %@", img);
UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
[imgView sizeToFit];
imgView.center = CGPointMake(46, 60);
[self.window addSubview:imgView];
```

## 其他配置说明

### Makefile

```
#用于编译的SDK和支持的ios最低版本
TARGET = iphone:11.2:9.0

#用于调试的设备地址
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

# 打包命名不一样，正式包不会输出log等
DEBUG = 1

# 采用ARC内存管理
WeChatBot_CFLAGS = -fobjc-arc

#忽略OC警告，避免警告导致编译不过
WeChatBot_OBJCFLAGS +=  -Wno-deprecated-declarations -Wno-unused-variable
```

### control 

```
Package: cc.onezen.wechatbot  #包名
Name: WeChatBot
Depends: mobilesubstrate   #依赖库和依赖插件，如果需要插件在cydia安装后不重启springboard可以删掉，否则每次重新
Version: 0.0.1
Architecture: iphoneos-arm
Description: An awesome MobileSubstrate tweak!
Maintainer: wz
Author: wz
Section: Tweaks #cydia源中的分类
Icon: file:///Library/AppSupport/WeChatBot/imgs/wcb_icon.png #icon
```
## 项目
git 地址: https://github.com/onezens/WeChatBot


