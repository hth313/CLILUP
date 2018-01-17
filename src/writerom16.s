#include "mainframe.h"
#include "hpil.h"


;;; **********************************************************************
;;;
;;; writeRom16 - Write a physical 16-bit page (RAM or FLASH) in HP-41CL
;;;              memory to mass storage.
;;;
;;; Input: X - either a 12 bit binary number page right justified,
;;;            or; a BCD number (i.e 810) to be treated as 0x810.
;;;        ALPHA: filename
;;;
;;; **********************************************************************

              .section code
              .public writeRom16
              .extern findpil
              .name   "WRROM16"
writeRom16:   rxq     findpil
              c=0     s             ; check for dup file
              gosub   FLSCH
              ldi     ROM16FILE     ; file type (data file)
              gosub   RWCHK         ; check for overwrite

              c=0
              pt=     9
              lc      2             ; C[10:6]= number of bytes (02000 hex)
              pt=     4
              lc      4             ; C[5:2]= number of registers
                                    ;   (0x0400 = 0x2000 / 8)
              pt=     1
              lc      ROM16FILE     ; file type
              gosub   CRTFL0        ; create the file
              gosub   SEKSUB        ; seek to the file

              c=regn  X             ; get physical page to write
              ?c#0    m             ; BCD data?
              gonc    5$            ; no
              rcr     10            ; yes, align with C.X
              c=0     m
5$:           c=0     s
              rcr     -9            ; C= 00PPP000000000
              pt=     4             ; read physical address command
              lc      5             ; C= 00PPP000050000
              a=c                   ; A= 00PPP000050000

              ldi     0x10
              dadd=c                ; deselect RAM
              ldi     0xf0          ; select NEWT peripheral
              pfad=c

              hpl=ch  1             ; write control int register
              ch=     1             ; enable FI line (bit 0)

              pt=     0
              s9=     0             ; clear error flag

10$:          acex    m
              wcmd                  ; read from physical memory
              rcr     6
              c=c+1                 ; increment physical memory address
              rcr     -6
              acex    m
              c=regn  2             ; get wcmd read data
              g=c                   ; G= low byte
              rcr     2             ; C[1:0]= high byte
              gosub   SDATA
              ?s9=1                 ; any errors?
              goc     90$           ; yes
              c=g                   ; C[1:0]= low byte
              gosub   SDATA
              ?s9=1                 ; any errors?
              goc     90$           ; yes

              a=a+1   x
              gonc    10$

              gosub   ENCP00        ; disable NEWT peripheral
              golong  SNDRDN        ; close file and return

90$:          golong  CSERCK        ; error check (this will display
                                    ;  an error and also call ENCP00)
