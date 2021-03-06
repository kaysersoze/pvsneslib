;---------------------------------------------------------------------------------
;
;	Copyright (C) 2013
;		Alekmaul 
;
;	This software is provided 'as-is', without any express or implied
;	warranty.  In no event will the authors be held liable for any
;	damages arising from the use of this software.
;
;	Permission is granted to anyone to use this software for any
;	purpose, including commercial applications, and to alter it and
;	redistribute it freely, subject to the following restrictions:
;
;	1.	The origin of this software must not be misrepresented; you
;		must not claim that you wrote the original software. If you use
;		this software in a product, an acknowledgment in the product
;		documentation would be appreciated but is not required.
;	2.	Altered source versions must be plainly marked as such, and
;		must not be misrepresented as being the original software.
;	3.	This notice may not be removed or altered from any source
;		distribution.
;
;---------------------------------------------------------------------------------

.equ REG_OBSEL		$2101

.ramsection ".reg_sprites" bank 0 slot 1

sprit_val1		dsb 1                         ; save value #1

.ends

.section ".sprites_text" superfree

.accu 16
.index 16
.16bit

;---------------------------------------------------------------------------
; void oamSetVisible(u16 id, u8 hide)
oamSetVisible:
	php
	phb

	phy
	phx

	sep #$20
	lda #:oamMemory
	pha
	plb

	rep #$20                         ; A 16 bits
	lda	10,s                     ; id
	tay
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc.w #512                   ; id>>4 + 512
	tay                          ; oam pointer is now on oam table #2
	
	lda	10,s                     ; id
	lsr a
	lsr a
	and.w #$3                    ; id >> 2 & 3
	tax

	sep #$20
	lda oamMemory,y              ; get value of oam table #2
	and.l oamHideand,x
	sta oamMemory,y              ; store new value in oam table #2
	
	lda.b 12,s                     ; hide
	beq oamHide1end              ; no, so bye bye
	
	lda.l oamHideshift,x         ; get shifted value of hide (<<1, <<2, <<4, <<6
	clc
	adc oamMemory,y
	sta oamMemory,y              ; store new value in oam table #2

	rep #$20                         ; A 16 bits
	lda	10,s                     ; id
	tay
	sep #$20                         ; A 8 bits
	lda.b #$1                        ; clear x entry (-255)
	sta oamMemory,y
	iny
	lda.b #$F0                       ; clear y entry
	sta oamMemory,y

oamHide1end:
	plx
	ply
	
	plb
	plp
	rtl

oamHideand: 
	.db $fe, $fb, $ef, $bf
oamHideshift: 
	.db $01, $04, $10, $40

;---------------------------------------------------------------------------
; void oamInitGfxAttr(u16 address, u8 oamsize)
oamInitGfxAttr:
	php
 
	rep #$20                         ; A 16 bits
	lda	5,s                      ; address

	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a                           ; adress >> 13
	
	sep #$20
	sta sprit_val1
	
	lda.b	7,s                      ; oamsize
	ora sprit_val1               ; oamsize | (address >> 13)  
	
	sta.l	REG_OBSEL
	
	plp
	rtl
	
.ends