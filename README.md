# Syndicate
Syndicate is a simple 2-stage-bootloader.

## Important
Syndicate searches on the first partiton of the disk!
So you NEED to put the kernel on the first partition.
Syndicate only reads FAT32.

## Build
Building does work on every system where you can install nasm.

Just type ```make```.

The Makefile contains a run and a img option, mainly for testing.
The Code is platform specific for FreeBSD. If you're running Linux,
feel free to contribute your run-code to the Makefile.
