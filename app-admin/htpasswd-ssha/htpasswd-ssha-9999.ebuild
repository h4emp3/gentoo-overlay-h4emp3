# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Create htpasswd files with additional algorithm S(ecure)SHA."
HOMEPAGE="https://github.com/DrGkill/htpasswd-ssha"
EGIT_REPO_URI="https://github.com/DrGkill/${PN}.git"
EGIT_BRANCH="master"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND="virtual/perl-MIME-Base64
	dev-perl/Digest-SHA1
	dev-perl/TermReadKey"

src_install(){
	dodoc README
	dobin htpasswd-ssha
}
