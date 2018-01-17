#include "mainframe.h"

              .section Header
              .extern readRom16, writeRom16

              .public `FAT entry: RDROM16`
              .public `FAT entry: FUPDATE`
              .public `FAT entry: HFUPDAT`
              .extern FUPDATE, HFUPDAT

XROMno:       .equ    14

              .con    XROMno        ; XROM number
              .con    .fatsize FatEnd ; number of entry points
FatStart:
              .fat    Header        ; ROM header
`FAT entry: RDROM16`:
              .fat    readRom16
              .fat    writeRom16
`FAT entry: FUPDATE`
              .fatrpn FUPDATE
`FAT entry: HFUPDAT`
              .fatrpn HFUPDAT

              .section FATend
FatEnd:       .con    0,0


;;; ************************************************************
;;;
;;; ROM header.
;;;
;;; ************************************************************

              .section code

              .name   "-CLILUP 1B" ; The name of the module
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
              .text   "B1UL"        ; Identifier LU-1B
              .con    0             ; checksum position
