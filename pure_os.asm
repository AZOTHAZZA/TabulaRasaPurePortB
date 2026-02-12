[org 0x7c00]

start:
    ; 1. 画面初期化
    mov ax, 0x0003
    int 0x10

    ; 2. UART初期化 (9600bps)
    mov dx, 0x3fb
    mov al, 0x80
    out dx, al
    mov dx, 0x3f8
    mov al, 0x0c
    out dx, al
    mov dx, 0x3fb
    mov al, 0x03
    out dx, al

    ; 初期表示
    mov si, boot_msg
    call draw_matrix

main_loop:
    mov di, currency_buffer
.recv_wait:
    ; --- ここが「耳」の役割 ---
    mov dx, 0x3fd       ; Line Status Register
    in al, dx
    test al, 0x01       ; データが届いたかチェック
    jz .recv_wait       ; 届くまでここで「超高速回転」して待つ
    
    mov dx, 0x3f8       ; Receiver Buffer Register
    in al, dx           ; 文字を強奪

    ; Enter系ならバッファをクリアして再待機
    cmp al, 13
    je main_loop
    cmp al, 10
    je main_loop
    
    ; 1文字でも来たら即座に受肉
    stosb
    mov byte [di], 0
    mov si, currency_buffer
    call draw_matrix    ; 画面を塗り替える
    jmp .recv_wait

draw_matrix:
    pusha
    mov dh, 5
.line:
    mov bh, 0x00
    mov dl, 30
    mov ah, 0x02
    int 0x10
    
    ; 前の文字を消すための空白を先行射出
    push si
    mov si, cls_msg
    call print_str
    pop si

    mov ah, 0x02
    int 0x10
    call print_str      ; SI(現在地)を表示
    inc dh
    cmp dh, 12
    jl .line
    popa
    ret

print_str:
    mov ah, 0x0E
    mov bl, 0x03
.lp:
    lodsb
    or al, al
    jz .dn
    int 0x10
    jmp .lp
.dn:
    ret

boot_msg db 'READY..', 0
cls_msg  db '                ', 0
currency_buffer equ 0x8000

times 510-($-$$) db 0
dw 0xAA55
