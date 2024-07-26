;; Copyright (c) 2020, Florian Büstgens
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;     1. Redistributions of source code must retain the above copyright
;;        notice, this list of conditions and the following disclaimer.
;;
;;     2. Redistributions in binary form must reproduce the above copyright notice,
;;        this list of conditions and the following disclaimer in the
;;        documentation and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
;; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; write.inc
;; Routines to output strings to TTY

;; How to use:
;;
;; mov word [writer_msg], ax ; If your message is in ax
;; call write
;;

_string_writer_loop:
	call _char_writer
_string_writer:
	lodsb		        ; Load byte into al
	cmp al, 0		; If al is not 0, not every char was written
	jne _string_writer_loop ; So call _char_writer
	add byte [ypos], 1	; Carriage Return
	mov byte [xpos], 0
	
	ret

_char_writer:
	mov ah, 0x0F		; Setting color
	mov cx, ax		; Save
	movzx ax, byte[ypos]	; set offsets
	mov dx, 160
	mul dx
	movzx bx, byte[xpos]	; set offsets
	shl bx, 1
	mov di, 0		; Address of vga memory
	add di, ax		; get offsets
	add di, bx		; get offsets

	mov ax,cx		; Restore
	stosw			; Write
	add byte [xpos], 1	; Add space for the next char

	ret
write:
	mov byte [ypos], 0
	mov byte [xpos], 0
	mov si, hstr
	mov cx, 4
_write_loop:
	rol ax, 4
	mov bx, ax
	and bx, 0x0F
	mov bl, [si + bx]
	mov [di], bl
	inc di
	dec cx
	jnz _write_loop
	
	mov si, writer_result
	call _string_writer

	mov byte [writer_msg], 0 ; Clear
	mov byte [writer_result], 0
	
	ret
	
xpos db 0
ypos db 0
hstr db '0123456789ABCDEF'
writer_result db '0000', 0      ; register string
writer_msg dw 0			; Our message
