DEBUG = 1
#用于调试的设备地址
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = arm64

#用于编译的SDK和支持的ios最低版本
TARGET = iphone:11.2:9.0

include $(THEOS)/makefiles/common.mk

# 工程名称
TWEAK_NAME = WeChatBot

# 采用ARC内存管理
WeChatBot_CFLAGS = -fobjc-arc

#头文件
WeChatBot_OBJCFLAGS += -I./WeChatBot/Headers/wechatHeaders/ 
WeChatBot_OBJCFLAGS += -I./WeChatBot/Headers/

#忽略OC警告
WeChatBot_OBJCFLAGS +=  -Wno-deprecated-declarations -Wno-unused-variable

#编译的实现文件
WeChatBot_FILES = Tweak.xmi
WeChatBot_FILES += $(wildcard WeChatBot/Classes/*.mm) $(wildcard WeChatBot/Classes/*/*.mm)
WeChatBot_FILES += $(wildcard WeChatBot/Classes/*.m) $(wildcard WeChatBot/Classes/*/*.m)

#导入系统的frameworks
WeChatBot_FRAMEWORKS = Foundation UIKit

#导入系统库
WeChatBot_LIBRARIES = stdc++ c++

#导入第三方Frameworks, 动态库需特殊处理
WeChatBot_LDFLAGS += -F./Libraries/dynamic -F./Libraries/static   # 识别的库实现
WeChatBot_CFLAGS  += -F./Libraries/dynamic -F./Libraries/static   # 头文件识别
WeChatBot_FRAMEWORKS += WCBFWStatic WCBFWDynamic

#导入第三方lib
WeChatBot_LDFLAGS += -L./Libraries/dynamic -L./Libraries/static 	# 识别的库实现
WeChatBot_CFLAGS  += -I./Libraries/include  						# 头文件识别
WeChatBot_LIBRARIES += WCBStatic WCBDyLib 

include $(THEOS_MAKE_PATH)/tweak.mk

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

