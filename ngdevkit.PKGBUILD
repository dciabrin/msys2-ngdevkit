# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=ngdevkit
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=0.5+202610171524
pkgrel=1
pkgvernightly=nightly-202610171524
pkgdesc="Open source development for Neo-Geo (mingw-w64)"
arch=('x86_64')
url='https://github.com/dciabrin/ngdevkit'
license=('LGPL3')
makedepends=("autoconf"
             "automake"
             "make"
             "zip")
depends=("${MINGW_PACKAGE_PREFIX}-ngdevkit-toolchain"
         "${MINGW_PACKAGE_PREFIX}-pkgconf"
         "${MINGW_PACKAGE_PREFIX}-python"
         "${MINGW_PACKAGE_PREFIX}-python-pillow"
         "${MINGW_PACKAGE_PREFIX}-python-ruamel-yaml")
options=('!strip' '!buildflags' 'staticlibs')
source=(https://github.com/dciabrin/ngdevkit/archive/${pkgvernightly}.tar.gz)
sha256sums=('28bff6a9342acb871cf59e65d0511ad2d781ddbc8e39f988952da5b5ef376975')

build() {
  cd ${_realname}-${pkgvernightly}
  autoreconf -iv
  ../${_realname}-${pkgvernightly}/configure \
    --prefix=${MINGW_PREFIX} \
    --build=${MINGW_CHOST} \
    --host=${MINGW_CHOST} \
    --target=${MINGW_CHOST} \
    --enable-external-toolchain \
    --enable-external-emudbg \
    --enable-external-gngeo \
    --enable-examples=no
    make
}

package() {
  cd ${_realname}-${pkgvernightly}
  make DESTDIR="${pkgdir}" install
}
