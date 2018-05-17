# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# package itself
CRATES="bat-${PV}"

# from crate
CRATES="${CRATES}
		clap-2.31.2
		error-chain-0.11.0
		git2-0.7.1
		syntect-2.0.1
	    ansi_term-0.10.2
	    atty-0.2.2
	    console-0.6.1
	    directories-0.10.0
	    lazy_static-1.0.0
"

# atty
CRATES="${CRATES}
		kernel32-sys-0.2.2
		libc-0.2.40
		winapi-0.2.8
"

# clap-2.31.2
CRATES="${CRATES}
		bitflags-1.0.3
		strsim-0.7.0
		term_size-0.3.1
		textwrap-0.9.0
		unicode-width-0.1.4
	    ansi_term-0.11.0
"

# kernel32-sys-0.2.2
CRATES="${CRATES}
		winapi-build-0.1.1
"

# console-0.6.1
CRATES="${CRATES}
		clicolors-control-0.2.0
		lazy_static-0.2.11
		parking_lot-0.5.5
		regex-0.2.11
		termios-0.2.2
		winapi-0.3.4
"

# winapi-0.3.4
CRATES="${CRATES}
		winapi-i686-pc-windows-gnu-0.4.0
		winapi-x86_64-pc-windows-gnu-0.4.0
"

# parking_lot-0.5.5
CRATES="${CRATES}
		owning_ref-0.3.3
		parking_lot_core-0.2.14
"

# error-chain-0.11.0
CRATES="${CRATES}
		backtrace-0.3.7
"

# owning_ref-0.3.3
CRATES="${CRATES}
		stable_deref_trait-1.0.0
"

# backtrace-0.3.7
CRATES="${CRATES}
		backtrace-sys-0.1.16
		cfg-if-0.1.3
		rustc-demangle-0.1.8
"

# parking_lot_core-0.2.14
CRATES="${CRATES}
		rand-0.4.2
		smallvec-0.6.1
"

# rand-0.4.2
CRATES="${CRATES}
		fuchsia-zircon-0.3.3
"

# fuchsia-zircon-0.3.3
CRATES="${CRATES}
		fuchsia-zircon-sys-0.3.3
"

# regex-0.2.11
CRATES="${CRATES}
		aho-corasick-0.6.4
		memchr-2.0.1
		regex-syntax-0.5.6
		thread_local-0.3.5
		utf8-ranges-1.0.0
"

# backtrace-sys-0.1.16
CRATES="${CRATES}
		cc-1.0.15
"

# git2-0.7.1
CRATES="${CRATES}
		libgit2-sys-0.7.1
		log-0.4.1
		url-1.7.0
"

# libgit2-sys-0.7.1
CRATES="${CRATES}
		libz-sys-1.0.18
		cmake-0.1.31
		pkg-config-0.3.11
"

# syntect-2.0.1
CRATES="${CRATES}
		bincode-1.0.0
		flate2-1.0.1
		fnv-1.0.6
		onig-3.2.2
		plist-0.2.4
		regex-syntax-0.4.2
		serde-1.0.55
		serde_derive-1.0.55
		serde_json-1.0.17
		walkdir-2.1.4
		yaml-rust-0.4.0
"

# bincode-1.0.0
CRATES="${CRATES}
		byteorder-1.2.3
"

# libz-sys-1.0.18
CRATES="${CRATES}
		vcpkg-0.2.3
"

# regex-syntax-0.5.6
CRATES="${CRATES}
		ucd-util-0.1.1
"

# url-1.7.0
CRATES="${CRATES}
		idna-0.1.4
		matches-0.1.6
		percent-encoding-1.0.1
"

# idna-0.1.4
CRATES="${CRATES}
		unicode-bidi-0.3.4
		unicode-normalization-0.1.7
"

# flate2-1.0.1
CRATES="${CRATES}
		miniz-sys-0.1.10
"

# thread_local-0.3.5
CRATES="${CRATES}
		unreachable-1.0.0
"

# unreachable-1.0.0
CRATES="${CRATES}
		void-1.0.2
"

# onig-3.2.2
CRATES="${CRATES}
		onig_sys-68.0.1
"

# plist-0.2.4
CRATES="${CRATES}
		base64-0.8.0
		chrono-0.4.2
		xml-rs-0.7.1
"

# base64-0.8.0
CRATES="${CRATES}
		safemem-0.2.0
"

# chrono-0.4.2
CRATES="${CRATES}
		num-integer-0.1.38
		num-traits-0.2.4
		time-0.1.40
"

# onig_sys-68.0.1
CRATES="${CRATES}
		duct-0.10.0
"

# time-0.1.40
CRATES="${CRATES}
		redox_syscall-0.1.37
"

# duct-0.10.0
CRATES="${CRATES}
		lazycell-0.6.0
		os_pipe-0.6.1
		shared_child-0.3.2
"

# os_pipe-0.6.1
CRATES="${CRATES}
		nix-0.10.0
"

# serde_derive-1.0.55
CRATES="${CRATES}
		proc-macro2-0.3.8
		quote-0.5.2
		syn-0.13.10
"

# nix-0.10.0
CRATES="${CRATES}
		bytes-0.4.7
		gcc-0.3.54
"

# proc-macro2-0.3.8
CRATES="${CRATES}
		unicode-xid-0.1.0
"

# serde_json-1.0.17
CRATES="${CRATES}
		dtoa-0.4.2
		itoa-0.4.1
"

# bytes-0.4.7
CRATES="${CRATES}
		iovec-0.1.2
"

# walkdir-2.1.4
CRATES="${CRATES}
		same-file-1.0.2
"

# yaml-rust-0.4.0
CRATES="${CRATES}
		linked-hash-map-0.5.1
"

CRATES="${CRATES}
"

inherit cargo bash-completion-r1

DESCRIPTION="A cat(1) clone with wings."
HOMEPAGE="https://github.com/sharkdp/bat"
SRC_URI="$(cargo_crate_uris ${CRATES})"
#https://github.com/trishume/syntect/archive/6ad8132b60cbf0637d92241de752f015ced01450.zip -> syntect-6ad8132b60cbf0637d92241de752f015ced01450.zip"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/rust-1.24"

#src_prepare() {
#	default_src_prepare
#	mkdir -p "${S}/target/snapshot"
#	mv "${WORKDIR}/syntect-6ad8132b60cbf0637d92241de752f015ced01450" \
#		"${ECARGO_VENDOR}/syntect-0.2.1"
#}

src_test() {
	cargo test || die "tests failed"
}

src_install() {
	cargo_src_install

	# hacks to find/install generated files
	#BUILD_DIR=$(dirname $(find target/release -name rg.1))
	#doman "${BUILD_DIR}"/rg.1
	#newbashcomp "${BUILD_DIR}"/rg.bash rg

	dodoc README.md

	#insinto /usr/share/zsh/site-functions
	#doins complete/_rg

}
