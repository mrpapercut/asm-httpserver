.intel_syntax noprefix

.section .text
.global _start
.type _start, @function

_start:
    call create_socket

    mov r15, rax    # socket fd in rax, needed in rdi for bind

    mov rdi, r15
    call bind
    mov rdi, r15
    call listen

connect_loop:
    mov rdi, r15
    call accept

    # rax contains fd for accepted connection
    mov r14, rax

    mov rax, 57     # syscall 'fork'
    syscall

    test rax, rax   # if rax is zero, this is the child process
    jnz parent_process

    # close socket for client
    mov rax, 3
    mov rdi, r15
    syscall

    mov rdi, r14
    call handle_socket

    call exit_success

parent_process:
    mov rax, 3
    mov rdi, r14
    syscall

    jmp connect_loop

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
    mov rdi, r15    # file_descriptor
    mov rsi, rsp    # sockaddr -> struct on stack
    mov rdx, 16     # length of sockaddr
    syscall

    add rsp, 16     # Realign stack

    ret

listen:
    mov rax, 50     # syscall 'listen'
    mov rdi, r15     # file descriptor
    mov rsi, 0     # backlog -> max num of queued connections
    syscall

    ret

accept:
    mov rax, 43     # syscall 'accept'
    mov rdi, r15    # file descriptor
    mov rsi, 0      # NULL
    mov rdx, 0      # NULL
    syscall

    ret
