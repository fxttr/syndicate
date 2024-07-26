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
[ORG 0x7c00]
	jmp boot_init
	
	; Includes
%include "write.inc"
%include "fio.inc"

boot_init: 
	cli			; Disable Interrupts
	call detect_kern

halt:
	jmp halt
	
	
times 510 - ($-$$) db 0		; Fill remaining memory
dw 0xaa55			; Magicnumber which marks this as bootable for BIOS
	
kern_bin db 'kern.bin' ; Our stage2 target. We'll try to locate it.
