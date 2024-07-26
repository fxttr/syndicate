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

;; fio.inc
;; Routines to find the kernel on a FAT32 partition
	
%include "fat32.nasm"

;; ----------------------------------------------------------
;; Find the kernel on a FAT32 drive
;; ----------------------------------------------------------
detect_kern:
	call prepare_fs		; Preparing the bootloader to read the FAT32 drive

;; Getting file informations
	mov di, 0x0200 + 0x20	; Get first file entry
	mov dx, WORD[di + 0x001A] ; Offset of the file entry
	mov WORD[__cluster], dx

;; Preparing kernel location
	mov ax, 0x0100		; Location
	mov es, ax		; Setting extra segment
	mov bx, 0x00

;; Reading kernel cluster
	mov cx, 0x0008
	mov ax, WORD[__cluster]
	call _lba_conv
	call _read_disk_sectors

	push WORD 0x0100
	push WORD 0x0000
	retf

__cluster: dw 0x0000
