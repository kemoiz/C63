; 10 sys (4096)
*=$801
          byte $0e, $08, $0a, $00, $9e, $20, $28, $34, $30, $39, $36, $29, $00, $00, $00
; 10 sys (2085)
border    = $d020                              ; border
back      = $d021                              ; background
irqrout   = $ea31
irqvec    = $314
*=$2000
incbin    "chars.bin"
*=$a000
incbin    "music.bin"
*=$1000
init
                                   ; jsr            $ff81
          lda            #$36
          sta            $0001
          lda            #$03
          sta            $d020
          sta            $d021
          lda            #%00011000
          sta            $d018
          jsr            $a000
          sei
          lda            #<irq
          ldx            #>irq
          sta            $314
          stx            $315
          lda            #$1b
          ldx            #$00
          ldy            #$7f
          sta            $d011
          stx            $d012
          sty            $dc0d
          lda            #$01
          sta            $d01a
          sta            $d019      
          lda            #$00
          jsr            $a000      
          cli
          ldx            #$00
          jsr            $0850     ;intro
          jsr            $9d00     
          lda            #$01      
          jsr $a000
          jmp            initsprites
                                   ; not used anymore
initsprites
          lda            #$06
          sta            $d025
          lda            #$07
          sta            $d026
          lda            #$00
          sta            $d029
          lda            #$05
          sta            $d028
          lda            #%00000100
          sta            $d01c     ; multicolor sprite 2
          lda            #$31
          sta            $07f8     ;sprite pointer first
          lda            #$30
          sta            $07fa     ;sprite pointer second
          lda            #$ff
          sta            $d015     ;enable all sprites
          lda            #$50
          sta            $d000     ;sprite 1 x
          lda            #$3f
          sta            $d001     ; sprite 1 y
          lda            #$60
          sta            $d002     ; sprite 2 x
          lda            #$60
          sta            $d003     ; sprite 2 y
          lda            #$01
          sta            $d01d     ;stretch spr1 x
          sta            $d017     ;stretch spr1 y
          lda            #$00
          sta            $00a2     ;null the counter
          lda            #$18
          sta            $d016
          lda            #$08
          sta            $d022
          lda            #$01
          sta            $d023
                                   ; overlay of player's sprite
          lda            #$37
          sta            $07f9
          lda            #$50
          sta            $d004
          sta            $d005
lo        jmp            fillscreen
ll2
          jmp            l2load
fillscreen
          lda            #$ff
          sta            $9f00
          lda            #$03
          sta            $d021
          ldx            #$00
          lda            level
          cmp            #$01
          beq            ll2
          jmp            l1load
stopload
          lda            $3028+$28,x
          sta            $0428+$28,x
                                   ;charmem fill
          lda            $3100,x
          sta            $0500,x
          tay
          lda            $8000,y
          sta            $d900,x
          lda            $3200,x
          sta            $0600,x
          tay
          lda            $8000,y
          sta            $da00,x
          lda            $32f8,x
          sta            $06f8,x
          tay
          lda            $8000,y
          sta            $daf8,x
          dex
          cpx            #$00
          bne            stopload
          lda            #$00
          sta            $9f00
          jmp            groundload
l0load
                                   ;charmem fill
          lda            $3000,x
          sta            $0400,x
          tay
          lda            $8000,y
          sta            $d800,x
          lda            $3100,x
          sta            $0500,x
          tay
          lda            $8000,y
          sta            $d900,x
          lda            $3200,x
          sta            $0600,x
          tay
          lda            $8000,y
          sta            $da00,x
          lda            $32f8,x
          sta            $06f8,x
          tay
          lda            $8000,y
          sta            $daf8,x
          dex
          cpx            #$00
          bne            l0load
          lda            #$00
          sta            $9f00
          jmp            groundload
l1load
          lda            #$00
          sta            rlepoint
          lda            #$30
          sta            rlepoint+1
          lda            #$00
          sta            rle_read
          lda            #$40
          sta            rle_read+1
          lda            #$00
          sta            flag
          jsr            rleunpack
          ldx            #$00
@lp
          lda            $4200,x
          sta            $3400,x
          lda            $4300,x
          sta            $3500,x
          inx
          cpx            #$00
          bne            @lp
          jmp            l0load
l2load
          lda            #$00
          sta            rlepoint
          lda            #$30
          sta            rlepoint+1
          lda            #$00
          sta            rle_read
          lda            #$44
          sta            rle_read+1
          lda            #$00
          sta            flag
          jsr            rleunpack
          ldx            #$00
          jmp            stopload
groundload
          ldx            #$00
@ww       lda            $4c00,x
          sta            $0748,x
          lda            #$08
          sta            $db48,x
          inx
          cpx            #$a0
          bne            @ww
