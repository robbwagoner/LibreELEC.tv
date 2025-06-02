#
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Robb Wagoner (robb.wagoner@protonmail.com)
#
#
# https://github.com/LibreELEC/LibreELEC.tv/blob/master/packages/readme.md
#
PKG_NAME="xfsprogs"
PKG_LONGDESC="Utilities for managing the XFS filesystem."
PKG_MAINTAINER="robb.wagoner@protonmail.com"

PKG_VERSION="6.14.0"
PKG_SHA256="cf02933de20ef9bc349c445d7640cb3d3237e9e026b6df7429834ddc7e5211d4"
PKG_ARCH="any"
PKG_LICENSE="LGPLv2"
PKG_SITE="https://xfs.wiki.kernel.org/"
PKG_URL="https://git.kernel.org/pub/scm/fs/xfs/xfsprogs-dev.git/snapshot/xfsprogs-dev-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain libinih liburcu"
PKG_DEPENDS_CONFIG="libinih liburcu"
PKG_DEPENDS_HOST="toolchain:host"


make_target(){
	export LOCAL_CONFIGURE_OPTIONS="--localstatedir=/var --prefix=/usr --host=${TARGET_NAME}"
	cd "${PKG_BUILD}"
  make \
	 	INSTALL_USER=root \
    INSTALL_GROUP=root
}

post_makeinstall_target(){
	safe_remove ${INSTALL}/usr/share
}
