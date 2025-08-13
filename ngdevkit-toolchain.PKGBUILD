# Maintainer: Damien Ciabrini <damien.ciabrini@gmail.com>

_realname=ngdevkit-toolchain
pkgbase=mingw-w64-${_realname}
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}"
pkgver=0.1+202506231313
pkgrel=2
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

pkgextraflags="--build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32"

prepare() {
  # extract directly in srcdir to keep path short as otherwise this causes
  # build issue with nested directories and path length limitation on windows
  tar --strip-components=1 -zxf ${pkgvernightly}.tar.gz
}

build() {
  # building the toolchain only works with MSYS sed
  # TODO: inject that part in ngdevkit-toolchain directly
  [[ -d "${srcdir}/build" ]] && rm -rf "${srcdir}/build"
  mkdir -p "${srcdir}/build/sed-msys2"
  cp /usr/bin/sed.exe "${srcdir}/build/sed-msys2"
  export PATH=$PWD/build/sed-msys2:$PATH
  make all LOCAL_PACKAGE_DIR=${LOCAL_PACKAGE_DIR:-} BUILD=$(PWD)/build DESTDIR="${pkgdir}" prefix="${MINGW_PREFIX}" EXTRA_BUILD_FLAGS="${pkgextraflags}"
}

package() {
  export PATH=$PWD/build/sed-msys2:$PATH
  # TODO remove the -j1 when newlib parallel install is fixed
  make -j1 install LOCAL_PACKAGE_DIR=${LOCAL_PACKAGE_DIR:-} BUILD=$(PWD)/build DESTDIR="${pkgdir}" prefix="${MINGW_PREFIX}" EXTRA_BUILD_FLAGS="${pkgextraflags}"
  # Remove the problematic symlinks
  mkdir -p ${pkgdir}${MINGW_PREFIX}/bin
  for i in ar ranlib; do
    rm -f ${pkgdir}${MINGW_PREFIX}/bin/m68k-neogeo-elf-$i.exe
    cat >${pkgdir}${MINGW_PREFIX}/bin/m68k-neogeo-elf-$i.exe <<EOF
#!/bin/sh
# NOTE: MINGW may be configured to implement symlinks with direct copies,
# which would break $i's plugin path. This wrapper execs into the real
# binary, which is enough to fix that problem.
exec ${MINGW_PREFIX}/m68k-neogeo-elf/bin/$i.exe \$*
EOF
    chmod +x ${pkgdir}${MINGW_PREFIX}/bin/m68k-neogeo-elf-$i.exe
  done
}