loop
          jsr            scrollcloud
          jsr            playergravity
          jsr            moveplayer
          jsr            setanim
          jsr            labelset
          jsr            timer
          jsr            bkgswap
          jsr            levelswap
          jmp            loop
;--- routines
levelswap
          clc
          lda            $d002
          cmp            #$12
          bcc            @n1
@cbb      clc
          lda            $d002
          cmp            #74
          bcs            @n3
          rts
@n3
          lda            $d010
          cmp            #%00000010
          beq            @n4
          rts
@n4
          lda            #$12
          sta            $d002
          lda            $d010
          eor            #%00000110
          sta            $d010
          dec            level
          jmp            fillscreen
@n1
          lda            $d010
          cmp            #%00000000
          beq            @n2
          jmp            @cbb
@n2
          inc            level
          lda            #73
          sta            $d002
          lda            $d010
          eor            #%00000110
          sta            $d010
          jmp            fillscreen
bkgswap
          lda            $d012
          cmp            #$10
          bcs            @w
          lda            #$03
          sta            $d021
@w
          rts
setanim
          lda            plrstate
          cmp            #$00
          beq            @rt2
          cmp            #$01
          beq            @rt
          lda            stopped
          cmp            #$01
          beq            @stop
          clc
          lda            anim
          cmp            #$01
          beq            @right
          cmp            #$02
          beq            @left
@rt       rts
@rt2
          lda            #$36
          sta            $07fa
          rts
@stop
          lda            #$30
          sta            $07fa
          rts
@right
          lda            animtimer
          cmp            #$80
          bcs            @x
          lda            #$32
          sta            $07fa
          rts
@x
          lda            #$33
          sta            $07fa
          rts
@left
          lda            animtimer
          cmp            #$80
          bcs            @x2
          lda            #$34
          sta            $07fa
          rts
@x2
          lda            #$35
          sta            $07fa
          rts
checkforvertcol2
          lda            $d002
          sec
                                   ; adc #$0f
                                   ; inc            $d002
          ldx            #$00
@d
          lda            $d002
          sec
          sbc            #$08
          cmp            $3500,x
          beq            @e
@w        inx
          inx
          inx
          cpx            #$09
          bne            @d
                                   ;dec           $d002
          rts
@e
          lda            $d003
          sec
          sbc            $3501,x
          cmp            $3502,x
          bcs            @w
          inc            $d002
          rts
checkforvertcol
          lda            $d002
                                   ; inc            $d002
          ldx            #$00
@d
          lda            $d002
          cmp            $3500,x
          beq            @e
@w        inx
          inx
          inx
          cpx            #$09
          bne            @d
          rts
@e
          lda            $d003
          sec
          sbc            $3501,x
          cmp            $3502,x
          bcs            @w
          dec            $d002
          rts
moveplayer
          lda            $d003
          sta            $d005
          lda            $d002
          sta            $d004
          lda            #%00000100
          bit            $dc00
          beq            @left
@c1       lda            #%00001000
          bit            $dc00
          beq            @right
@c2       lda            #%00010000
          bit            $dc00
          beq            @jump
          lda            #$7f
          cmp            $dc00
          bne            @comeback
          lda            #$01
          sta            stopped
@comeback
          rts
@left
          lda            timerb
          cmp            #$80
          bne            @comeback
          clc
          lda            $d002
          cmp            #$00
          bne            @r
          lda            $d010
          eor            #%00000010
          sta            $d010
@r
          jsr            checkforvertcol2
          dec            $d002
          lda            #$02
          sta            anim
          lda            #$00
          sta            stopped
          jmp            @c1
@right
          lda            timerb
          cmp            #$80
          bne            @comeback
          clc
          lda            $d002
          cmp            #$ff
          bne            @w
          lda            $d010
          eor            #%00000010
          sta            $d010
@w
          jsr            checkforvertcol
          inc            $d002
          lda            #$01
          sta            anim
          lda            #$00
          sta            stopped
          jmp            @c2
@jump
          lda            plrstate
          cmp            #$02
          bne            @cb
          lda            #$01
          sta            plrstate
          lda            #$00
          sta            stopped
@cb       rts
timer
          lda            timerb
          adc            #$08
          sta            timerb
          clc
          lda            $d012
          cmp            #$80
          bcc            @cb
          inc            animtimer
@cb       rts
labelset
          lda            $d002
          jsr            hextodec
          sty            $0407
          stx            $0408
          sta            $0409
          lda            $d003
          jsr            hextodec
          sty            $040f
          stx            $0410
          sta            $0411
          rts
