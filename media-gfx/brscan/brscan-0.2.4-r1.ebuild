# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit unpacker

DESCRIPTION="Brother Sane Backend"
HOMEPAGE="https://support.brother.com/g/b/producttop.aspx?c=us&lang=en&prod=mfc3820cn_us"
SRC_URI="https://download.brother.com/welcome/dlf006633/${P}-0.amd64.deb"

LICENSE="BROTHER-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	unpack_deb "${P}-0.amd64.deb"
	mkdir -v "${S}"
	mv -v "${S%/*}/usr" "${S}"
}

src_install() {
	cp -R "${S}/usr" "${D}/" || die "Install failed!"
}
