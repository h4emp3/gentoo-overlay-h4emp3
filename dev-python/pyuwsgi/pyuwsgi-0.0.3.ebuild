# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="This module provides a basic WSGI Interface for writing webpages in Python"
HOMEPAGE="http://cgit.secforge.com/pyuwsgi"
SRC_URI="http://cgit.secforge.com/${PN}/plain/${PN}-${PVR}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 x86"
IUSE="apache uwsgi"

DEPEND="( <dev-lang/python-3 )
apache? ( www-apache/mod_wsgi )
uwsgi? ( www-servers/uwsgi )"
RDEPEND="!<dev-lang/python-2.5"
