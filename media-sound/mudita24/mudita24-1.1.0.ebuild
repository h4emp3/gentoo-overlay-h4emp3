# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION="Control tool for Envy24 (ice1712) based soundcards"
HOMEPAGE="https://github.com/NielsMayer/mudita24/"
EGIT_REPO_URI="https://github.com/NielsMayer/${PN}/"
EGIT_COMMIT="e38b1a39a8ca4f82b74d7b70bf9a3489e37b3588"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug static-libs"

DEPEND=">=dev-util/cmake-2.6.2
	>=x11-libs/gtk+-2.20:2
	>=media-sound/alsa-utils-1.0.0"
RDEPEND=""

src_prepare() {
	mv "${WORKDIR}/${P}/README" "${WORKDIR}/${P}/INFO"
	mv "${WORKDIR}/${P}/${PN}/"* "${WORKDIR}/${P}/"
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with debug)
		$(cmake-utils_use_with static-libs static)
	)
	cmake-utils_src_configure
}
