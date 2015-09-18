# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit subversion cmake-utils

DESCRIPTION="Control Panel for Ice1712 Audio Cards"
HOMEPAGE="https://code.google.com/p/mudita24/"
ESVN_REPO_URI="http://mudita24.googlecode.com/svn/trunk/mudita24"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="debug static-libs"

DEPEND=">=dev-util/cmake-2.6.2
	>=x11-libs/gtk+-2.20:2
	>=media-sound/alsa-tools-1.0.0[ice1712]"
RDEPEND=""

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with debug)
		$(cmake-utils_use_with static-libs static)
	)
	cmake-utils_src_configure
}
