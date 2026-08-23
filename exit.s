.intel_syntax noprefix

.section .text

.global exit
.type exit, @function

exit:
    mov rax, 60
    syscall
