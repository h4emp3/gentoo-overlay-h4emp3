# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_4}  )

inherit python-r1 distutils-r1 git-r3

DESCRIPTION="Plugins for Nagios, Icinga and others."
HOMEPAGE="https://code.workwork.net/workwork/monitoring-plugins"
EGIT_REPO_URI="https://code.workwork.net/workwork/${PN}.git"
EGIT_REPO_BRANCH="master"

LICENSE="GPL-2"
KEYWORDS="~*"
SLOT="0"

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="=dev-python/monitoring-plugins-common-9999"

python_install_all() {
	local DOCS=( LICENSE *.rst )
	distutils-r1_python_install_all
}