playergravity
          clc
          lda            timerb
          cmp            #$80
          bne            @y
          lda            plrstate
          cmp            #$01
          beq            @jump
;-- load platforms
; ground
          lda            $d003
          cmp            #200
          bcs            @comeback
          ldx            #$00
@lp       lda            $d002
          sec
          sbc            $3400,x
          cmp            $3401,x
          bcc            @n1
@n2       inx
          inx
          inx
          clc
          cpx            #$0c      ;amount of platforms
          bcc            @lp
          jmp            @w
@n1
          lda            $d003
          cmp            $3402,x
          beq            @comeback
          jmp            @n2
@w
          lda            #$00
          sta            plrstate
          inc            $d003
          inc            $d003
@y        rts
@comeback
          lda            #$02
          sta            plrstate
          rts
@jump
          clc
          lda            jumpdur
          cmp            #$04      ;
          bcs            @op2
          lda            $d003
          sbc            jumpdur
          sta            $d003
          inc            jumpdur
          rts
@op2
          lda            jumpdur
          cmp            #$12
          bcs            @op3
          dec            $d003
          dec            $d003
          inc            jumpdur
          rts
@op3
          lda            jumpdur
          cmp            #$1c
          bcs            @op4
          dec            $d003
          inc            jumpdur
          rts
@op4
          inc            jumpdur
          lda            jumpdur
          cmp            #$30
          bcs            @op
          rts
@op
          lda            #$00
          sta            plrstate
          sta            jumpdur
          rts
scrollcloud
          lda            $00a2
          cmp            #$08
          bne            @comeback
          inc            $d000
          lda            #$00
          sta            $00a2
@comeback
          rts
;--- constant routines
; 61 - rle_read, fb - rlepoint
rleunpack
          lda            #$03
          sta            $d021
          ldx            #$00
@loop
          inc            $d020
          lda            rlepoint
          sta            $63
          lda            rlepoint+1
          sta            $64
          lda            rle_read
          sta            $61
          lda            rle_read+1
          sta            $62
          ldy            #$00
          lda            ($61),y
          cmp            #$20
          beq            @countbytes
                                   ;    cmp            #$00
          beq            @end
@cb
          inc            rle_read
@cb3
          inc            rlepoint
          ldx            rlepoint
                                   ;   lda $4000,x
          dex
          stx            $63
          ldy            #$00
          sta            ($63),y
          ldy            #$01
          lda            ($61),y
          inx
          cpx            #$00
          beq            @end
          lda            flag
          cmp            #$01
          beq            @ww
          jmp            @loop
@ww
          clc
          ldx            rlepoint
                                   ; cpx #$00
          cpx            #$fe
          bcc            @loop
          rts
@end
          inc            rlepoint+1
          lda            #$01
          sta            flag
          jmp            @loop
@s        rts
@inchighbyte2
          lda            $62
                                   ; cmp            #$41
                                   ; beq            @end
          inc            $62
          inc            rle_read+1
          jmp            @cb3
@countbytes
          lda            rlepoint
          sta            $63
          ldy            #$00
          lda            #$20
          sta            ($63),y
          ldx            rle_read
          stx            $61
          inc            $61
          lda            ($61),y
          dec            $61
          tay
          dey
@w
                                   ;cpx #$ff
                                   ;beq @cb
          inc            rlepoint
          ldx            rlepoint
          cpx            #$00
          beq            @inchighbyte1
@cb2      lda            #$20
          sty            $fb
          ldy            #$00
          stx            $63
@sto      sta            ($63),y
          ldy            $fb
          dey
          cpy            #$00
          bne            @w
          inc            rle_read
          ldx            rlepoint
          lda            #$20
          jmp            @cb
@inchighbyte1
          inc            rlepoint+1
          inc            $64
          jmp            @cb2
hextodec
          ldy            #$2f
          ldx            #$3a
          sec
@l1       iny
          sbc            #100
          bcs            @l1
@l2       dex
          adc            #10
          bmi            @l2
          adc            #$2f
          rts
;--- irq
irq
          jsr            $a003
          asl            $d019
          jmp            irqrout
;
count     byte            30
scroll
          byte            $00
scrollflag
          byte            $00
scrollflag2
          byte            $00
scrolloffset
          byte            $00
timerb
          byte            $00
jumpdur
          byte            $00
plrstate                           ;-- 00 - falling, 1 - jumping
          byte            $00
anim                               ;00 - regular, 01 - running right, 02 - left
          byte            $00
animtimer
          byte            $00
stopped
          byte            $00
level
          byte            $00
rlepoint
          byte            $00,$30
rle_read
          byte $00, $40
flag
          byte            $00
*=$0c00
sprite
          incbin"cloud.bin"
