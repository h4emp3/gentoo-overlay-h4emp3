# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/firefox-bin/firefox-bin-38.0.1-r1.ebuild,v 1.2 2015/05/31 15:04:50 axs Exp $

EAPI="5"

# Can be updated using scripts/get_langs.sh from mozilla overlay
# Not officially supported as of yet
# csb
MOZ_LANGS=(af ar as ast be bg bn-BD bn-IN br bs ca cs cy da de el en
en-GB en-US en-ZA eo es-AR es-CL es-ES es-MX et eu fa fi fr fy-NL ga-IE gd gl
gu-IN he hi-IN hr hu hy-AM id is it ja kk kn ko lt lv mai mk ml mr nb-NO
nl nn-NO or pa-IN pl pt-BR pt-PT rm ro ru si sk sl son sq sr sv-SE ta
te tr uk vi zh-CN zh-TW)

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_alpha/a}" # Handle alpha for SRC_URI
MOZ_PV="${MOZ_PV/_beta/b}" # Handle beta for SRC_URI
MOZ_PV="${MOZ_PV/_rc/rc}" # Handle rc for SRC_URI
MOZ_PN="${PN/-bin}"
MOZ_P="${MOZ_PN}-${MOZ_PV}"

ALPHA_RELEASE="2015-08-02-00-40-05"

# Upstream ftp release URI that's used by mozlinguas.eclass
# We don't use the http mirror because it deletes old tarballs.
MOZ_FTP_URI="ftp://ftp.mozilla.org/pub/mozilla.org/${MOZ_PN}"

inherit eutils multilib pax-utils fdo-mime gnome2-utils mozlinguas nsplugins

DESCRIPTION="Firefox Web Browser"

if [[ ${PV} =~ alpha ]]; then
	PN_FULL="${PN}-aurora"
	MOZ_PN_FULL="${MOZ_PN}-aurora"
	SLOT="aurora"
	SRC_URI="${SRC_URI}
		amd64? (
		${MOZ_FTP_URI}/nightly/${ALPHA_RELEASE}-mozilla-aurora/${MOZ_P}.en-US.linux-x86_64.tar.bz2 -> ${PN}_x86_64-${PV}.tar.bz2 )
		x86? ( ${MOZ_FTP_URI}/nightly/${ALPHA_RELEASE}-mozilla-aurora/${MOZ_P}.en-US.linux-i686.tar.bz2 -> ${PN}_i686-${PV}.tar.bz2	)"
else
	if [[ ${PV} =~ beta ]]; then
		PN_FULL="${PN}-beta"
		MOZ_PN_FULL="${MOZ_PN}-beta"
		SLOT="beta"
	else
		PN_FULL="${PN}"
		MOZ_PN_FULL="${MOZ_PN}"
		SLOT="stable"
	fi
	SRC_URI="${SRC_URI}
		amd64? ( ${MOZ_FTP_URI}/releases/${MOZ_PV}/linux-x86_64/en-US/${MOZ_P}.tar.bz2 -> ${PN}_x86_64-${PV}.tar.bz2 )
		x86? ( ${MOZ_FTP_URI}/releases/${MOZ_PV}/linux-i686/en-US/${MOZ_P}.tar.bz2 -> ${PN}_i686-${PV}.tar.bz2 )"
fi

HOMEPAGE="http://www.mozilla.com/firefox"
RESTRICT="strip mirror"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IUSE="selinux startup-notification"

