# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Module infrastructure, keybindings and prompt for the Z shell."
HOMEPAGE="https://code.workwork.net/hmp/zsh-foo"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	app-shells/zsh
	=app-shells/zsh-syntax-highlighting-0.3.0-r3"

EGIT_REPO_URI="https://code.workwork.net/hmp/${PN}.git"

if [ "${PV}" = '9999' ]; then
	EGIT_BRANCH="develop"
else
	EGIT_COMMIT="${PV}"
fi

CONTRIB_DIR="/usr/share/zsh/site-contrib/${PN}"

src_prepare() {

	local path_rx="s|^(declare -gr _zf_base=).*$|\1'${CONTRIB_DIR}'|"

	sed -i -re "$path_rx" "${S}/src/zsh-foo/bin/zfoo-module"
	sed -i -re "$path_rx" "${S}/src/zsh-foo/zsh-foo.zsh"

}

src_install() {

	dobin "${S}/src/zsh-foo/bin/"*

	insinto "${CONTRIB_DIR}"
	doins -r "${S}/src/zsh-foo/zsh-foo.zsh" \
		"${S}/src/zsh-foo/modules/" \
		"${S}/src/zsh-foo/colorthemes/"

}
