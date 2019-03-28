DEBUG = 1
#iphone的ip地址
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
# SDKVERSION=10.3 
# SYSROOT = $(THEOS)/sdks/iPhoneOS10.3.sdk
ARCHS = arm64
#支持的ios版本
TARGET = iphone::10.3:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatBot

WeChatBot_CFLAGS = -fobjc-arc #-D__APPLE__=1 -D__cplusplus=1

#头文件
WeChatBot_OBJCFLAGS += -I./WeChatBot/Headers/wechatHeaders/ 
WeChatBot_OBJCFLAGS += -I./WeChatBot/Headers/ -I/opt/theos/include -I/opt/theos/vendor/include -I/opt/theos/include/_fallback -include /opt/theos/Prefix.pch

#导入系统的framework
WeChatBot_FRAMEWORKS = Foundation UIKit

#导入系统静态库
# WeChatBot_LDFLAGS += -lc++ -l
WeChatBot_LIBRARIES = substrate stdc++ c++
WeChatBot_CXXFLAGS = -std=c++11 -stdlib=libc++
export ADDITIONAL_CPPFLAGS +=  -std=c++11

#编译的实现文件
WeChatBot_FILES = Tweak.xmi WeChatBot/Classes/WBMsgManager.mm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
