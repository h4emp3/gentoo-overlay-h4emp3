# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3

EGIT_REPO_URI="https://github.com/DrGkill/${PN}.git"
SRC_URI=""
KEYWORDS="amd64"

DESCRIPTION="Provide SSHA encrypted passwords for nginx basic authentication"
HOMEPAGE="https://github.com/DrGkill/htpasswd-ssha"

LICENSE="GPLv3"
SLOT="0"

RDEPEND="virtual/perl-MIME-Base64
	dev-perl/Digest-SHA1
	dev-perl/TermReadKey"

src_install(){
	dodoc README
	dobin htpasswd-ssha
}
