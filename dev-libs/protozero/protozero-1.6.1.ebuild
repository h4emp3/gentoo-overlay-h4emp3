# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3 cmake-utils

DESCRIPTION="Minimalist protocol buffer decoder and encoder in C++"
HOMEPAGE="https://github.com/mapbox/protozero"
EGIT_REPO_URI="https://github.com/mapbox/protozero"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-util/cmake-3.9.6
	"
RDEPEND="${DEPEND}"
