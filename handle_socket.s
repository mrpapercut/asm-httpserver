.intel_syntax noprefix

.section .rodata
http_response:
    .asciz "HTTP/1.0 200 OK\r\n\r\n"

.section .bss
request_buf:    .skip 1024
path_buf:       .skip 256
file_buf:       .skip 4096

.text

.global handle_socket
.type handle_socket, @function

# input:
# rdi = socket fd

handle_socket:
    push r12
    mov r12, rdi    # store socket fd for reuse in r12

    call read_request
    call process_request
    #; call write_response
    call close_request

    pop r12
    ret

read_request:
    mov rax, 0      # syscall 'read'
    mov rdi, r12    # file descriptor

    lea rsi, [rip + request_buf]    # buffer
    mov rdx, 1024   # length
    syscall

    ret

process_request:
    #; [operation][space][path][space][HTTP version][\r\n][strings delimited \r\n][\r\n]
    #; shortest possible is `GET / HTTP/1.1\r\n\r\n` (16 bytes)
    cmp rax, 16
    jl exit_failure

    cmp DWORD PTR [rsi], 0x20544547 # ' TEG'
    je process_get_request

    #; cmp DWORD PTR [rdi], 0x54534F50 # 'TSOP'
    #; je process_post_request

    #; mov rdx, rax    # length from 'read'
    #; mov rax, 1      # syscall 'write'
    #; mov rdi, 1      # stdout
                    # rsi already contains the read buffer
    #; syscall

    #; ret

process_get_request:
    #; read rdi[4+n] until 4+n == 0x20

    xor rax, rax    # clear rax because we're using it
    mov rcx, 0x4    # prepare counter
    lea r13, [rip + path_buf]

read_path_loop:
    cmp BYTE PTR [rsi+rcx], 0x20
    mov BYTE PTR [r13+rcx], 0x0
    je read_path_file

    mov al, BYTE PTR [rsi+rcx]
    mov BYTE PTR [r13+rcx], al
    inc rcx
    jmp read_path_loop

read_path_file:
    #; r13 is path-buffer
    #; rcx is length of path-buffer
    mov r14, rcx

    #; open file
    mov rax, 2      # syscall 'open'
    mov rdi, r13    # filename
    add rdi, 4      # flag starts at index 4
    mov rsi, 0      # readonly
    syscall

    #; read file
    mov rdi, rax    # fd from read
    mov rax, 0      # syscall 'read'
    lea rsi, [rip + file_buf]
    mov rdx, 4096

    syscall

    mov r14, rax    # length of read buffer
    mov r8, rsi     # read buffer

    mov rax, 3      # syscall 'close'
                    # rdi already contains fd
    syscall

    jmp write_http_ok

write_http_ok:
    mov rax, 1      # syscall 'write'
    mov rdi, r12
    lea rsi, [rip + http_response]
    mov rdx, 19
    syscall

write_response:
    mov rax, 1      # syscall 'write'
    mov rdi, r12    # socket fd
    mov rsi, r8     # read buffer
    mov rdx, r14    # length of buffer
    syscall

    ret

close_request:
    mov rax, 3      # syscall 'close'
    mov rdi, r12    # file descriptor
    syscall

    ret
