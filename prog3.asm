;Rich Pauls
;June 28, 2016
;ECE 033
;Prof Wagh
;
;Prog3
;
;"The Histogram"
;
;Input: 	As many numbers as wanted
;
;
;Function:	Outputs a histogram of the number of times 
;		each number was inputted. 
;		Does not allow user to input characters other than digits

bdos	equ    	5h        	; CP/M function call address
boot	equ    	0h        	; address to get back to CP/M
string	equ    	9h          	; string print function number
cr	equ    	0Dh          	; value of ASCII code of <CR>
lf	equ   	0Ah          	; value of ASCII code of line feed
bs	equ	08H		; value of ASCII backspace
cin	equ	1		; character input function number
cout	equ	2		; character output function number
x	equ	'X'		; wasn't working hard-coding the ascii for some reason
colon	equ	3Ah		; value of ASCII code for a colon

	org	100h		; standard origin for CP/M
	lxi	sp, sp0

	mvi	c, string	; prepare to output welcome message
	lxi	d, mess1	; load welcome message pointer into register pair d-e
	call 	bdos		; run print string function, printing the welcome message	


	mvi	a, 10		; Set the counters to zero
	lxi	h, buff
clear:	mvi	m, 0h		; Using indirect addressing
	inx	h
	dcr	a
	cpi	0
	jnz	clear

	mvi	c, cin
loop1:	call	bdos		; Get input and delete it if it’s not a number
	cpi	cr
	jz	output		; if carriage return, number entry is done
	cpi	'0'		; 30h = ASCII zero
	jc	del
	cpi	'9' + 1		; 39h = ASCII nine
	jc	store		; these two comparisons make sure the input is a digit

del:	mvi	c, string	; To remove the non-digit character, 
	lxi	d, delete	; print a backspace, space, and backspace
	call	bdos
	mvi	c, cin
	jmp	loop1		; jump back and get next char

store:	sui	'0'		; Store the input in memory
	lxi	h, buff		; add the user's number to the buffer
	adc	l		; giving you the location in memory of the counter
	jnc	skip		
	inr	h
skip:	mov	l, a
	inr	M		; then increment that counter
	jmp	loop1

output:	mvi	c, string
	lxi	d, mess2
	call	bdos
	mvi	b, '0'		; B will count which number’s histo is being printed
	mvi	c, cout		; prepare to output characters
	lxi	sp, buff	; Point SP at first counter
loop5:	mvi	e, lf
	call	bdos
	mvi	e, cr
	call	bdos
	mvi	a, '9'+1	; Check if all ten have been printed yet
	cmp	b
	jz	done		; if so, jump to end
	
	pop	h		; Pop two counters to H-L pair
	mov	e, b
	call	bdos		; Print the number of the corresponding histogram
	mvi	e, colon
	call	bdos
	mvi	e, 20h		; 20h = space (wasn't working as ' ' for some reason)
	call	bdos
	mvi	e, x
	inr	b
	mvi	a, 0		; Reg A will check when a counter is depleted
loop6:	cmp	L		; A number of X’s will be printed
	jz	printH		; Corresponding to the counter in L
	call	bdos
	dcr	L		; decrement count
	jmp	loop6

printH:	mvi	e, lf		; This part is the same but prints the second
	call	bdos		; counter that was popped to H-L
	mvi	e, cr
	call	bdos
	mov	e, b
	call	bdos		
	mvi	e, colon
	call	bdos
	mvi	e, 20h		; 20h = space (wasn't working as ' ' for some reason)
	call	bdos
	mvi	e, x
	inr	b
loop7:	cmp	H
	jz	loop5
	call	bdos
	dcr	H
	jmp	loop7

done:	lxi	d, mess3	; print goodbye message
	mvi	c, string
	call	bdos
	jmp	boot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;Subroutines

; No subroutines. I would use one to print each bar of the histogram
; but the program is sped up by using the stack to pop each
; pair of counters. This is more important

;;;Messages

mess1:	db	'Welcome to the Histogram Maker 9000!'
	db	lf, lf, cr, 
	db	'Enter as many digits as you like (choose carefully)'
	db	lf, lf, cr, '$'

mess2:	db	lf, lf, cr, 'Histogram:', lf, cr, '$'

mess3:	db	lf, cr, 
	db	'Thanks you for using the Histogram-Maker-9000(TM)'
	db	lf, cr, 'If you liked this, please consider donating!$'

delete:	db	bs, ' ', bs, '$'
	

buff:	ds	10
	ds	2
sp0	equ	$
	end