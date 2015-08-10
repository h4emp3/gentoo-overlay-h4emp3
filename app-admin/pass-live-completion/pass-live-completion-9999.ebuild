# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python3_4 )

inherit distutils-r1 git-r3

DESCRIPTION="Python based interactive shell for app-admin/pass ."
HOMEPAGE="https://code.workwork.net/hmp/pass-live-completion"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-admin/pass"
RDEPEND="${DEPEND}"


EGIT_REPO_URI="https://code.workwork.net/hmp/${PN}.git"

if [ "${PV}" = '9999' ]; then
	EGIT_BRANCH="develop"
else
	EGIT_COMMIT="${PV}"
fi


python_install() {
	distutils-r1_python_install
	dobin "${S}/bin/pass-live-completion"
}
