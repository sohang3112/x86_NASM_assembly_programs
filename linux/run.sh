#!/bin/bash
set -e         # terminate script if any error

if [[ $# != 1 ]]; then    # wrong number of arguments
    echo "Usage: run.sh /path/to/program.asm"
    exit 1
fi

bname="${1##*/}"         # filename with extension (rm path */ by keeping text only after last /)
name="${bname%.*}"              # filename without extension
echo "$name"

mkdir -p bin/        # make output directory if not exists
trap 'echo "Deleting bin/ ..." && rm -r bin/' EXIT     # delete bin/ (having object file *.o and binary ELF) at script exit irrespective of error

if [[ "$1" == *_64bit.asm ]]; then
    echo "Compiling & Linking for 64 bit assembly..."                 
    nasm -f elf64 "$1" -o "bin/$name.o"        # compile
    ld "bin/$name.o" -o "bin/$name"            # link                       
elif [[ "$1" == *_32bit.asm ]]; then
    echo "Compiling & Linking for 32 bit assembly..."
    nasm -f elf "$1" -o "bin/$name.o"           # compile
    ld -m elf_i386 "bin/$name.o" -o "bin/$name" # link
else
    echo "Expected filename to end with '_64bit.asm' or '_32bit.asm'."
    exit 1
fi

echo "Running Program..."
"bin/$name"       # run