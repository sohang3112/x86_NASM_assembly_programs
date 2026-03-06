; Print hello world in Linux (32-bit program): https://www.secureideas.com/blog/2021/05/linux-x86-assembly-how-to-build-a-hello-world-program-in-nasm.html

global _start    ; global is used to export .start symbol

section .data
   msg: db "Hello, World!",0xa ; 0xa = "\n"
   len: equ $-msg       ; current offset - msg offset - gives string length

section .text          ; executable code in .text
_start:
   ; syscall - write(1, msg, len)
   mov eax, 4     ; 4 = Syscall number for Write()
   mov ebx, 1     ; write to file descriptor STDOUT = 1
   mov ecx, msg   ; pointer to string
   mov edx, len   ; len of string is 14 here
   int 0x80       ; syscall (raise interrupt)

   ; syscall - exit(0);
   mov al, 1      ; Syscall for Exit()
   mov ebx, 0     ; The status code we want to provide.
   int 0x80       ; Poke kernel. This will end the program
