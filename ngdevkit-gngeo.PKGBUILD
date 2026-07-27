# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=gngeo
pkgbase=mingw-w64-ngdevkit-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-ngdevkit-${_realname}"
pkgver=0.8.1+202607271849
pkgrel=1
pkgvernightly=nightly-202607271849
pkgdesc="Portable Neo-Geo emulator customized for ngdevkit (mingw-w64)"
arch=('x86_64')
url='https://github.com/dciabrin/gngeo'
license=('custom')
makedepends=("autoconf"
             "autoconf-archive"
             "automake"
             "make"
             "${MINGW_PACKAGE_PREFIX}-emudbg"
             "${MINGW_PACKAGE_PREFIX}-gcc"
             "${MINGW_PACKAGE_PREFIX}-libtool"
             "${MINGW_PACKAGE_PREFIX}-pkgconf")
depends=("${MINGW_PACKAGE_PREFIX}-SDL2"
         "${MINGW_PACKAGE_PREFIX}-glew")
options=('!strip' '!buildflags' 'staticlibs')
source=(https://github.com/dciabrin/${_realname}/archive/refs/tags/${pkgvernightly}.tar.gz)
sha256sums=('230e198e27e5f9ffc683a3f85097403c27110609879e2a84fa43c23472b8c3a2')

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
    --target=${MINGW_CHOST} \
    --program-prefix=ngdevkit- \
    --enable-msys2 \
    --with-glew \
    CFLAGS="-Wno-implicit-function-declaration -DGNGEORC=\\\"ngdevkit-gngeorc\\\"" \
    GL_LIBS="-L${MINGW_PREFIX}/bin -lglew32 -lopengl32"
  MSYS2_ARG_CONV_EXCL="-DDATA_DIRECTORY=" make pkgdatadir=${MINGW_PREFIX}/share/ngdevkit-gngeo
}

package() {
  cd "${srcdir}/build-${MINGW_CHOST}"
  make DESTDIR="${pkgdir}" install pkgdatadir=${MINGW_PREFIX}/share/ngdevkit-gngeo
}
