;
shift     ldx            #$27
@shift2
          lda            $071f,x
          sta            $0720,x
          dex
          cpx            #$00
          bne            @shift2
          lda            $0746
          sta            $0720
          lda            #$00
          sta            scrollflag
          rts
;irqx
;-- save re
          PHA
          TXA
          PHA
          TYA
          PHA
          clc
          lda            scrollflag2
          cmp            #$01
          jmp            @store
          lda            #$00
          sta            $d016
@cmb
          inc            scroll
          lda            scroll
          cmp            #$08
          bcc            @out
          inc            $d016
          lda            #$00
          sta            scroll
          sta            $d016
          jsr            shift
@out
          asl            $d019
          PLA
          TAY
          PLA
          TAX
          PLA
          JMP            IRQROUT
@store
          lda            scroll
          sta            $d016
          jmp            @cmb