TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = RedditApp Reddit

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RedditFilter

$(TWEAK_NAME)_FILES = Tweak.x FilterSettingsViewController.x Settings.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Iinclude

include $(THEOS_MAKE_PATH)/tweak.mk
