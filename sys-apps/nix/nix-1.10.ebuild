# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit user

DESCRIPTION="Purely Functional Package Manager with atomic operations."
HOMEPAGE="https://nixos.org/nix/"
SRC_URI="http://nixos.org/releases/${PN}/${P}/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="+multiuser +gc systemd doc"

# undocumented dependencies:
# - dev-perl/WWW-Curl

COMMON_DEPEND="
	>=dev-lang/perl-5.8
	app-arch/bzip2
	>=dev-db/sqlite-3.6.19
	gc? ( dev-libs/boehm-gc )
	doc? ( dev-libs/libxml2
		dev-libs/libxslt
		app-text/docbook-xsl-stylesheets
	)
	systemd? ( sys-apps/systemd ) || ( sys-apps/openrc )
"
DEPEND="${COMMON_DEPEND}
	sys-libs/zlib
	sys-devel/make
	>=sys-devel/gcc-4.7[cxx]
	virtual/pkgconfig
	>=sys-devel/bison-2.6
	>=sys-devel/flex-2.5.35
"
RDEPEND="${COMMON_DEPEND}
	dev-perl/DBD-SQLite
	dev-perl/WWW-Curl
"

NIX_BUILD_GROUP="nixbld"
NIX_USERS_GROUP="nix-users"
NIX_BUILD_USERS="${NIX_BUILD_USERS-1}"

src_configure() {

	econf $(use_enable gc)

}

src_install() {

	# TODO: stuff from misc/
	# - docker
	# - emacs
	# - launchd (only osx, right?)
	# - upstart (only ubuntu, right?)

	default

	# remove upstart (?) config
	rm -r "${ED}/etc/init/"

	# create nix store
	dodir '/nix/store'

	if use 'multiuser'; then

		# update profile
		echo "export NIX_REMOTE='daemon'" >>"${D}/etc/profile.d/nix.sh"

		# create profiles folder
		dodir '/var/lib/nix/profiles'

		# create per-user profiles folder
		dodir '/var/lib/nix/profiles/per-user'

	fi

	if ! use 'systemd'; then

		# delete systemd stuff
		rm -r "${ED}/usr/lib/systemd"

		# without systemd we need an initscript to start the nix-daemon needed
		# for multiuser operations
		if use 'multiuser'; then

			# create config for initscript
			newconfd "${FILESDIR}/${PN}.openrc-run-config" "nix-daemon"

			# add users group to config
			echo "nix_users_group='${NIX_USERS_GROUP}'" \
				>>"${D}/etc/conf.d/nix-daemon"

			# create initscript
			newinitd "${FILESDIR}/${PN}.openrc-run" "nix-daemon"

		fi

	fi

}

pkg_postinst() {

	# https://nixos.org/nix/manual/#ssec-multi-user
	if use 'multiuser'; then

		# create users/groups necessary for multiuser mode
		enewgroup "${NIX_BUILD_GROUP}"
		enewgroup "${NIX_USERS_GROUP}"
		for i in $(seq 1 "${NIX_BUILD_USERS}"); do
			enewuser "${NIX_BUILD_GROUP}-${i}" \
				-1 '' '' "${NIX_BUILD_GROUP}" "${NIX_BUILD_GROUP}"
		done

		# fix profiles folder permissions
		chgrp "${NIX_USERS_GROUP}" '/var/lib/nix/profiles'
		chmod 'ug=rwx,o=' '/var/lib/nix/profiles'

		# fix per-user profiles folder permissions
		dodir '/var/lib/nix/profiles/per-user'
		chgrp "${NIX_USERS_GROUP}" '/var/lib/nix/profiles/per-user'
		chmod 1770 '/var/lib/nix/profiles/per-user'

		elog "To be able to use the multiuser Nix env your user has to be in "
		elog "the correct group: ${NIX_USERS_GROUP}"

	fi

	# fix nix store permissions
	chgrp "${NIX_USERS_GROUP}" '/nix/store'
	chmod 1770 '/nix/store'

}

pkg_postrm() {

	if \
		grep -q -m1 -E "^${NIX_BUILD_GROUP}-[0-9]+" '/etc/passwd' \
		|| egetent 'group' "${NIX_BUILD_GROUP}" &>/dev/null
	then

		elog "During install this ebuild created a group and one or more users."
		elog "If you don't need them anymore, you can delete them with:"

		local nix_user
		for nix_user in $(grep -oE "^${NIX_BUILD_GROUP}-[0-9]+" '/etc/passwd')
		do
			elog "userdel ${nix_user%%:*}"
		done

		if [ -n "$(egetent 'group' "${NIX_BUILD_GROUP}")" ]; then
			elog "groupdel ${NIX_BUILD_GROUP}"
		fi

		if [ -n "$(egetent 'group' "${NIX_USERS_GROUP}")" ]; then
			elog "groupdel ${NIX_USERS_GROUP}"
		fi

	fi

}
