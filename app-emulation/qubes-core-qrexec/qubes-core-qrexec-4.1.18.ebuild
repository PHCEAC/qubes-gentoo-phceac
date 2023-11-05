# Maintainer: Frédéric Pierret <frederic.pierret@qubes-os.org>

EAPI=7

PYTHON_COMPAT=( python3_{7..11} )

inherit git-r3 multilib distutils-r1 qubes

if [[ ${PV} == *9999 ]]; then
	EGIT_COMMIT=HEAD
else
	EGIT_COMMIT="v${PV}"
fi

EGIT_BRANCH="release4.1"
EGIT_REPO_URI="https://github.com/QubesOS/qubes-core-qrexec.git"

KEYWORDS="amd64"
DESCRIPTION="The Qubes qrexec files (qube side)"
HOMEPAGE="http://www.qubes-os.org"
LICENSE="GPL-2"

SLOT="0"
IUSE="pandoc-bin"


DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
        dev-python/sphinx[${PYTHON_USEDEP}]
        dev-python/dbus-python[${PYTHON_USEDEP}]
        sys-libs/pam
        app-emulation/qubes-libvchan-xen
        pandoc-bin? (
            app-text/pandoc-bin
        )
        !pandoc-bin? (
            app-text/pandoc
        )
        ${PYTHON_DEPS}
        "
RDEPEND="${DEPEND}"
PDEPEND=""

src_prepare() {
    qubes_verify_sources_git "${EGIT_COMMIT}"
    default
}

src_compile() {
    # Fix PAM
    sed -i 's/postlogin/system-auth/g' agent/qrexec.pam

    myopt="${myopt} DESTDIR=${D} SYSTEMD=1 BACKEND_VMM=xen LIBDIR=/usr/$(get_libdir)"
    emake ${myopt} all-base
    emake ${myopt} all-vm
}

src_install() {
    emake ${myopt} install-base
    emake ${myopt} install-vm
}

pkg_postinst() {
    systemctl enable qubes-qrexec-agent.service
}

pkg_postrm() {
    systemctl disable qubes-qrexec-agent.service
}