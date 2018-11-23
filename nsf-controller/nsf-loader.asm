; iNES header

; iNES identifier
.byte "NES",$1a

; Number of PRG-ROM blocks
.byte $02

; Number of CHR-ROM blocks
.byte $01

; ROM control bytes: Horizontal mirroring, no SRAM
; or trainer, Mapper #0
.byte $00, $00

; Filler
.byte $00,$00,$00,$00,$00,$00,$00,$00

.org $8000

; erase memory range routine
erase:
  lda #$00
  sta $86
  stx #$00

  @erase_loop:
    sta #$86, x
    inc $20
    bcs @inc_hi

  @erase_check:
    ldy $22
    cpy $20
    bne @erase_loop
    ldy $23
    cpy $23
    bne @erase_loop
    rts

  @inc_hi:
    inc $21
    jmp @erase_check

main:
  ; clear $0000-$07ff
  lda #$00
  sta $20
  sta $21
  lda #$ff
  sta $22
  lda #$07
  sta $23
  jsr erase

  ; clear $6000-$7fff
  lda #$00
  sta $20
  lda #$60
  sta $21
  lda #$ff
  sta $22
  lda #$7f
  sta $23
  jsr erase

  ; clear $4000-$4013
  lda #$00
  sta $20
  lda #$40
  sta $21
  sta $23
  lda #$13
  sta $22
  jsr erase

  ; clear the bank switching stuff
  lda #$f8
  sta $20
  lda #$5f
  sta $21
  lda #$ff
  sta $22
  lda #$5f
  sta $23
  jsr erase

  ; init sound registers
  lda #$00
  sta $4015
  lda #$0f
  sta $4015

  ; set frame counter to four step mode
  lda #$40
  sta $4017

  ; set up playback parameters
  lda #$00 ; song number
  ldx #$00 ; ntsc / pal bit
  jsr $be34 ; nsf load address

play_loop:
  jsr $f2d0
  ldx #$10
  ldy #$ff
  @delay_loop:
    dey
    beq @x_dec
    jmp @delay_loop

  @x_dec:
    ldy #$ff
    dex
    beq play_loop
    jmp @delay_loop

vblank:
irq:
  rti

.pad $bdc4

; include the NSF program
.incbin smb-nsf.bin

.pad $fffa
.word vblank, main, irq