# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Robb Wagoner (robb.wagoner@protonmail.com)
#
# ORIGIN: https://forum.libreelec.tv/thread/21568-add-mdadm/
PKG_NAME="mdadm"
PKG_LONGDESC="mdadm is a tool for managing Linux Software RAID arrays."
PKG_MAINTAINER="robb.wagoner@protonmail.com"

PKG_VERSION="4.4"
PKG_SHA256="680fed532857088e0cd87c56c00033ae35eae0a3f9cb7e1523b345ba8717fb93"
PKG_ARCH="any"
PKG_LICENSE="LGPLv2"
PKG_SITE="https://raid.wiki.kernel.org/index.php/A_guide_to_mdadm"
PKG_URL="https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git/snapshot/mdadm-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd smartmontools"
PKG_TOOLCHAIN="manual"

make_target(){
  make SYSCONFDIR=/storage/.config CC=$CC CWFLAGS=
}

makeinstall_target(){
  BINDIR=/usr/sbin

  # mkdir -p ${INSTALL}/usr/sbin/
  install -D -m 755 mdadm ${INSTALL}/usr/sbin/mdadm
  install -D -m 755 mdmon ${INSTALL}/usr/sbin/mdmon
    # cp mdmon ${INSTALL}/usr/sbin/mdmon

  mkdir -p ${INSTALL}/usr/share/mdadm ${INSTALL}/var/lib/mdcheck
    install -D -m 755 misc/mdcheck ${INSTALL}/usr/share/mdcheck

  make install-udev DESTDIR=${INSTALL} BINDIR=/usr/sbin
  make install-systemd DESTDIR=${INSTALL} SYSTEMD_DIR=/usr/lib/systemd/system BINDIR=/usr/sbin
}

post_makeinstall_target() {
  install -D -m 644 ${PKG_DIR}/mdadm.conf ${INSTALL}/usr/config/mdadm.conf
  install -D -m 644 ${PKG_DIR}/kodi_notify.env ${INSTALL}/usr/config/kodi_notify.env
  install -D -m 755 ${PKG_DIR}/kodi-notify.sh ${INSTALL}/usr/bin/kodi-notify.sh
  install -D -m 755 ${PKG_DIR}/mdadm-notify.sh ${INSTALL}/usr/bin/mdadm-notify.sh
  install -D -m 755 ${PKG_DIR}/mount-md-device.sh ${INSTALL}/usr/bin/mount-md-device.sh
  install -D -m 644 ${PKG_DIR}/udev/rules.d/md-mount.rules ${INSTALL}/usr/lib/udev/rules.d/99-md-mount.rules
}

post_install() {
  enable_service mdmon@.service
  enable_service mdmonitor.service
}
