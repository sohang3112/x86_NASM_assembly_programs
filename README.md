Syscalls, registers etc. differ in 32-bit and 64-bit assembly in Linux.

Running:

```bash
$ cd linux/
$ ./run.sh /path/to/program.asm
```

## Resources

- [NASM x86 Assembly Cheatsheet](https://www.cs.uaf.edu/2010/fall/cs301/support/x86/index.html)
- [Linux ELF Manpage](https://man7.org/linux/man-pages/man5/elf.5.html) - 
  eg. sections (required & optional) are listed under line *Various sections hold program and control information* - here I made table (most to least relevant for me):

Section    | Description
---------- | ------------------------------------------------------
`.text`    | Main executable code
`.data`    | Mutable global variables
`.bss`     | Uninitialized data (zero initialized at program start)
`.rodata`  | Read-only constants
`.ini`     | Initialization code (eg. runtime setting up environment, running constructors of global variables)
`.fini`    | Finalization code run after `exit()` is called (eg. flushing buffers, global destructors)
`.interp`  | Pathname of program interpreter (if any)
`.ctors`   | Initialized pointers to C++ constructor functions 
`.dtors`   | Initialized pointers to C++ destructor functions
`.line`    | Line numbers for symbolic debugging
`.comment` | Version control information

OMITTED SECTIONS (not useful for me):
* `.data1`, `.rodata1`, `.shstrtab`, `.note`, `.note.ABI-tag`, `.note.gnu.build-id`, `.note.GNU-stack`, `.note.openbsd.ident`
* dynamic linker: `.dynamic`, `.dynstr`, `.dynsym`, `.got` (Global Offset Table: addresses of dynamically linked functions), `.hash` (Symbol Hash table for addresses of dynamically linked variables), `.plt` (Procedure Linking Table), `.relNAME`, `.relaNAME`, `.strtab` (symbol table name strings), `.symtab` (Symbol Table)
* GNU: `.gnu.version`, `.gnu.version.d`, `.gnu.version.r`

Registers:
- General-Purpose Registers (16): `rax`, `rbx`, `rcx`, `rdx`, `rsi`, `rdi`, `rbi`, `rsp`, `r8` ... `r15`
- Floating Point Registers (8): `xmm0` .. `xmm7`

C Function Calling Convention (NOT SURE, also Linux syscalls don't seem to follow this?):
- Input arguments in order: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, rest pushed on stack
- Return: `rax`, rest TODO

In variable declarations in constants:

Data Type | Description
--------- | ------------
`db`      | TODO
`resb`    | TODO
`equ`     | compile-time int constant (i.e. takes no space in memory (RAM))

Int constants can be defined using both `%define` macros and `equ`, but `equ` ones get added as symbols inside ELF binary (so useful if we want linker to see these symbols).

## Learning Roadmap for x86-64 Assembly

This was suggested in a Reddit comment:

1. Read the data sheet for the Intel 8008 processor. 
   No need to write any code or go into detail. 
   Just absorb the fact that there are registers named A, B, C, D, E, H and L, and four 1-bit flags (Carry, Parity, Zero, Sign).
2. Now read the instruction set reference for Intel 8086/8088 processors. 
   This is the fundamental basis you need for x86 assembly, since it's the first x86 chip. 
   At this point you probably want to write some code to get used to operating on data, especially interesting instructions like (I)MUL and DIV, 
   the various jump instructions and the various addressing modes.
3. Look at floating point coprocessors and figure out the stack model and how they work. 
   Don't spend too much time on this, but you should be familiar with it.
4. Move on to the 386 so you understand the "extended" registers, and 32-bit addressing. 
   Write more code. Port your previous code to 32-bits, for example. 
   Now start paying attention to calling conventions, like pascal convention, C convention, and especially fastcall.
5. Now start looking into the MMX and SIMD extensions. 
   These add more registers and a boatload of new instructions for operating on multiple data at the same time. 
   This is really, REALLY useful for writing hand-optimized computer graphics code.
6. Now jump to x64. 
   By now it won't be such a shock when you see something like RAX and R8 and wonder why they are named so differently and behave slightly differently. 
   Also, the calling convention is REALLY confusing unless you have understood all of the previous processors, instruction set extensions, and calling conventions. 
   This is the real reason why you have to do all of the previous steps before you get here.
