# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=ngdevkit
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=0.5+202611232216
pkgrel=1
pkgvernightly=nightly-202611232216
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
sha256sums=('6bb00ec161e6f7df6498fdf2d96c066bac760dd1425b12025771fe68b501c2a7')

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
