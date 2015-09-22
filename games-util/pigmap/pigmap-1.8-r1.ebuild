# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Fast Minecraft map generator"
HOMEPAGE="https://github.com/akudeukie/pigmap"
EGIT_REPO_URI="https://github.com/akudeukie/${PN}"
EGIT_COMMIT="v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="sys-libs/zlib
	media-libs/libpng:0
	media-libs/libjpeg-turbo"
RDEPEND="${DEPEND}"

function src_install() {
	dobin pigmap
	dodoc README
	insinto /usr/share/${PN}
	doins template.html blockdescriptor.list blocktextures.list style.css
	insinto /usr/share/${PN}/textures/entity
	doins textures/entity/end_portal.png
}
