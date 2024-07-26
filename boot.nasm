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

;;  ____                  _ _           _
;; / ___| _   _ _ __   __| (_) ___ __ _| |_ ___
;; \___ \| | | | '_ \ / _` | |/ __/ _` | __/ _ \
;;  ___) | |_| | | | | (_| | | (_| (_| | ||  __/
;; |____/ \__, |_| |_|\__,_|_|\___\__,_|\__\___|
;;        |___/

;; Syndicate BOOTLOADER
;;
;; Stage 1
;;
	
[BITS 16]
[ORG 0x7C00]

jmp short start

start:
	jmp 0:boot_init

boot_init: 
	cli			; Disable interrupts
	mov ax, 0x00
	mov ds, ax		; Set data segment
	mov es, ax		; Set extra segment
	mov ss, ax		; Set stack segment
	mov sp, 0x7C00		; Set stack pointer
	sti			; Enable interrupts
	cld

	mov [__drive_number], dl
	
	mov si, __msg_bootup
	call printer

	;; We disable this for now. We need more space for the fat16 implementation.
	;;call detect_bios

	call detect_kern
	
	mov si, __msg_partfound
	call printer

;; Jumping to kernel
	push WORD 0x0100
	push WORD 0x0000
	retf

.error:
	jmp $		; Better never reach this.
;; Bye...

;; ---------------------------------------------------------
;; ---------------------------------------------------------
;; ---------------------------------------------------------
;; ---------------------------------------------------------
	
; Includes
%include "print.nasm"
%include "fio.nasm"
;;%include "bios.nasm"
__test: db "Hello", 0x00
__msg_bootup: db 0xD, 0xA, 'Syndicate 0.01', 0xD, 0xA, 'Trying to detect kernel...', 0xD, 0xA, 0x00
__msg_partfound: db 0xD, 0xA, 'Boot partition found, trying to load kernel...', 0xD, 0xA, 0x00
	
times 510 - ($-$$) db 0x00	; Fill remaining memory
dw 0xAA55			; Magicnumber which marks this as bootable for BIOS

