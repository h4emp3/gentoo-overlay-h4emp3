# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# package itself
CRATES="bat-${PV}"

# from crate (versions from lockfile, all but directories)
CRATES="${CRATES}
		ansi_colours-1.0.1
		ansi_term-0.11.0
		atty-0.2.11
		clap-2.32.0
		console-0.6.2
		directories-1.0.2
		error-chain-0.12.0
		git2-0.7.5
		lazy_static-1.1.0
		syntect-2.1.0
"

# deps of deps
CRATES="${CRATES}
		aho-corasick-0.6.8
		base64-0.8.0
		bincode-1.0.1
		bitflags-1.0.4
		byteorder-1.2.6
		cc-1.0.25
		cfg-if-0.1.5
		chrono-0.4.6
		clicolors-control-0.2.0
		cloudabi-0.0.3
		flate2-1.0.2
		fnv-1.0.6
		fuchsia-zircon-0.3.3
		fuchsia-zircon-sys-0.3.3
		idna-0.1.5
		itoa-0.4.3
		kernel32-sys-0.2.2
		lazy_static-0.2.11
		libc-0.2.43
		libgit2-sys-0.7.10
		libz-sys-1.0.23
		linked-hash-map-0.5.1
		lock_api-0.1.4
		log-0.4.5
		matches-0.1.8
		memchr-2.1.0
		miniz-sys-0.1.10
		num-integer-0.1.39
		num-traits-0.2.6
		onig-3.2.2
		onig_sys-68.2.1
		owning_ref-0.3.3
		parking_lot-0.6.4
		parking_lot_core-0.3.1
		percent-encoding-1.0.1
		pkg-config-0.3.14
		plist-0.2.4
		proc-macro2-0.4.19
		quote-0.6.8
		rand-0.4.3
		rand-0.5.5
		rand_core-0.2.1
		redox_syscall-0.1.40
		redox_termios-0.1.1
		regex-1.0.5
		regex-syntax-0.4.2
		regex-syntax-0.6.2
		remove_dir_all-0.5.1
		rustc_version-0.2.3
		ryu-0.2.6
		safemem-0.2.0
		same-file-1.0.3
		scopeguard-0.3.3
		semver-0.9.0
		semver-parser-0.7.0
		serde-1.0.79
		serde_derive-1.0.79
		serde_json-1.0.31
		smallvec-0.6.5
		stable_deref_trait-1.1.1
		strsim-0.7.0
		syn-0.15.6
		tempdir-0.3.7
		term_size-0.3.1
		termion-1.5.1
		termios-0.3.0
		textwrap-0.10.0
		thread_local-0.3.6
		time-0.1.40
		ucd-util-0.1.1
		unicode-bidi-0.3.4
		unicode-normalization-0.1.7
		unicode-width-0.1.5
		unicode-xid-0.1.0
		unreachable-1.0.0
		url-1.7.1
		utf8-ranges-1.0.1
		vcpkg-0.2.6
		version_check-0.1.5
		void-1.0.2
		walkdir-2.2.5
		winapi-0.2.8
		winapi-0.3.6
		winapi-build-0.1.1
		winapi-i686-pc-windows-gnu-0.4.0
		winapi-util-0.1.1
		winapi-x86_64-pc-windows-gnu-0.4.0
		xml-rs-0.7.0
		yaml-rust-0.4.2
"

inherit cargo bash-completion-r1

DESCRIPTION="A cat(1) clone with wings."
HOMEPAGE="https://github.com/sharkdp/bat"
SRC_URI="$(cargo_crate_uris ${CRATES})"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/rust-1.26"

src_test() {
	cargo test || die "tests failed"
}

src_install() {
	cargo_src_install

	# hacks to find/install generated files
	#BUILD_DIR=$(dirname $(find target/release -name bat.1))
	#doman "${BUILD_DIR}"/bat.1
	#newbashcomp "${BUILD_DIR}"/bat.bash bat

	dodoc README.md

	#insinto /usr/share/zsh/site-functions
	#doins complete/_bat

}
