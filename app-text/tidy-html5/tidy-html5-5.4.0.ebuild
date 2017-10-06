# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3 cmake-utils

DESCRIPTION="Tidy the layout and correct errors in HTML(5) and XML documents"
HOMEPAGE="http://www.html-tidy.org/"
EGIT_REPO_URI="https://github.com/htacg/${PN}"
EGIT_COMMIT="${PV}"

LICENSE="TIDY-HTML5"
SLOT="0"
KEYWORDS="~* x86 amd64"

DEPEND=">=dev-util/cmake-2.8.8"
RDEPEND="!!app-text/htmltidy"

DOCS='README.md README/*.md'
HTML_DOCS='README/README.html'
