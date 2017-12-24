#include "mainframe.i"
#include "hpil.i"

;;; **********************************************************************
;;;
;;; readRom16 - Read a 16-bit ROM from mass storage to a page in HP-41CL
;;;             RAM area (in the 0x807-0x87f range).
;;;
;;; Input: X - either a 12 bit binary number page right justified,
;;;            or; a BCD number (i.e 810) to be treated as 0x810.
;;;
;;; **********************************************************************

              .section code
              .public readRom16
              .name   "RDROM16"
readRom16:    rxq     findpil

;;; Search for the file, this is done before checking input in X as FLSCH0
;;; clobbers A, B, C, M, N...

              ldi     ROM16FILE     ; file type
              gosub   FLSCH0        ; search file
              gosub   SEEKRN        ; seek and read first record

              c=n                   ; C[3:0]= file size in registers
                                    ;   (one reg is 8 bytes)
              a=c
              c=0
              ldi     0x3ff
              c=c+1                 ; C= 0400 (0x1000 * 2 / 8)
              pt=     3
              ?a#c    wpt           ; check file size
              gonc    15$           ; good
              gosub   PLEREX        ; wrong size (the SIZE ERR entry in PIL is
              .messl  "SIZE"        ;  not public, and there are many versions
              golong  DSPERR        ;  of that module...)

;;; Now we can validate we have a good RAM page to put it in.

15$:          c=regn  X             ; allow 807 - 87F, the user RAM area
              ?c#0    m             ; binary entry?
              gonc    5$            ; yes
              rcr     10            ; no, a BCD number, right justify it
              c=0     m             ; keep tree digits (12 bits).
5$:           c=0     s
              m=c                   ; M.X= 00000000000PPP
              a=c
              c=0
              pt=     2
              lc      8
              lc      0
              lc      7
              a=a-c
              goc     95$           ; < 807, DATA ERROR
              ldi     1 + 0x87f - 0x807
              a=a-c
              gonc    95$           ; > 87F, DATA ERROR

              c=m                   ; C= 00000000000PPP
              rcr     -9            ; C= 00PPP000000000
              pt=     4
              lc      4             ; write physical address cmd
              a=c                   ; A= ..PPP000.4.000
                                    ; A.X is used as counter for 4096
                                    ; words to transfer

              s9=0                  ; reset error flag
              gosub   SNDATA        ; send the data
              pt=     3

20$:          gosub   RDDFRM        ; read a high data frame (byte)
              ?s9=1                 ; any error?
              goc     90$           ; yes, abort
              hpil=c  2             ; no, echo frame just read
              rcr     -2
              bcex                  ; B[3:2]= high byte
              gosub   RDDFRM        ; read low byte
              ?s9=1                 ; any error?
              goc     90$           ; yes, abort
              hpil=c  2             ; no, echo frame just read
              c=b     xs
              bcex    x             ; B[3:0]= DDDD (16 bit ROM word)
              acex    m             ; C= ..PPPXXX.4....
              c=b     wpt           ; C= ..PPPXXX.4DDDD
              wcmd
              rcr     6             ; increment physical memory address
              c=c+1
              rcr     -6
              a=c     m             ; save back
              a=a+1   x             ; update page counter
              gonc    20$           ; not done

90$:          golong  UNTCHK        ; untalk and check for errors

;;; DATA ERROR is detected after we set up the mass storage as talker, so tell
;;; it to forget about it, then report the error.
95$:          gosub   UNT           ; untalk
              golong  ERRDE         ; DATA ERROR


;;; **********************************************************************
;;;
;;; findpil - Ensure there is an HP-IL module inserted.
;;;
;;; **********************************************************************
              .section code
              .public findpil
findpil:      c=0                   ; check for existence of HP-IL module
              gosub   CHKCST
              ?c#0
              rtnc
              spopnd
              golong  ERRNE         ; NONEXISTENT if not present
