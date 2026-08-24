.intel_syntax noprefix

.section .text

.global exit_success, exit_failure
.type exit_success @function
.type exit_failure @function

exit_success:
    mov rdi, 0
    jmp exit

exit_failure:
    mov rdi, 1
    jmp exit

exit:
    mov rax, 60
    syscall
