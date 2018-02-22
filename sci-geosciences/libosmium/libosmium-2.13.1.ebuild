# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3 cmake-utils

DESCRIPTION="Fast and flexible C++ library for working with OpenStreetMap data."
HOMEPAGE="https://github.com/osmcode/libosmium/"
EGIT_REPO_URI="https://github.com/osmcode/libosmium/"
EGIT_COMMIT="v${PV}"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# TODO:
# - separate build and run deps properly
# - optional deps: google sparsehash, boost program options, gdal/ogr, geos,
#				   proj.4, doxygen

DEPEND="
	|| ( >=sys-devel/gcc-4.8.5-r1 >=sys-devel/llvm-3.4.2-r100 )
	>=app-arch/bzip2-1.0.6-r8
	>=dev-libs/boost-1.55.0
	>=dev-libs/expat-2.2.5
	>=dev-libs/protozero-1.5.1
	>=dev-libs/utfcpp-2.3.4
	>=sys-libs/zlib-0.5.4.2
	"

RDEPEND="${DEPEND}"
