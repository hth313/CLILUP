(define memories
  '((memory CLILUP (position independent)
            (bank 1) (address (#x0 . #xFFF))
            (section (Header FAT FATend #x0) code RPN
                     (crc32table #x800)
                     (poll #xFF4))
            (checksum #xFFF hp41)
            (fill 0))))
