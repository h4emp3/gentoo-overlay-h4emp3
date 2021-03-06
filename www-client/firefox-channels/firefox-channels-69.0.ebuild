# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Can be updated using scripts/get_langs.sh from mozilla overlay
# esr is missing: bn en-CA
MOZ_LANGS=(ach af an ar ast az be bg br bs ca cak cs cy da de dsb el en
en-GB en-US eo es-AR es-CL es-ES es-MX et eu fa ff fi fr fy-NL ga-IE gd gl gn gu-IN
he hi-IN hr hsb hu hy-AM ia id is it ja ka kab kk km kn ko lij lt lv mk mr ms my
nb-NO nl nn-NO oc pa-IN pl pt-BR pt-PT rm ro ru si sk sl son sq sr sv-SE ta te
th tr uk ur uz vi xh zh-CN zh-TW )

# replace channels with bin, this ebuild replaces www-client/firefox-bin
REAL_PN="${PN/-channels}-bin"

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_beta/b}" # Handle beta for SRC_URI
MOZ_PV="${MOZ_PV/_rc/rc}" # Handle rc for SRC_URI
MOZ_PN="${REAL_PN/-bin}"
if [[ ${PV} = '60.9.0' ]]; then
	# ESR releases have slightly version numbers
	MOZ_PV="${MOZ_PV}esr"
	CHANNEL="esr"
	PN_FULL="${REAL_PN}-esr"
	MOZ_PN_FULL="${MOZ_PN}-esr"
elif [[ ${PV} =~ beta ]]; then
	CHANNEL="beta"
	PN_FULL="${REAL_PN}-beta"
	MOZ_PN_FULL="${MOZ_PN}-beta"
else
	CHANNEL="stable"
	PN_FULL="${REAL_PN}"
	MOZ_PN_FULL="${MOZ_PN}"
fi
MOZ_P="${MOZ_PN}-${MOZ_PV}"

MOZ_HTTP_URI="https://archive.mozilla.org/pub/mozilla.org/${MOZ_PN}/releases/"

inherit eutils pax-utils xdg-utils gnome2-utils mozlinguas-v2 nsplugins

DESCRIPTION="Firefox Web Browser"
SRC_URI="${SRC_URI}
	amd64? ( ${MOZ_HTTP_URI%/}/${MOZ_PV}/linux-x86_64/en-US/${MOZ_P}.tar.bz2 -> ${REAL_PN}_x86_64-${PV}.tar.bz2 )
	x86? ( ${MOZ_HTTP_URI%/}/${MOZ_PV}/linux-i686/en-US/${MOZ_P}.tar.bz2 -> ${REAL_PN}_i686-${PV}.tar.bz2 )"
HOMEPAGE="https://www.mozilla.org/en-US/firefox/"
RESTRICT="strip mirror"

case "$CHANNEL" in
	esr)
		KEYWORDS="-* amd64 x86"
		SLOT="esr"
		;;
	stable)
		KEYWORDS="-* amd64 x86"
		SLOT="stable"
		;;
	beta)
		KEYWORDS="-* ~amd64 ~x86"
		SLOT="beta"
		;;
esac
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+ffmpeg +pulseaudio selinux startup-notification"

DEPEND="!www-client/firefox-bin
	!www-client/firefox-bin-slotted
	app-arch/unzip"
