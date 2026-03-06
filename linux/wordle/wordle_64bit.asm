; Wordle game implemented with direct system calls, does not depend on C stdlib

; ANSI escape sequences (control, color codes etc.): https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
%define CURSOR_UP ESCAPE, "[1A"

section .rodata        ; read-only constants   
    wordsFilename: db "wordle/wordle_words.txt", NULL      ; path relative to linux/ (won't work from anywhere else) ; TODO: make this general so works from anywhere
    totalWords: equ 3103        ; number of words in file (1 word per line)    

    overwrite: db CURSOR_UP, CARRIAGE_RETURN, "abcde", NEWLINE    ; cursor up, to line begin, overwrite, newline -- NOTE: abcde is just a hardcoded testing string, remove later
    overwriteLen: equ $-overwrite

    notAWordError: db "NOT A WORD", NEWLINE
    notAWordErrorLen: equ $-notAWordError

    fileErrorExitMsg: db "Failed to open file wordle_words.txt to load all 5-letter words", NEWLINE
    fileErrorExitMsgLen: equ $-fileErrorExitMsg

    winMsg: db "You won by guessing correct word!", NEWLINE
    winMsgLen: equ $-winMsg

    lostMsg: db "You lost - no more attempts left. Correct word is ?????", NEWLINE       ; correct word to be filled in place of ????? at runtime using memcpy
    lostMsgLen: equ $-lostMsg

    ; system call codes
    SYS_READ: equ 0
    SYS_WRITE: equ 1
    SYS_OPEN: equ 2
    SYS_CLOSE: equ 3
    SYS_LSEEK: equ 8
    SYS_EXIT: equ 60

    ; file handles
    STDIN: equ 0
    STDOUT: equ 1

    ; file fopen() flags
    O_RDONLY: equ 0

    ; file seek modes: absolute, relative etc.
    SEEK_ABSOLUTE: equ 0

    ; characters' ASCII Codes: https://www.ascii-code.com/
    NULL: equ 0
    BACKSPACE: equ 8
    NEWLINE: equ 10
    CARRIAGE_RETURN: equ 13        ; moves cursor to beginning of line
    ESCAPE: equ 27

    ; game config
    WORD_SIZE: equ 5
    ALL_WORDS_SIZE: equ (WORD_SIZE + 1) * totalWords

section .bss          ; uninitialized global variables
    ; Both are const char[]
    computerWord: resb WORD_SIZE
    userWord: resb WORD_SIZE + 1       ; extra character at end for newline
    allWords: resb ALL_WORDS_SIZE      ; whole file contents of wordle_words.txt will be loaded in this

; section .data         ; initialized global variables - not required here
    
section .text         ; executable code
    global _start   

_start:           ; NOT A FUNCTION (no ret, since nothing to return to)
    mov dword [userWord + WORD_SIZE], NEWLINE          ; put \n in last (extra) char of userWord for printing

    call loadAllWords
    call randomComputerWord

    ; userWord = finput(STDIN, userWord, WORD_SIZE)
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, userWord
    mov rdx, WORD_SIZE
    syscall
    
    mov rax, SYS_WRITE       
    mov rdi, STDOUT     
    mov rsi, overwrite
    mov rdx, overwriteLen
    syscall    

    ; print userWord
    mov rax, SYS_WRITE       
    mov rdi, STDOUT     
    mov rsi, userWord
    mov rdx, WORD_SIZE + 1      ; extra char for newline
    syscall    

    ; TODO: check if userWord matches computerWord (or if not, which characters are same, which characters are right but at wrong positions, which characters are completely wrong)
    ; overwrite prev line, show each character foreground white, background color (green - letter in correct spot, yellow - letter in wrong spot, grey - letter not in word)

    ; TODO: also check if userWord is valid (i.e. present in allWords global var)
    ;  use simple hash: convert 5-letter lowercase word to a 5-digit base-26 int (this requires just log2(26^5) = 23 total bits)
    ;  instead of saving allWords, pre-compute hashes of all words into an int array allWordHashes (this is automatically sorted as original words are sorted)
    ;  calc userWord hash, check if exists in allWordHashes using binary search

    ; TODO: mk case-insensitive (lowercase userWord beforehand)

    ; exit(0) if success
    mov rax, SYS_EXIT      
    xor rdi, rdi                    
    syscall   

randomComputerWord:           ; fn () -> void; saves a random word into global var computerWord
    ; rax = random 64-bit int
    random_gen: rdrand rax
    jnc random_gen         ; jump if no carry (CF=0) to retry in loop

    ; rax = rax % totalWords
    ; mov rax,   ; quotient (already in rax)
    xor rdx, rdx  ; must be zeroed before unsigned division
    mov rcx, totalWords
    div rcx  ; result in rax:rdx (quotient:remainder)

    mov rax, rdx       
    inc rax           ; make it 1-based word index
    add rax, computerWord       ; pointer to chosen random word

    ; copy word from file into computerWord global var
    mov rcx, WORD_SIZE
    mov rsi, rax     ; source char* pointer (inside allWords string)
    mov rdi, computerWord     ; destination char*
    rep movsb         ; Copy bytes: copy rcx bytes from rsi to rdi

    ret
    
loadAllWords:      ; fn () -> void; saves wordle_words.txt into global var
    ; r8 = fopen(filename, flags=O_RDONLY)
    mov rax, SYS_OPEN
    mov rdi, wordsFilename   ; null-terminated char* string
    mov rsi, O_RDONLY
    syscall

    test rax, rax       ; test does bitwise AND, but without saving its result (only saves Sign Flag)
    js fileErrorExit    ; error if rax (returned by SYS_OPEN) is negative, i.e. Sign Flag is set to 1
    mov r8, rax         ; save file descriptor

    ; read whole file
    mov rax, SYS_READ
    mov rdi, r8         ; file descriptor
    mov rsi, allWords
    mov rdx, ALL_WORDS_SIZE
    syscall

    ; fclose(r8)
    mov rax, SYS_CLOSE
    mov rdi, r8          ; file descriptor
    syscall

    ret  

fileErrorExit:    ; NOT A FUNCTION (i.e. jump here not call)
    ; print fileErrorExitMsg
    mov rax, SYS_WRITE       
    mov rdi, STDOUT     
    mov rsi, fileErrorExitMsg
    mov rdx, fileErrorExitMsgLen
    syscall 

    ; exit(1)
    mov rax, SYS_EXIT      
    mov rdi, 1                  
    syscall   


         
                                      
                    
                    
                    
                    
                    
                    
                    