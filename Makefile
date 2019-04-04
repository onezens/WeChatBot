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
WeChatBot_OBJCFLAGS +=  -Wno-deprecated-declarations

#编译的实现文件
WeChatBot_FILES = Tweak.xmi
WeChatBot_FILES += $(wildcard WeChatBot/Classes/*.mm) $(wildcard WeChatBot/Classes/*/*.mm)
WeChatBot_FILES += $(wildcard WeChatBot/Classes/*.m) $(wildcard WeChatBot/Classes/*/*.m)

#导入系统的frameworks
WeChatBot_FRAMEWORKS = Foundation UIKit

#导入系统静态库
WeChatBot_LIBRARIES = stdc++ c++

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
