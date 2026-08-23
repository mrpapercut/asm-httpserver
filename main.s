.intel_syntax noprefix

.section .text

.global _start
.type _start, @function

_start:
    mov rdi, 0
    call exit
