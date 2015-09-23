# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
PYTHON_COMPAT=( python2_7 )

inherit git-r3 distutils-r1

DESCRIPTION="Simple to use CardDAV CLI client with mutt query syntax support"
HOMEPAGE="http://lostpackets.de/pycarddav/"
EGIT_REPO_URI="https://github.com/geier/pycarddav"
EGIT_COMMIT="v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

PYTHON_REQ_USE="sqlite(+)"
RDEPEND="dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/vobject[${PYTHON_USEDEP}]
	dev-python/urwid[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	${RDEPEND}"

DOCS="CHANGELOG
	CONTRIBUTING.txt
	CONTRIBUTORS.txt
	NEWS.txt
	README.rst
	pycard.conf.sample"

pkg_postinst() {
	ewarn "Copy and edit the supplied pycard.conf.sample file (default"
	ewarn "location is ~/.config/pycard/pycard.conf). If you don't want to"
	ewarn "store the password inclear text in the config file, pyCardDAV will"
	ewarn "ask for it while syncing."
}
