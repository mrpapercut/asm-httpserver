.intel_syntax noprefix

.section .text

.global _start
.type _start, @function

_start:
    call create_socket

    mov rdi, rax    # socket fd in rax, needed in rdi for bind
    call bind

    call listen     # socket fd should still be in rdi
    call accept     # socket fd should still be in rdi

    mov rdi, 0  # exit code
    call exit

create_socket:
    mov rax, 41 # syscall 'socket'
    mov rdi, 2  # family -> AF_INET -> IP protocol family
    mov rsi, 1  # type -> SOCK_STREAM
    mov rdx, 0  # protocol
    syscall

    ret

bind:
    sub rsp, 16     # Create stack space for struct
    mov WORD PTR [rsp], 0x2         # AF_INET -> 2
    mov WORD PTR [rsp+2], 0x5000    # 00 50 -> port 80
    mov QWORD PTR [rsp+4], 0x0000   # 0.0.0.0 as 4 zero bytes

    mov rax, 49     # syscall 'bind'
    #; mov rdi,     # file_descriptor, in rax from create_socket but already in rdi at this point
    mov rsi, rsp    # sockaddr -> struct on stack
    mov rdx, 16     # length of sockaddr
    syscall

    add rsp, 16     # Realign stack

    ret

listen:
    mov rax, 50     # syscall 'listen'
    #; mov rdi,     # file descriptor, should still be in rdi
    mov rsi, 0     # backlog -> max num of queued connections
    syscall

    ret

accept:
    mov rax, 43
    #; mov rdi,     # file descriptor, should still be in rdi
    mov rsi, 0
    mov rdx, 0
    syscall

    ret
