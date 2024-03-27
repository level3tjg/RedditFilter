TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = RedditApp Reddit

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RedditFilter

$(TWEAK_NAME)_FILES = $(wildcard *.x*) fishhook/fishhook.c
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Iinclude -Wno-module-import-in-extern-c

include $(THEOS_MAKE_PATH)/tweak.mk
