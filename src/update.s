#include "mainframe.i"

              .section Header
              .public `FAT entry: RDROM16`
              .extern readRom16, writeRom16
XROMno:       .equ    14

              .con    XROMno        ; XROM number
              .con    .fatsize FatEnd ; number of entry points
FatStart:
              .fat    Header        ; ROM header
`FAT entry: RDROM16`:
              .fat    readRom16
              .fat    writeRom16

              .section FATend
FatEnd:       .con    0,0


;;; ************************************************************
;;;
;;; ROM header.
;;;
;;; ************************************************************

              .section code

              .name   "-CLILUP 1A" ; The name of the module
Header:       rtn


;;; **********************************************************************
;;;
;;; Poll vectors, module identifier and checksum
;;;
;;; **********************************************************************

              .section poll
              .con    0             ; Pause
              .con    0             ; Running
              .con    0             ; Wake w/o key
              .con    0             ; Powoff
              .con    0             ; I/O
              .con    0             ; Deep wake-up
              .con    0             ; Memory lost
              .text   "A1UL"        ; Identifier LU-1A
              .con    0             ; checksum position
