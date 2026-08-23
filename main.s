.intel_syntax noprefix

.section .rodata
http_response:
    .asciz "HTTP/1.0 200 OK\r\n\r\n"


.text
.global _start
.type _start, @function

_start:
    call create_socket

    mov rdi, rax    # socket fd in rax, needed in rdi for bind
    call bind

    call listen     # socket fd should still be in rdi
    call accept     # socket fd should still be in rdi

    # rax contains fd for accepted socket
    mov rdi, rax
    call read_request
    call write_response
    call close_request

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
    mov rax, 43     # syscall 'accept'
    #; mov rdi,     # file descriptor, should still be in rdi
    mov rsi, 0      # NULL
    mov rdx, 0      # NULL
    syscall

    ret

read_request:
    mov rax, 0      # syscall 'read'
    #; mov rdi,     # file descriptor, should still be in rdi
    sub rsp, 256    # create stack space for buffer
    mov rsi, rsp    # buffer
    mov rdx, 256    # length
    syscall

    add rsp, 256    # realign stack pointer

    ret

write_response:
    mov rax, 1      # syscall 'write'
    lea rsi, [rip + http_response]    # buffer
    mov rdx, 19     # length
    syscall

    ret

close_request:
    mov rax, 3      # syscall 'close'
    #; mov rdi,     # file descriptor, should still be in rdi
    syscall

    ret
