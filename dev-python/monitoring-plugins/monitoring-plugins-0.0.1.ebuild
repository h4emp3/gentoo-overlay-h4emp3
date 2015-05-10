# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_4}  )

inherit distutils-r1 git-r3

DESCRIPTION="Plugins for Nagios, Icinga and others."
HOMEPAGE="https://code.workwork.net/workwork/monitoring-plugins"
EGIT_REPO_URI="https://code.workwork.net/workwork/monitoring-plugins.git"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
SLOT="0"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
		>=dev-python/monitoring-plugins-common-0.0.1"

python_install_all() {
	local DOCS=( LICENSE *.rst )
	distutils-r1_python_install_all
}
