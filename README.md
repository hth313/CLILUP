HP-41CL Update module using HP-IL
=================================

This module for the HP-41CL contains some instructions that allow reading
and writing 16-bit images to and from HP-IL mass storage devices.

In addition there is an RPN program that is used to control the process which
is better documented in the  [hp-41cl_update](https://github.com/isene/hp-41cl_update/)
project.


Background
----------

Traditionally, a ROM page in the HP-41 is 4K large. As it uses 10-bit
memory, there is a choice of compressing it when storing it to a byte oriented
file system. However, the `.rom` file format is an uncompressed memory page,
and uses 2 bytes for each memory location. Thus, it will normally have the
6 upper bits set to 0.

In the HP-41CL, the physical memory system is actually 16-bit wide, though it
only exposes 10-bit to the Nut CPU (logical memory). These previosuly unused
bits now have a meaning as they are used to control the speed of the faster
NEWT CPU to pace it in timing loops. Additionally, some special HP-41CL
modules make use of the extra bits for data purposes.

As a result, there is now a need to pass 16-bit ROM images to the HP-41CL.
The read and write instructions provided in this module makes it possible
to transfer such (uncompressed) 16-bit ROM images between the physical
memory of the HP-41CL and HP-IL mass storage.


Read and write instructions
---------------------------

The `RDROM16` instruction reads a physical memory page from HP-IL mass
storage to HP-41CL RAM memory.

The `WRROM16` instruction writes a physical memory page to HP-IL mass storage.

Both instructions expects a filename in the Alpha register and the physical
address page in X.

The physical address page is a 3-digit binary number, it can be specified
either as a BCD number or as a binary number (non normalized number, NNN).

To specify page `801` (hex), you can enter it as an ordinary number `801`.

If the address page contains hex digits above 9, for example `80E`, you
need to specify it as an NNN. This can be done in two ways, either enter the
address in Alpha register and use the traditional `CODE` instruction, or
load the Ladybug module, enable hex mode and type in the hex number in X.

Some examples:

To save page 810 (hex), enter filename in Alpha register and type:

    810 in X
    XEQ WRROM16

To load page 800 (hex), enter filename in alpha register and type:

    800 in X
    XEQ RDROM16


Details on the page numbers
---------------------------

In case you wonder about the X register input, recall how a floating
point number is represented in the HP-41

    S MMMMMMMMMM SXX

where `S` is the sign, `MMMMMMMMMM` is the mantissa and `SXX` is the
exponent with its sign.

If the mantissa is non-zero, the address is obtained by taking the first
3 digits of `MMMMMMMMMM` and treating that as a binary page address.
As these are BCD encoded digits, it means that if you enter `800`, it will
get treated the hex number `800`, in fact you can actually just type `8` as
it will appear at the first position and the rest of `MMMMMMMMMM` will be 0.
If you enter `800003`, it will still take the first 3 digits and treat that
as `800`.

If the mantissa is 0, `RDROM16` and `WRROM16` expects that `SXX` contains
a binary page address (12 bits).

To enter a binary page address you need to use `CODE`, which is a common
instruction from the good old days of the HP-41. It allows converting a hex
number in the Alpha register to a binary (non-normalized) number in X.

If you are using the PPC ROM, you can do as follows:

    ALPHA 8AF ALPHA       ; type in the page number
    XEQ HN                ; hex to NNN (works the same as `CODE`)
    ALPHA filename ALPHA
    XEQ RDROM16           ; read from file


An alternative way is to use the Ladybug module which uses binary integers
as its native numbers. This means that you can just enter the 3 digit hex
number in X from the keyboard:

    WSIZE 56              ; set word size to 56 bits
                          ; (any word size 12 or wider will work)
    ALPHA filename ALPHA
    8AF_           H      ; type the page number as `8AF`
    XEQ RDROM16           ; read from file


Error messages
--------------

There is a wide range of error messages that can result from using these instructions,
some are explained below.

- **NONEXISTENT**  is given if there is no HP-IL module attached

- **DATA ERROR**   is given if the address is outside allowed range
                   (the allowed range is `807` to `87F` inclusive)

- **SIZE ERR**     is given by `RDROM16` if the file size is not 8K bytes.
