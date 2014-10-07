dvdxplode
=========

Small but useful Perl script to extract all titles or chapters of a DVD to
separate vob files.

Installation
============

This script requires no installation; just clone this repository and use it
from there.

You may need to first install libdvdread (including development headers), the
DVD::Read perl module from CPAN, and depending on use case, possibly libdvdcss.

Usage
=====

To extract all titles to separate files named like `dvdtitle1.vob`,
`dvdtitle2.vob`, ...:

```
./dvdxplode.pl /dev/sr0 dvdtitle%d.vob
```

To extract all chapters to separate files named like `dvdtitle1-chapter01.vob`,
`dvdtitle1-chapter02.vob`, `dvdtitle2-chapter01.vob`, ...:

```
./dvdxplode.pl /dev/sr0 dvdtitle%d-chapter%02d.vob
```

As you see, the mode of operation is decided by the number of printf
placeholders in the output file name - typically you will only ever want to use
`%d` for a number with no leading zeros, and `%02d` for exactly two digits,
possibly with a leading zero.

To automatically encode all these output files to iPhone 4-compatible mp4 files
using mpv:

```
./dvdxplode.pl /dev/sr0 dvdtitle%d-chapter%02d.vob | while IFS= read -r vob; do
  mpv "$vob" -o "${vob%.*}.mp4" -profile enc-to-iphone-4
  rm -f "$vob"
done
```

That's all!

Copyright
=========

This is free and unencumbered software released into the public domain.

For more information, please refer to the included file LICENSE and
http://unlicense.org
