[org 0x7c00]

; --- 画面初期化とGitHub風UI ---
xor ax, ax
mov ds, ax
mov es, ax
mov ax, 0x0003      ; 80x25 テキストモード
int 0x10
mov ax, 0xb800
mov gs, ax

; 画面全体の背景を整える
call draw_ui_frame

call init_port_b

; --- メイン受信ループ ---
main_receive_loop:
    call receive_byte
    cmp al, 'P'         ; PURE パケット検知
    je .handle_pure
    jmp main_receive_loop

.handle_pure:
    call receive_dword  ; EBXに100億RATIO等の数値を受容
    
    ; 表示位置の設定 (中央付近)
    mov di, 160 * 10 + 20
    mov esi, msg_pure
    call print_string_cyan
    
    ; 数値を表示 (十進数変換執行)
    mov eax, ebx
    call print_number_dec
    jmp main_receive_loop

; --- 物理層: シリアル通信ルーチン ---
init_port_b:
    mov dx, 0x3fb
    mov al, 0x80        ; DLAB ON
    out dx, al
    mov dx, 0x3f8
    mov al, 0x01        ; 115200 bps (最も純粋な速度)
    out dx, al
    mov dx, 0x3f9
    xor al, al
    out dx, al
    mov dx, 0x3fb
    mov al, 0x03        ; 8N1
    out dx, al
    ret

receive_byte:
    mov dx, 0x3fd
.wait:
    in al, dx
    test al, 0x01
    jz .wait            ; データが来るまで1/zの静寂で待機
    mov dx, 0x3f8
    in al, dx
    ret

receive_dword:
    ; 4バイトを結合してEBXに格納
    xor ebx, ebx
    call receive_byte
    mov bl, al
    call receive_byte
    mov bh, al
    shl ebx, 16
    call receive_byte
    mov bl, al
    call receive_byte
    mov bh, al
    ror ebx, 16         ; エンディアン調整
    ret

; --- 数値レンダリング: 十進数 ASCII 変換 ---
print_number_dec:
    mov cx, 0
    mov ebx, 10
.divide:
    xor edx, edx
    div ebx
    push dx             ; 余り（各桁）をスタックへ
    inc cx
    test eax, eax
    jnz .divide
.display:
    pop ax
    add al, '0'
    mov ah, 0x0F        ; 白文字属性
    mov [gs:di], ax
    add di, 2
    loop .display
    ret

; --- 描画補助 ---
print_string_cyan:
    mov ah, 0x03        ; シアン（PUREカラー）
.loop:
    lodsb
    or al, al
    jz .done
    mov [gs:di], ax
    add di, 2
    jmp .loop
.done:
    ret

draw_ui_frame:
    ; ヘッダー描画
    mov di, 0
    mov esi, msg_header
    mov ah, 0x1F        ; 青背景・白文字
.h_loop:
    lodsb
    or al, al
    jz .h_done
    mov [gs:di], ax
    add di, 2
    jmp .h_loop
.h_done:
    ret

; --- データセクション ---
msg_header db " PURE-OS v1.0 | PORT-B: TRADING TERMINAL | LOGOS SYNCED                 ", 0
msg_pure   db "PURE (RATIO): ", 0

times 510-($-$$) db 0
dw 0xaa55
