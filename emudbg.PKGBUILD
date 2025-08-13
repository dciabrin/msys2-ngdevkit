# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=emudbg
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=0.2+202403192028
pkgrel=1
pkgvernightly=nightly-202403192028
pkgdesc="Emulator-agnostic source-level debugging API (mingw-w64)"
arch=('x86_64')
url='https://github.com/dciabrin/emudbg'
license=('LGPL3')
makedepends=("autoconf"
             "automake"
             "make"
             "${MINGW_PACKAGE_PREFIX}-gcc"
             "${MINGW_PACKAGE_PREFIX}-pkgconf")
depends=("${MINGW_PACKAGE_PREFIX}-pkg-config")
options=('!strip' '!buildflags' 'staticlibs')
source=(https://github.com/dciabrin/${_realname}/archive/${pkgvernightly}.tar.gz)
sha256sums=('56306dd13bebcf001bcf340695b05d225bf077fc9ef99283db8f46eaf019e536')

build() {
  [[ -d "${srcdir}/build-${MINGW_CHOST}" ]] && rm -rf "${srcdir}/build-${MINGW_CHOST}"
  mkdir -p "${srcdir}/build-${MINGW_CHOST}"
  cd "${srcdir}/build-${MINGW_CHOST}"
  pushd ../${_realname}-${pkgvernightly}
  autoreconf -iv
  popd
  ../${_realname}-${pkgvernightly}/configure \
    --prefix=${MINGW_PREFIX} \
    --build=${MINGW_CHOST} \
    --host=${MINGW_CHOST} \
    --target=${MINGW_CHOST}
  make
}

package() {
  cd "${srcdir}/build-${MINGW_CHOST}"
  make DESTDIR="${pkgdir}" install
}
