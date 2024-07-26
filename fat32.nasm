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

;; fat32.inc
;; This code tries to detect and read a FAT32 filesystem.
;; Only reading supported.

__oem_id:                  db 		"Syndicate"
__bytes_per_sector:        dw 		0x0200
__sectors_per_cluster:     db 		0x08
__reserved_sectors:        dw 		0x0020
__total_FATs:              db 		0x02
__max_root_entries:        dw 		0x0000
__number_of_sectors:       dw 		0x0000
__media_descriptor:        db 		0xF8
__sectors_per_FAT:         dw 		0x0000
__sectors_per_track:       dw 		0x003D
__sectors_per_head:        dw 		0x0002
__hidden_sectors:          dd 		0x00000000
__total_sectors:     	   dd 		0x00FE3B1F		
__big_sectors_per_FAT:     dd 		0x00000778
__flags:                   dw 		0x0000
__fs_version:              dw 		0x0000
__root_directory_start:    dd 		0x00000002
__fs_info_sector:          dw 		0x0001
__backup_boot_sector:      dw 		0x0006
__drive_number:            db 		0x00
__reserved_byte:           db   	0x00
__signature:               db 		0x29
__volume_id:               dd 		0xFFFFFFFF
__volume_label:            db 		"Syndicate boot"
__system_id:               db 		"FAT32   "

;; ----------------------------------------------------------
;; Preparing the bootloader for reading FAT32 partitions
;; ----------------------------------------------------------
prepare_fs:
;; Computing data location
	mov cx, WORD[__sectors_per_cluster] ; Get size of a cluster
	mov al, BYTE[__total_FATs]	    ; Get number of FATs
	mul WORD[__big_sectors_per_FAT]	    ; Multiplied by the number of sectors per FAT
	add ax, WORD[__reserved_sectors]    ; Add the reserved sectors to find the start of the Data Area
	mov WORD[__datasector], ax	    ; Store the address

;; Read computed data area into memory
	mov ax, WORD[__root_directory_start]
	call _lba_conv
	mov bx, 0x0200
	call _read_disk_sectors

	retf

	

;; ----------------------------------------------------------
;; Converting cluster address into lba address
;; ----------------------------------------------------------
_lba_conv:
	sub ax, 0x0002
	xor cx, cx
	mov cl, BYTE[__sectors_per_cluster]
	mul cx
	add ax, WORD[__datasector]
	ret

;; ----------------------------------------------------------
;; Reading all sectors from disk
;; ----------------------------------------------------------
_read_disk_sectors:
.restart:
	mov di, 0x0010		; Tries
.loop:
	push ax
	push bx
	push cx
	call _chs_conv
	
;; Preparing BIOS interrupt http://www.ctyme.com/intr/rb-0607.htm
	mov ah, 0x02		; BIOS read sector
	mov al, 0x01		; Read one sector per loop
	mov ch, BYTE[__absolute_track]
	mov cl, BYTE[__absolute_sector]
	mov dh, BYTE[__absolute_head]
	mov dl, BYTE[__drive_number]
	int 0x13
	jnc .success		; Found sector?

;; Something went really wrong. Recovering. http://www.ctyme.com/intr/rb-0605.htm
	xor ax, ax
	int 0x13

	dec di
	pop cx
	pop bx
	pop ax
	jnz .loop		; Try again if di not zero
	int 0x18
.success:
	mov si, __progress_bar
	call printer
	pop cx
	pop bx
	pop ax
	add bx, WORD[__bytes_per_sector] ; Try next buffer
	inc ax				 ; Try next sector
	loop .restart			 ; Read next sector
	ret
	
;; ----------------------------------------------------------
;; Converting lba address to chs 
;; ----------------------------------------------------------
_chs_conv:
	xor dx, dx
	div WORD[__sectors_per_track]
	inc dl
	mov BYTE[__absolute_sector], dl
	xor dx, dx
	div WORD[__sectors_per_head]
	mov BYTE[__absolute_head], dl
	mov BYTE[__absolute_track], al
	ret

__progress_bar: db "*", 0x00
__progress_bar_done: db "*", 0xD, 0xE, 0x00
__absolute_sector: db 0x00
__absolute_head: db 0x00
__absolute_track: db 0x00
__datasector: dw 0x0000
