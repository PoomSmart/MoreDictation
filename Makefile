SDKVERSION = 7.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk
TWEAK_NAME = MoreDictation
MoreDictation_FILES = Tweak.xm
MoreDictation_PRIVATE_FRAMEWORKS = AssistantServices

include $(THEOS_MAKE_PATH)/tweak.mk
