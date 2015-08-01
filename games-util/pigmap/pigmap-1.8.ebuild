# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3

DESCRIPTION=""
HOMEPAGE=""
EGIT_REPO_URI="https://github.com/akudeukie/${PN}"

LICENSE="GPL-3"
SLOT="1.8"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sys-libs/zlib
	media-libs/libpng
	media-libs/libjpeg-turbo"
RDEPEND="${DEPEND}"

function fetch() {
	git-r3_fetch ${EGIT_REPO_URI} refs/tags/v${PN}
}

function src_install() {
	dobin pigmap
	dodoc README COPYING
	insinto /usr/share/${PN}
	doins template.html blockdescriptor.list blocktextures.list style.css
	insinto /usr/share/${PN}/textures/entity
	doins textures/entity/end_portal.png
}
