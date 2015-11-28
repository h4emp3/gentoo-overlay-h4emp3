# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 readme.gentoo

DESCRIPTION="Fish shell like syntax highlighting for zsh (patched)"
HOMEPAGE="https://github.com/zsh-users/zsh-syntax-highlighting"
EGIT_REPO_URI="https://github.com/h4emp3/${PN}"
EGIT_COMMIT="${PVR}"

LICENSE="HPND"
SLOT="0"
KEYWORDS="~* ~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="app-shells/zsh"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="In order to use ${CATEGORY}/${PN} add
. /usr/share/zsh/site-contrib/${PN}/zsh-syntax-highlighting.zsh
at the end of your ~/.zshrc
For testing, you can also execute the above command in your zsh."

src_prepare() {
	grep -q 'local .*cdpath_dir' \
		"${S}/highlighters/main/main-highlighter.zsh" >/dev/null 2>&1 || \
		sed -i -e '/for cdpath_dir/ilocal cdpath_dir' \
			-- "${S}/highlighters/main/main-highlighter.zsh" || die
	epatch_user
}

src_install() {
	dodoc *.md
	insinto /usr/share/zsh/site-contrib/${PN}
	doins *.zsh .revision-hash .version
	doins -r highlighters
	readme.gentoo_create_doc
}
