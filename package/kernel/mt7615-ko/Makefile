include $(TOPDIR)/rules.mk
include $(TOPDIR)/include/version.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mt7615-ko
PKG_VERSION:=5.0.3.0
PKG_RELEASE:=1
PERFIX:=.
include $(INCLUDE_DIR)/package.mk

define Package/mt7615-ko/Default
  CATEGORY:=Ralink
  TITLE:=Ralink MT7615 AP driver
  DEPENDS:=+libuci
  FILES:=$(PKG_BUILD_DIR)/mt_wifi_ap/mt_wifi.ko
  AUTOLOAD:=$(call AutoLoad,91,mt_wifi)
endef

Package/mt7615-ko = $(Package/mt7615-ko/Default)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef
Build/Compile = $(Build/Compile/Default)

INSTALL_VARIANT:=install-overlay

define Package/mt7615-ko/$(INSTALL_VARIANT)
	$(CP) -r ./files/* $(1)/
endef

$(eval $(call BuildPackage,mt7615-ko))
