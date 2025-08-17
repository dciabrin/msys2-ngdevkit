# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=ngdevkit-toolchain
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=0.1+202506231313
pkgrel=3
pkgvernightly=nightly-202506231313
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
sha256sums=('f5be1f9d56704bc89a2dd7169539d12bcf4f8ededf2d5f422a46555afb21436e')
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
