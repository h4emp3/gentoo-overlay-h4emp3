# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

DESCRIPTION="CACert Root Certificates"
HOMEPAGE="http://www.cacert.org/index.php?id=3"

LICENSE="RDL-COD14-p20100710"
SLOT="0"
KEYWORDS="alpha amd64 -amd64-fbsd arm arm64 hppa ia64 m68k -mips nios2 ppc ppc64
		  riscv s390 sh sparc -sparc-fbsd x86 -x86-fbsd"
IUSE=""

DEPEND="app-misc/ca-certificates[-cacert]"
RDEPEND="${DEPEND} dev-libs/openssl"

src_unpack() {
	mkdir -p "${S}"
}

src_install() {
	insinto /usr/share/ca-certificates/cacert.org || die
	doins "${FILESDIR}"/root.crt "${FILESDIR}"/class3.crt || die
	dosym /usr/share/ca-certificates/cacert.org/root.crt \
		/etc/ssl/certs/cacert_class1.pem
	dosym /usr/share/ca-certificates/cacert.org/class3.crt \
		/etc/ssl/certs/cacert_class3.pem
}

pkg_postinst() {
	"${EROOT}"/usr/sbin/update-ca-certificates --root "${EROOT}"

	local c badcerts=0
	for c in $(find -L "${EROOT}"etc/ssl/certs/ -type l) ; do
		ewarn "Broken symlink for a certificate at $c"
		badcerts=1
	done
	if [ $badcerts -eq 1 ]; then
		ewarn "You MUST remove the above broken symlinks"
		ewarn "Otherwise any SSL validation that use the directory may fail!"
		ewarn "To batch-remove them, run:"
		ewarn "find -L ${EROOT}etc/ssl/certs/ -type l -exec rm {} +"
	fi
}
