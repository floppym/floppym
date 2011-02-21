# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/rb_libtorrent/rb_libtorrent-0.15.4.ebuild,v 1.6 2010/12/09 19:35:18 xmw Exp $

EAPI="2"
PYTHON_DEPEND="python? 2:2.4"
PYTHON_USE_WITH="threads"
PYTHON_USE_WITH_OPT="python"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"
inherit eutils python versionator

MY_P=${P/rb_/}
MY_P=${MY_P/torrent/torrent-rasterbar}
S=${WORKDIR}/${MY_P}

DESCRIPTION="C++ BitTorrent implementation focusing on efficiency and scalability"
HOMEPAGE="http://www.rasterbar.com/products/libtorrent/"
SRC_URI="http://libtorrent.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc examples python ssl"
RESTRICT="test"

DEPEND="|| ( >=dev-libs/boost-1.35
		( ~dev-libs/boost-1.34.1 dev-cpp/asio ) )
	python? ( >=dev-libs/boost-1.35.0-r5[python] )
	>=sys-devel/libtool-2.2
	sys-libs/zlib
	examples? ( !net-p2p/mldonkey )
	ssl? ( dev-libs/openssl )"

RDEPEND="${DEPEND}"

src_configure() {
	# use multi-threading versions of boost libs
	local BOOST_LIBS="--with-boost-system=boost_system-mt \
		--with-boost-filesystem=boost_filesystem-mt \
		--with-boost-thread=boost_thread-mt \
		--with-boost-python=boost_python-mt"

	# detect boost version and location, bug 295474
	BOOST_PKG="$(best_version ">=dev-libs/boost-1.34.1")"
	BOOST_VER="$(get_version_component_range 1-2 "${BOOST_PKG/*boost-/}")"
	BOOST_VER="$(replace_all_version_separators _ "${BOOST_VER}")"
	BOOST_INC="/usr/include/boost-${BOOST_VER}"
	BOOST_LIB="/usr/$(get_libdir)/boost-${BOOST_VER}"

	local LOGGING
	use debug && LOGGING="--enable-logging=verbose"

	econf $(use_enable debug) \
		$(use_enable test tests) \
		$(use_enable examples) \
		$(use_enable python python-binding) \
		$(use_enable ssl encryption) \
		--with-zlib=system \
		${LOGGING} \
		--with-boost=${BOOST_INC} \
		--with-boost-libdir=${BOOST_LIB} \
		${BOOST_LIBS}

	# Python bindings are built/tested/installed manually.
	sed -e "/SUBDIRS =/s/ python//" -i bindings/Makefile || die
}

src_compile() {
	default

	if use python ; then
		python_copy_sources bindings/python
		building() {
			# Override paths stored in bindings/python-${PYTHON_ABI}/Makefile
			# files by 'configure'.
			emake PYTHON="$(PYTHON)" \
				PYTHON_INCLUDEDIR="$(python_get_includedir)" \
				PYTHON_LIBDIR="$(python_get_libdir)" || die
		}
		python_execute_function -s --source-dir bindings/python building
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die 'emake install failed'
	dodoc ChangeLog AUTHORS NEWS README || die 'dodoc failed'
	if use doc ; then
		dohtml docs/* || die "Could not install HTML documentation"
	fi
	if use python ; then
		installing() {
			emake PYTHON="$(PYTHON)" \
				PYTHON_INCLUDEDIR="$(python_get_includedir)" \
				PYTHON_LIBDIR="$(python_get_libdir)" \
				DESTDIR="${D}" install || die
		}
		python_execute_function -s --source-dir bindings/python installing
	fi
}