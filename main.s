.intel_syntax noprefix

.section .text

.global _start
.type _start, @function

_start:
    call create_socket

    mov rdi, 0
    call exit

create_socket:
    mov rax, 41 # 'socket' syscall
    mov rdi, 2  # family -> AF_INET -> IP protocol family
    mov rsi, 1  # type -> SOCK_STREAM
    mov rdx, 0  # protocol
    syscall

    ret
