# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit autotools eutils git-2 linux-mod

DESCRIPTION="Native ZFS for Linux"
HOMEPAGE="http://zfsonlinux.org/"
SRC_URI=""
EGIT_REPO_URI="git://github.com/zfsonlinux/zfs.git"

LICENSE="CDDL GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=sys-devel/spl-${PV}"
RDEPEND="!sys-fs/zfs-fuse"

pkg_setup() {
	CONFIG_CHECK="!PREEMPT !DEBUG_LOCK_ALLOC"
	kernel_is ge 2 6 32 || die "Linux 2.6.32 or newer required"
	check_extra_config
}

src_prepare() {
	AT_M4DIR="config"
	eautoreconf
}

src_configure() {
	set_arch_to_kernel
	econf \
		--with-config=all \
		--with-linux="${KV_DIR}" \
		--with-linux-obj="${KV_OUT}"
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}