RDEPEND="dev-libs/atk
	>=sys-apps/dbus-0.60
	>=dev-libs/dbus-glib-0.72
	>=dev-libs/glib-2.26:2
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	>=x11-libs/cairo-1.10[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-2.18:2
	>=x11-libs/gtk+-3.4.0:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXt
	>=x11-libs/pango-1.22.0
	virtual/freedesktop-icon-theme
	pulseaudio? ( !<media-sound/apulse-0.1.9
		|| ( media-sound/pulseaudio media-sound/apulse ) )
	ffmpeg? ( media-video/ffmpeg )
	selinux? ( sec-policy/selinux-mozilla )
"

QA_PREBUILT="
	opt/${MOZ_PN_FULL}/*.so
	opt/${MOZ_PN_FULL}/${MOZ_PN}
	opt/${MOZ_PN_FULL}/${REAL_PN}
	opt/${MOZ_PN_FULL}/crashreporter
	opt/${MOZ_PN_FULL}/webapprt-stub
	opt/${MOZ_PN_FULL}/plugin-container
	opt/${MOZ_PN_FULL}/mozilla-xremote-client
	opt/${MOZ_PN_FULL}/updater
	opt/${MOZ_PN_FULL}/minidump-analyzer
	opt/${MOZ_PN_FULL}/pingsender
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
	sizes="16 32 48 128"
	icon_path="${S}/browser/chrome/icons/default"
	icon="${PN_FULL}"
	name="Mozilla Firefox"

	# Install icons and .desktop for menu entry
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png" || die
	done
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${S}"/browser/chrome/icons/default/default48.png ${PN_FULL}.png
	domenu "${FILESDIR}"/${PN_FULL}.desktop
	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
		"${ED}usr/share/applications/${PN_FULL}.desktop" || die

	# Add StartupNotify=true bug 237317
	if use startup-notification; then
		echo "StartupNotify=true" >> "${ED}"usr/share/applications/${PN_FULL}.desktop
	fi

	# Install firefox in /opt
	dodir ${MOZILLA_FIVE_HOME%/*}
	mv "${S}" "${ED}"${MOZILLA_FIVE_HOME} || die

	# Disable built-in auto-update because we update firefox-bin through package manager
	insinto ${MOZILLA_FIVE_HOME}/distribution/
	newins "${FILESDIR}"/disable-auto-update.policy.json policies.json

	# Fix prefs that make no sense for a system-wide install
	insinto ${MOZILLA_FIVE_HOME}/defaults/pref/
	doins "${FILESDIR}"/local-settings.js
	insinto ${MOZILLA_FIVE_HOME}
	newins "${FILESDIR}"/all-gentoo-2.js all-gentoo.js

	# Install language packs
	MOZEXTENSION_TARGET="distribution/extensions" \
		MOZ_INSTALL_L10N_XPIFILE="1" \
		mozlinguas_src_install

	# Create /usr/bin/firefox-bin[-(beta|esr)]
	dodir /usr/bin/
	local apulselib=$(usex pulseaudio "/usr/$(get_libdir)/apulse:" "")
	cat <<-EOF >"${ED}"usr/bin/${PN_FULL}
	#!/bin/sh
	unset LD_PRELOAD
	LD_LIBRARY_PATH="${apulselib}/opt/${MOZ_PN_FULL}/" \\
	GTK_PATH=/usr/$(get_libdir)/gtk-3.0/ \\
	exec /opt/${MOZ_PN_FULL}/${MOZ_PN} "\$@"
	EOF
	fperms 0755 /usr/bin/${PN_FULL}

	# revdep-rebuild entry
	insinto /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=${MOZILLA_FIVE_HOME}" >> ${T}/10${PN_FULL}
	doins "${T}"/10${PN_FULL} || die

	# Plugins dir, still used for flash
	share_plugins_dir

	# Required in order to use plugins and even run firefox on hardened.
	pax-mark mr "${ED}"${MOZILLA_FIVE_HOME}/{firefox,firefox-bin,plugin-container}
}

pkg_postinst() {
	if ! has_version 'gnome-base/gconf' || ! has_version 'gnome-base/orbit' \
		|| ! has_version 'net-misc/curl'; then
		einfo
		einfo "For using the crashreporter, you need gnome-base/gconf,"
		einfo "gnome-base/orbit and net-misc/curl emerged."
		einfo
	fi
	use ffmpeg || ewarn "USE=-ffmpeg : HTML5 video will not render without media-video/ffmpeg installed"
	use pulseaudio || ewarn "USE=-pulseaudio : audio will not play without pulseaudio installed"

	# Update mimedb for the new .desktop file
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
