#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/target.mk

PKG_NAME:=musl
PKG_VERSION:=1.2.3
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://musl.libc.org/releases/
#PKG_HASH:=7d5b0b6062521e4627e099e4c9dc8248d32a30285e959b7eecaa780cf8cfd4a4

# wongsyrone: use git version
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=4100279825c17807bdabf1c128ba4e49a1dea406
PKG_MIRROR_HASH:=9801484185c71b61e1000740d1c60d23196b6d0939ec048bc872b1c30d07f73d
PKG_SOURCE_URL:=https://git.musl-libc.org/git/musl
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz

LIBC_SO_VERSION:=$(PKG_VERSION)
PATCH_DIR:=$(PATH_PREFIX)/patches

BUILD_DIR_HOST:=$(BUILD_DIR_TOOLCHAIN)
HOST_BUILD_PREFIX:=$(TOOLCHAIN_DIR)
HOST_BUILD_DIR:=$(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/hardening.mk

TARGET_CFLAGS:= $(filter-out -O%,$(TARGET_CFLAGS))
TARGET_CFLAGS+= $(if $(CONFIG_MUSL_DISABLE_CRYPT_SIZE_HACK),,-DCRYPT_SIZE_HACK)

MUSL_CONFIGURE:= \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	$(HOST_BUILD_DIR)/configure \
		--prefix=/ \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-gcc-wrapper \
		--enable-debug \
		--enable-optimize

define Host/Configure
	ln -snf $(PKG_NAME)-$(PKG_VERSION) $(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
	( cd $(HOST_BUILD_DIR); rm -f config.cache; \
		$(MUSL_CONFIGURE) \
	);
endef

define Host/Clean
	rm -rf \
		$(HOST_BUILD_DIR) \
		$(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME) \
		$(BUILD_DIR_TOOLCHAIN)/$(LIBC)-dev
endef
