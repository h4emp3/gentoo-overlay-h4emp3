# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION="Tidy the layout and correct errors in HTML(5) and XML documents"
HOMEPAGE="http://www.html-tidy.org/"
EGIT_REPO_URI="https://github.com/htacg/tidy-html5"
EGIT_COMMIT="5.1.9"

LICENSE="W3C Software Notice and License"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="debug doc static-libs"

DEPEND=">=dev-util/cmake-2.8.8
	doc? ( app-doc/doxygen )"
RDEPEND="!!app-text/htmltidy"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with debug)
		$(cmake-utils_use_with static-libs static)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	if use doc; then
		doxygen documentation/doxygen.cfg || die "error creating apidocs"
	fi
}

src_install() {
	cmake-utils_src_install
	use doc && dohtml -r documentation/api
}