DEPEND="app-arch/unzip"
RDEPEND="dev-libs/atk
	>=sys-apps/dbus-0.60
	>=dev-libs/dbus-glib-0.72
	>=dev-libs/glib-2.26:2
	>=media-libs/alsa-lib-1.0.16
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	>=x11-libs/cairo-1.10[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-2.18:2
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXt
	>=x11-libs/pango-1.22.0
	virtual/freedesktop-icon-theme
	selinux? ( sec-policy/selinux-mozilla )
"

QA_PREBUILT="
	opt/${MOZ_PN_FULL}/*.so
	opt/${MOZ_PN_FULL}/${MOZ_PN}
	opt/${MOZ_PN_FULL}/${PN}
	opt/${MOZ_PN_FULL}/crashreporter
	opt/${MOZ_PN_FULL}/webapprt-stub
	opt/${MOZ_PN_FULL}/plugin-container
	opt/${MOZ_PN_FULL}/mozilla-xremote-client
	opt/${MOZ_PN_FULL}/updater
"

S="${WORKDIR}/${MOZ_PN}"

src_unpack() {
	unpack ${A}

	# Unpack language packs
	mozlinguas_src_unpack
}

src_install() {
	declare MOZILLA_FIVE_HOME=/opt/${MOZ_PN_FULL}

	local size sizes icon_path icon name
	sizes="16 32 48"
	icon_path="${S}/browser/chrome/icons/default"
	icon="${PN_FULL}"
	name="Mozilla Firefox"

	# Install icons and .desktop for menu entry
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png" || die
	done
	# The 128x128 icon has a different name
	insinto "/usr/share/icons/hicolor/128x128/apps"
	newins "${icon_path}/../../../icons/mozicon128.png" "${icon}.png" || die
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${S}"/browser/chrome/icons/default/default48.png ${PN_FULL}.png
	domenu "${FILESDIR}"/${PN_FULL}.desktop
	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
		"${ED}/usr/share/applications/${PN_FULL}.desktop" || die

	# Add StartupNotify=true bug 237317
	if use startup-notification; then
		echo "StartupNotify=true" >> "${ED}"/usr/share/applications/${PN_FULL}.desktop
	fi

	# Install firefox in /opt
	dodir ${MOZILLA_FIVE_HOME%/*}
	mv "${S}" "${ED}"${MOZILLA_FIVE_HOME} || die

	# Fix prefs that make no sense for a system-wide install
	insinto ${MOZILLA_FIVE_HOME}/defaults/pref/
	doins "${FILESDIR}"/local-settings.js
	# Copy preferences file so we can do a simple rename.
	cp "${FILESDIR}"/all-gentoo-1.js \
		"${ED}"${MOZILLA_FIVE_HOME}/all-gentoo.js || die

	# Install language packs
	mozlinguas_src_install

	local LANG=${linguas%% *}
	if [[ -n ${LANG} && ${LANG} != "en" ]]; then
		elog "Setting default locale to ${LANG}"
		echo "pref(\"general.useragent.locale\", \"${LANG}\");" \
			>> "${ED}${MOZILLA_FIVE_HOME}"/defaults/pref/${PN}-prefs.js || \
			die "sed failed to change locale"
	fi

	# Create /usr/bin/firefox-bin(-beta|aurora)
	dodir /usr/bin/
	cat <<-EOF >"${ED}"/usr/bin/${PN_FULL}
	#!/bin/sh
	unset LD_PRELOAD
	LD_LIBRARY_PATH="/opt/${MOZ_PN_FULL}/"
	GTK_PATH=/usr/lib/gtk-2.0/
	exec /opt/${MOZ_PN_FULL}/${MOZ_PN} "\$@"
	EOF
	fperms 0755 /usr/bin/${PN_FULL}

	# revdep-rebuild entry
	insinto /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=${MOZILLA_FIVE_HOME}" >> ${T}/10${PN_FULL}
	doins "${T}"/10${PN_FULL} || die

	# Plugins dir
	share_plugins_dir

	# Required in order to use plugins and even run firefox on hardened.
	pax-mark mr "${ED}"${MOZILLA_FIVE_HOME}/{firefox,firefox-bin,plugin-container}
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	if ! has_version 'gnome-base/gconf' || ! has_version 'gnome-base/orbit' \
		|| ! has_version 'net-misc/curl'; then
		einfo
		einfo "For using the crashreporter, you need gnome-base/gconf,"
		einfo "gnome-base/orbit and net-misc/curl emerged."
		einfo
	fi
	# Drop requirement of curl not built with nss as it's not necessary anymore
	#if has_version 'net-misc/curl[nss]'; then
	#	einfo
	#	einfo "Crashreporter won't be able to send reports"
	#	einfo "if you have curl emerged with the nss USE-flag"
	#	einfo
	#fi

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
