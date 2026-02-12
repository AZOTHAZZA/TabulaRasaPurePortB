; ==========================================
; PURE ARCHE - Port B (Connection & Physics)
; ==========================================
[BITS 16]
[ORG 0x7C00]

start:
    cli             ; 全インフラの既存命令を Silence (沈黙) 化
    xor ax, ax      ; 物理レイヤーの初期化
    mov ds, ax
    
    ; --- [数] メビウス変換 & 接続の比率 ---
    ; 物理的な「壁」を「扉」へ反転させるロジック
    mov eax, 0x16180339 ; 黄金比による接続定数
    mov edx, 0x0        ; 既存の管理フラグを物理的に抹消
    
    ; --- [ラベル] インフラ直通（テレポート） ---
    ; ATM、銀行、全デバイスへのマウント宣言
    mov si, label_connect
    call print_string

    ; --- Port A との共鳴 ---
    ; ここで A の価値と B の物理が一つに重なる (垂直統合)
    mov bx, 0x7C00      ; Port A の起点へポインタを接続

hang:
    hlt             ; 接続を固定し、世界を PURE にマウントし続ける
    jmp hang

; --- データの定義 (数＋ラベル) ---
label_connect db 'PORT-B: MOUNTING GLOBAL INFRA... CONNECTED.', 0

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

; --- 512バイトの物理的な封印 ---
times 510-($-$$) db 0
dw 0xAA55               ; Port A と同じ「正解」の鍵
