*=$0850
          lda            #$00
          sta            $d020
          sta            $d021
          lda            #$00
          sta            $00a2
@lp
          lda            $00a2
          cmp            #$79
                                   ; bne            @lp
          lda            #$00
          sta            $d027
          lda            #$00
          sta            $d028
          lda            #$2e
          sta            $07f8     ;sprite pointer first
          lda            #$2f
          sta            $07f9     ;sprite pointer second
          lda            #$ff
          sta            $d015     ;enable all sprites
          lda            #$80
          sta            $d000     ;sprite 1 x
          lda            #$70
          sta            $d001     ; sprite 1 y
          lda            #$80+$30
          sta            $d002     ; sprite 2 x
          lda            #$70
          sta            $d003     ; sprite 2 y
          lda            #$03
          sta            $d01d     ;stretch spr1 x
          sta            $d017     ;stretch spr1 y
          lda            #$00
          sta            $00a2     ;null the counter
                                   ;    lda            #$18
                                   ;   sta            $d016
;now, we're going to have a fade in
holdme
          lda            $00a2
          cmp            #8
          bne            holdme
          lda            #11
          sta            $d027
          sta            $d028
          lda            #15
          sta            $d021
@holdme2
          lda            $00a2
          cmp            #15
          bne            @holdme2
          lda            #12
          sta            $d027
          sta            $d028
          lda            #11
          sta            $d021
@holdme3
          lda            $00a2
          cmp            #24
          bne            @holdme3
          lda            #15
          sta            $d027
          sta            $d028
          lda            #0
          sta            $d021
hold
          jsr            noploop
          ldx            pointer
          lda            gradient,x
          sta            $d027
          sta            $d028
          inc            pointer
          lda            pointer
          cmp            #$0c
          beq            @resetpointer
          lda            $dc01
          cmp            #$ef
          bne            hold
          cli
          jmp            menuloop
@resetpointer
          ldx            clearpointer
          lda            #$20
          sta            $0400,x
          sta            $0500,x
          sta            $0600,x
          sta            $06e8,x
          ldx            clearpointer
          inx
          cpx            #$00
          beq            gototextroutine
          stx            clearpointer
rtrn      lda            #$00
          sta            pointer
          jmp            hold
noploop
          ldx            #$00
@lp
          inx
          nop
          nop
          cpx            #$02
          bne            @lp
          rts
gototextroutine
          jsr            txtloop
          jmp            rtrn

menuloop
          ldx            #$00
          lda            #$00
          sta            $d015
@draw
          lda            $b800,x
          sta            $d800,x
          lda            $bc00,x
          sta            $0400,x
          lda            $b900,x
          sta            $d900,x
          lda            $bd00,x
          sta            $0500,x
          lda            $ba00,x
          sta            $da00,x
          lda            $be00,x
          sta            $0600,x
          lda            $bb00,x
          sta            $db00,x
          lda            $bee8,x
          sta            $06e8,x
          dex
          cpx            #$00
          bne            @draw
@ml

          
          lda            #%00000001
          bit            $dc00
          beq            @incrasterpos
          
          lda            #%00000010
          bit            $dc00
          beq            @decrasterpos
          lda            #%00001000
          bit            $dc00     
          beq            @rets     
          
@return 
          lda            $d012
          sbc            rasterpos
          cmp            #$10
          bcs            @fail
          lda            #$02
          sta            $d021     
          
          jsr            renderbacklight
          jmp            @ml
@fail
          lda            #$00
          sta            $d021     


          jmp            @ml       
          
@incrasterpos
          clc

          inc delayer
          lda            delayer   
          cmp            #$20     
          bne @return
          inc menupointer
          jmp            @return   
          
@decrasterpos
          inc delayer
          lda            delayer   
          cmp            #$20     
          bne @return
          dec menupointer
          jmp            @return   
          
@rets
          rts
          


renderbacklight
          sec
          lda            menupointer     
          cmp #$00        
          beq            @flash1   
          jsr            @hide1     
          cmp            #$01     
          bcc            @flash2  
          jsr            @hide2          
          
          rts
@flash1
          lda #$01
          ldx            #$10      

@lp
          sta $d992,x
          dex
          bne @lp
          rts          
@hide1
          lda #$02
          ldx            #$10     
          jmp            @lp       
          
@flash2
          lda #$01
          ldx            #$10+$28      

@lp2
          sta $d992,x
          dex
          bne @lp2
          rts        
@hide2
          lda #$02
          ldx            #$10+$28     
          jmp            @lp            
menupointer
          byte $00
delayer
          byte $00 
rasterpos
          byte           $80
          
clearpointer
          byte            $00
pointer
          byte            $00
gradient
          byte 15, 15, 15, 12, 12, 12, 11, 11, 11, 1, 1, 1
introtext
          byte $10,$12,$05,$13,$05,$0e,$14,$13,$20,$19,$0f,$15,$2e,$2e,$2e, $00
txtloop
          lda            introtext,x
          cmp            #$00
          beq            rtrt
          sta            $0667,x
          inx
          jmp            txtloop
rtrt
          rts
*=$0b80
incbin    "kemoiz.bin"
