# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=ngdevkit-toolchain
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=0.1+202508170852
pkgrel=1
pkgvernightly=nightly-202508170852
pkgdesc="Toolchain for ngdevkit (mingw-w64)"
arch=('x86_64')
url='https://github.com/dciabrin/ngdevkit-toolchain'
license=('LGPL3')
makedepends=("autoconf"
             "automake"
             "bison"
             "gawk"
             "make"
             "patch"
             "sed"
             "tar"
             "texinfo"
             "${MINGW_PACKAGE_PREFIX}-boost"
             "${MINGW_PACKAGE_PREFIX}-bzip2"
             "${MINGW_PACKAGE_PREFIX}-gcc"
             "${MINGW_PACKAGE_PREFIX}-libtool"
             "${MINGW_PACKAGE_PREFIX}-pkgconf"
             "${MINGW_PACKAGE_PREFIX}-readline"
             "${MINGW_PACKAGE_PREFIX}-xz")
depends=("flex"
         "${MINGW_PACKAGE_PREFIX}-expat"
         "${MINGW_PACKAGE_PREFIX}-gettext"
         "${MINGW_PACKAGE_PREFIX}-gmp"
         "${MINGW_PACKAGE_PREFIX}-mpc"
         "${MINGW_PACKAGE_PREFIX}-mpfr"
         "${MINGW_PACKAGE_PREFIX}-ncurses"
         "${MINGW_PACKAGE_PREFIX}-gmp"
         "${MINGW_PACKAGE_PREFIX}-zlib")
options=('!strip' '!buildflags' 'staticlibs')
source=(https://github.com/dciabrin/${_realname}/archive/refs/tags/${pkgvernightly}.tar.gz)
sha256sums=('586f7ac7936cda535192033ff146f4c09c8a64edce9454a3ccbd1cd55e0a4e81')
noextract=(${pkgvernightly}.tar.gz)

prepare() {
  # extract directly in srcdir to keep path short as otherwise this causes
  # build issue with nested directories and path length limitation on windows
  tar --strip-components=1 -zxf ${pkgvernightly}.tar.gz
}

build() {
  make all LOCAL_PACKAGE_DIR=${LOCAL_PACKAGE_DIR:-} BUILD=$(PWD)/build DESTDIR="${pkgdir}" prefix="${MINGW_PREFIX}"
}

package() {
  make install LOCAL_PACKAGE_DIR=${LOCAL_PACKAGE_DIR:-} BUILD=$(PWD)/build DESTDIR="${pkgdir}" prefix="${MINGW_PREFIX}"
}
