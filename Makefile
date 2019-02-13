# OpenWRT/LEDE Makefile of https://github.com/shadowsocksrr/shadowsocksr-libev

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocksr-libev
PKG_VERSION:=2018-11-21
PKG_RELEASE:=ed6c9eb12530a7ecbdf3f5801fe59b177fe74779

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.gz
PKG_SOURCE_URL:=https://github.com/smaller09/shadowsocksr-libev.git
PKG_SOURCE_VERSION:=$(PKG_RELEASE)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=smaller09

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=openssl pcre

PKG_CONFIG_DEPENDS:= \
	CONFIG_SHADOWSOCKSR_STATIC_LINK \
	CONFIG_SHADOWSOCKSR_WITH_PCRE \
	CONFIG_SHADOWSOCKSR_WITH_OPENSSL

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocksr-libev/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy
	URL:=https://github.com/shadowsocksrr/shadowsocksr-libev
	DEPENDS:=+zlib +libpthread \
		+!SHADOWSOCKSR_WITH_PCRE:libpcre \
		+!SHADOWSOCKSR_WITH_OPENSSL:libopenssl \
		+!SHADOWSOCKSR_WITH_SODIUM:libsodium
endef

Package/shadowsocksr-libev = $(call Package/shadowsocksr-libev/Default)

define Package/shadowsocksr-libev/config
menu "Shadowsocksr-libev Compile Configuration"
	depends on PACKAGE_shadowsocksr-libev
	config SHADOWSOCKSR_STATIC_LINK
		bool "enable static link libraries."
		default n

		menu "Select libraries"
			depends on SHADOWSOCKSR_STATIC_LINK
			config SHADOWSOCKSR_WITH_PCRE
				bool "static link libpcre."
				default y
			config SHADOWSOCKSR_WITH_OPENSSL
				bool "static link libopenssl."
				default y
		endmenu
endmenu
endef

define Package/shadowsocksr-libev/description
shadowsocksr-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert

ifeq ($(CONFIG_SHADOWSOCKSR_STATIC_LINK),y)
	ifeq ($(CONFIG_SHADOWSOCKSR_WITH_PCRE),y)
		CONFIGURE_ARGS += --with-pcre="$(STAGING_DIR)/usr"
	endif
	ifeq ($(CONFIG_SHADOWSOCKSR_WITH_MBEDTLS),y)
		CONFIGURE_ARGS += --with-mbedtls="$(STAGING_DIR)/usr"
	endif
	CONFIGURE_ARGS += LDFLAGS="-Wl,-static -static -static-libgcc"
endif
define Package/shadowsocksr-libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
	$(LN) ssr-local $(1)/usr/bin/ssr-tunnel
endef

$(eval $(call BuildPackage,shadowsocksr-libev))
