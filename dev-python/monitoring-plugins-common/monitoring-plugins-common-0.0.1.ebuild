# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_4}  )

inherit python-r1 distutils-r1 git-r3

DESCRIPTION="Common files for monitoring-(ssh-)plugins."
HOMEPAGE="https://code.workwork.net/workwork/monitoring-plugins-common"
EGIT_REPO_URI="https://code.workwork.net/workwork/monitoring-plugins-common.git"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
SLOT="0"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

python_install_all() {
	local DOCS=( LICENSE *.rst )
	distutils-r1_python_install_all
}
