# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/go/go-9999.ebuild,v 1.1 2012/05/15 18:11:26 williamh Exp $

EAPI=4

EHG_REPO_URI="https://go.googlecode.com/hg"

[[ ${PV} == 9999 ]] && vcs=mercurial

inherit $vcs bash-completion-r1 elisp-common eutils

if [[ ${PV} != 9999 ]]; then
	SRC_URI="http://go.googlecode.com/files/go${PV}.src.tar.gz"
	# Upstream only supports go on amd64, arm and x86 architectures.
	KEYWORDS="-* ~x86"
fi

DESCRIPTION="A concurrent garbage collected and typesafe programming language"
HOMEPAGE="http://www.golang.org"

LICENSE="BSD"
SLOT="0"
IUSE="bash-completion emacs vim-syntax zsh-completion"

if [[ ${PV} != 9999 ]]; then
	IUSE="${IUSE} pax_kernel"
	COMMON_DEPEND="pax_kernel? ( sys-apps/paxctl )"
fi

DEPEND="sys-apps/ed
	${COMMON_DEPEND}"
RDEPEND="bash-completion? ( app-shells/bash-completion )
	emacs? ( virtual/emacs )
	vim-syntax? ( app-editors/vim )
	zsh-completion? ( app-shells/zsh-completion )
	${COMMON_DEPEND}"

	# The go language stores binary data for packages in *.a files.
	# These are _NOT_ libraries, and should not be stripped.
STRIP_MASK="/usr/lib/go/pkg/linux*/*.a"

[[ ${PV} == 9999 ]] || S="${WORKDIR}"/go

export_settings()
{
	export HOST_EXTRA_CFLAGS="${CFLAGS}"
	export HOST_EXTRA_LDFLAGS="${LDFLAGS}"
	export GOROOT_FINAL=/usr/lib/go
	export GOROOT="$(pwd)"
	export GOBIN="${GOROOT}/bin"
}

src_prepare()
{
	if [[ ${PV} != 9999 ]]; then
		epatch "${FILESDIR}"/${P}-hardened.patch
	fi
}

src_compile()
{
	export_settings
	if [[ ${PV} != 9999 ]]; then
		use pax_kernel && opts="--pax-kernel"
	fi
	cd src
	./make.bash $opts
	cd ..

	if use emacs; then
		elisp-compile misc/emacs/*.el
	fi
}

src_test()
{
	export_settings
	cd src
	./run.bash --no-rebuild --banner
}

src_install()
{
	dobin bin/*
	dodoc AUTHORS CONTRIBUTORS PATENTS README

	dodir /usr/lib/go
	insinto /usr/lib/go

	# There is a known issue which requires the source tree to be installed [1].
	# Once this is fixed, we can consider using the doc use flag to control
	# installing the doc and src directories.
	# [1] http://code.google.com/p/go/issues/detail?id=2775
	doins -r doc lib pkg src

	if use bash-completion; then
		dobashcomp misc/bash/go
	fi

	if use emacs; then
		elisp-install ${PN} misc/emacs/*.el misc/emacs/*.elc
	fi

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles
		doins -r misc/vim/ftdetect
		doins -r misc/vim/ftplugin
		doins -r misc/vim/syntax
		doins -r misc/vim/plugin
		doins -r misc/vim/indent
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins misc/zsh/go
	fi

	fperms -R +x /usr/lib/go/pkg/tool
}

pkg_postinst()
{
	if use emacs; then
		elisp-site-regen
	fi

	# If the go tool sees a package file timestamped older than a dependancy it
	# will rebuild that file.  So, in order to stop go from rebuilding lots of
	# packages for every build we need to fix the timestamps.  The compiler and
	# linker are also checked - so we need to fix them too.
	ebegin "fixing timestamps to avoid unnecessary rebuilds"
	tref="usr/lib/go/pkg/*/runtime.a"
	find "${ROOT}"usr/lib/go/pkg -type f \
		-exec touch -r "${ROOT}"${tref} {} \;
	eend $?
}

pkg_postrm()
{
	if use emacs; then
		elisp-site-regen
	fi
}
