.intel_syntax noprefix

.section .rodata
http_response:
    .asciz "HTTP/1.0 200 OK\r\n\r\n"

.text

.global handle_socket
.type handle_socket, @function

# input:
# rdi = socket fd

handle_socket:
    mov r12, rdi    # store socket fd for reuse in r12

    call read_request
    call process_request
    call write_response
    call close_request

    ret

read_request:
    mov rax, 0      # syscall 'read'
    mov rdi, r12    # file descriptor

    sub rsp, 1024   # create stack space for buffer
    mov rsi, rsp    # buffer
    mov rdx, 1024   # length
    syscall

    add rsp, 1024   # realign stack pointer

    ret

process_request:
    mov rdx, rax    # length from 'read'
    mov rax, 1      # syscall 'write'
    mov rdi, 1      # stdout
                    # rsi already contains the read buffer
    syscall

    ret

write_response:
    mov rax, 1      # syscall 'write'
    mov rdi, r12
    lea rsi, [rip + http_response]    # buffer
    mov rdx, 19     # length
    syscall

    ret

close_request:
    mov rax, 3      # syscall 'close'
    mov rdi, r12    # file descriptor
    syscall

    ret
