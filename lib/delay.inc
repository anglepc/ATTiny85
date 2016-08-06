.CSEG
delay: ; R16*(3+40000) = 0.005 sec to 1.275 sec 
        push    R16
        push    R17
        push    R18
        ldi     R16, 20 ; 0.1 seconds
delay_R16:
        ldi     R17, 50
delay_R17: ; 50(4+796)=40,000 cycles = 0.005 seconds 
        ldi     R18, 199
delay_R18: ; 796 cycles = 0.0000995 seconds 
        dec     R18
        nop
        brne    delay_R18
        nop
        dec     R17
        brne    delay_R17
        nop
        dec     R16
        brne    delay_R16
        pop     R18
        pop     R17
        pop     R16
        ret

delay_5ms: ; R16*(3+40000) = 0.005 sec to 1.275 sec 
	push	R16
        ldi     R16, 1 ; 0.005 seconds
	rjmp	delay_var
delay_10ms: ; R16*(3+40000) = 0.005 sec to 1.275 sec 
	push	R16
        ldi     R16, 2 ; 0.01 seconds
	rjmp	delay_var
delay_100ms: ; R16*(3+40000) = 0.005 sec to 1.275 sec 
	push	R16
        ldi     R16, 20 ; 0.1 seconds
	rjmp	delay_var
delay_1000ms: 
	push	R16
        ldi     R16, 200
	rjmp	delay_var
delay_var: ; R16*(3+40000) = 0.005 sec to 1.275 sec 
        push    R17
        push    R18
delay_var_loop1:
        ldi     R17, 50
delay_var_loop2: ; 50(4+796)=40,000 cycles = 0.005 seconds 
        ldi     R18, 199
delay_var_loop3: ; 796 cycles = 0.0000995 seconds 
        dec     R18
        nop
        brne    delay_var_loop3
        nop
        dec     R17
        brne    delay_var_loop2
        nop
        dec     R16
        brne    delay_var_loop1
        pop     R18
        pop     R17
        pop     R16
        ret
