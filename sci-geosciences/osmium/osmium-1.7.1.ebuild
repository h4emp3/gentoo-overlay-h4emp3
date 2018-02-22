# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3 cmake-utils

DESCRIPTION="Command line tool for working with OSM data, based on Osmium."
HOMEPAGE="http://osmcode.org/osmium-tool/"
EGIT_REPO_URI="https://github.com/osmcode/osmium-tool/"
EGIT_COMMIT="v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

# TODO:
# - separate build and run deps properly

DEPEND="
	|| ( >=sys-devel/gcc-4.8.5-r1 >=sys-devel/llvm-3.4.2-r100 )
	>=sci-geosciences/libosmium-2.13.1
	>=dev-libs/protozero-1.5.1
	>=dev-libs/utfcpp-2.3.4
	>=dev-libs/rapidjson-1.1.0
	>=dev-libs/boost-1.55.0
	>=app-arch/bzip2-1.0.6-r8
	>=sys-libs/zlib-0.5.4.2
	>=dev-libs/expat-2.2.5
	>=dev-util/cmake-3.9.6
	doc? ( >=app-text/pandoc-1.19.2.1-r1 )
	"

RDEPEND="${DEPEND}"
