# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python3_4 )

inherit distutils-r1 git-r3

DESCRIPTION="MozLz4a compression/decompression utility."
HOMEPAGE="https://gist.github.com/Tblue/62ff47bef7f894e92ed5"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/lz4"
RDEPEND="${DEPEND}"

EGIT_REPO_URI="https://gist.github.com/62ff47bef7f894e92ed5.git"
EGIT_COMMIT="2483756c55ed34be565aea269f05bd5eeb6b0a33"

src_prepare() {
	epatch "${FILESDIR}/${PV}-setuptools-entrypoint.patch"
	mkdir "${WORKDIR}/${P}/mozlz4a"
	mv "${WORKDIR}/${P}/mozlz4a.py" "${WORKDIR}/${P}/mozlz4a/__init__.py"
	cp "${FILESDIR}/setup.py" "${WORKDIR}/${P}/"
}
