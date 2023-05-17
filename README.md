# MSYS2 packages for ngdevkit

## Nightly builds status

[![Nightly build for emudbg](https://img.shields.io/github/actions/workflow/status/dciabrin/msys2-ngdevkit/build.yaml?branch=nightly%2Femudbg&label=emudbg)](https://github.com/dciabrin/msys2-ngdevkit/actions/workflows/build.yaml?query=branch%3Anightly%2Femudbg)
[![Nightly build for ngdevkit-gngeo](https://img.shields.io/github/actions/workflow/status/dciabrin/msys2-ngdevkit/build.yaml?branch=nightly%2Fngdevkit-gngeo&label=ngdevkit-gngeo)](https://github.com/dciabrin/msys2-ngdevkit/actions/workflows/build.yaml?query=branch%3Anightly%2Fngdevkit-gngeo)
[![Nightly build for ngdevkit-toolchain](https://img.shields.io/github/actions/workflow/status/dciabrin/msys2-ngdevkit/build.yaml?branch=nightly%2Fngdevkit-toolchain&label=ngdevkit-toolchain)](https://github.com/dciabrin/msys2-ngdevkit/actions/workflows/build.yaml?query=branch%3Anightly%2Fngdevkit-toolchain)
[![Nightly build for ngdevkit](https://img.shields.io/github/actions/workflow/status/dciabrin/msys2-ngdevkit/build.yaml?branch=nightly%2Fngdevkit&label=ngdevkit)](https://github.com/dciabrin/msys2-ngdevkit/actions/workflows/build.yaml?query=branch%3Anightly%2Fngdevkit)

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dciabrin/msys2-ngdevkit/rebuild-repository.yaml?label=MSYS2 repository)](https://github.com/dciabrin/msys2-ngdevkit/actions/workflows/rebuild-repository.yaml)


## Description

This git repository contains a collection of PKGBUILD files that are
consumed by ngdevkit CI to produce nightly packages for MSYS2. The
packages target the UCRT64 subsystem, which means they provide native
Win10 binaries with no runtime dependencies on MSYS2.

You can consume those packages directly in your MSYS2 environment by
adding the ngdevkit MSYS2 repository in your `/etc/pacman.conf`:

    [ngdevkit]
    SigLevel = Optional TrustAll
    Server = https://dciabrin.net/msys2-ngdevkit/\$arch

Have a look at the [ngdevkit repository](https://github.com/dciabrin/ngdevkit)
for a detailed documentation on how to install those packages and use them to build
and run some example ROMs.


## Discussion

Please send feedbacks and report bugs to the main [ngdevkit repository](https://github.com/dciabrin/ngdevkit/issues).
