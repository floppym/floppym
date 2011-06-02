# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PERL_EXPORT_PHASE_FUNCTIONS=no
inherit perl-module

DESCRIPTION="SGML-based documentation formatting package used for the Debian manuals"
HOMEPAGE="http://packages.debian.org/sid/debiandoc-sgml"
SRC_URI="mirror://debian/pool/main/${P:0:1}/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	perl_set_version
	emake \
		DESTDIR="${D}" \
		prefix="${EPREFIX}/usr" \
		perl_dir="${ED}${VENDOR_LIB}" \
		install
}
