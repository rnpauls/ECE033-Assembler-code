;Rich Pauls
;June 11, 2016
;ECE 033
;Prof Wagh
;
;Prog1
;
;"The Range Finder"
;
;Takes 8 numbers between 0 and 255 as input
;Outputs the number of them between the range
;0-66 , 67-166, and 167-255, all inclusive

bdos	equ    	5h        	; CP/M function call address
boot	equ    	0h        	; address to get back to CP/M
string	equ    	9h          	; string print function number
cr	equ    	0Dh          	; value of ASCII code of <CR>
lf	equ   	0Ah          	; value of ASCII code of line feed
tab	equ	09		; value of ASCII code of horizontal tab
cin	equ	1		; character input function number
cout	equ	2		; character output function number
count	equ	8		; the number of numbers to be entered

	org	100h		; standard origin for CP/M
	lxi	sp, sp0		; initialize stack pointer at sp0, defined at the end of the program

	mvi	b,  '0'		; (load ASCII zero into registers b, h, and l 
	mvi	h, '0'		; these three registers will be used to keep track of 
	mvi	l,  '0'		; the number of low, middle, and high numbers, respectively)

	mvi	c, string	; prepare to output welcome message
	lxi	d, mess1	; load welcome message pointer into register pair d-e
	call 	bdos		; run print string function, printing the welcome message

	mvi	d , count	; Store the number 8 in the count register, e. 
				; Once this count reaches zero, the results are printed
	
	call	nextLn		; prompts the user for a new number

nextCh:	mvi	c, cin		; prepare to recieve user's input
	call	bdos		; runs function 1: get user's character and store it in A
	cpi	cr		; compare that character to ASCII <CR>
	jz	incrm		; if <CR> was entered, jump to incrementing the appropriate counter
	
	call 	update		; if a digit was entered, call the subroutine to update the 
				; number diplayed on the screen
				; as well as the number stored in register L
	jmp	nextCh		; jump to entering another character
	
incrm:	mov	a, l		; move the user's final number into register A
	pop	h		; pop the h-l pair so it can be incremented
	cpi	67		; compare the user's final number to ASCII 67. All small numbers return a carry
	jnc	mid		; if there is no carry, the number is not small. Jump to the check for medium numbers
	inr	b		; if there is a carry, increment b, the register holding the small # count
	jmp 	check		; jump to checking if 8 numbers have been entered yet

mid:	cpi	167		; compare the user's final number to ASCII 167. All medium numbers return carry
	jnc	big		; if no carry, it must be a big number. Jump ahead
	inr	h		; if there is a carry, increment the count for medium numbers
	jmp	check		; jump to checking if 8 numbers have been entered yet

big:	inr	l		; the only option left is that it is a big number. Increment the count for big #'s
	

check:	dcr	d		; decrement the count
	mvi	a, 0		; move 0 into the accumulator
	cmp	d		; compare 0 to the count
	cnz	nextLn		; if it's not zero, 8 numbers have not been entered yet. 
	
	mvi	c, string	; prepare to output results message
	lxi	d, out1		; load pointer to string containing "small numbers: " into d-e register
	call 	bdos		; run print string function, printing the above message
	mvi	c, cout		; prepare to output a character
	mov	e, b		; move the small count into reg e in order to use the print char function
	call 	bdos		; run the output character function

	mvi	c, string	; prepare to output medium results message
	lxi	d, out2		; load pointer to string containing "medium: " into d-e register
	call 	bdos		; run print string function, printing the above message
	mvi	c, cout		; prepare to ouptut a character
	mov	e, h		; move the medium count into reg e in order to use the print char function
	call 	bdos		; run the output character function

	mvi	c, string	; prepare to output results message
	lxi	d, out3		; load pointer to string containing "large: " into d-e register
	call 	bdos		; run print string function, printing the above message
	mvi	c, cout		; prepare to ouptut a character
	mov	e, l		; move the large count into reg e in order to use the print char function
	call 	bdos		; run the output character function

	mvi	c, string	; prepare to output goodybe message
	lxi	d, mess6	; load pointer to string containing goodbye message into d-e register
	call 	bdos		; run print string function, printing the message

	jmp	boot		; end of program
				; Subroutines begin below

; Subroutine nextLn
; input	: none
; action: prompts the user for their next number, and jump to nextCh label
; registers destroyed	: none

nextLn: push	h		; push the h-l register pair so it can be used for DAD
	push 	d		; not important the first time, however later the d register needs to be preserved
				; it will be popped when it needs to be incremented
	lxi	h, 0		; Set H-L registers to zero so they can hold the next number
	
	mvi	c, string	; prepare to output welcome message
	lxi	d, mess2	; load welcome message pointer into register pair d-e
	call 	bdos		; run print string function, printing the welcome message
	pop	d
	jmp	nextCh		; does not return. Jumps to nextChr

; Subroutine update
; input	: 	A character in register A and 
; 		whatever number the user has already entered this time, stored in reg H-L
; action:	multiply the previous number (in H-L) by ten and add it to 
;		the number equivalent of the character in A. Returns the new number in L
;		Only reg L is ever added to A, as the number should never be too large for one reg
; registers destroyed :	A, C, E, H, L

update: sui	'0'	; subtract ASCII zero from the user's input, so you are left with a number
	dad 	h	; double the old number
	add	l	; add 2x previous number (A <- <A> + 2*<H-L>)
	dad	h	; H-L is now 4x the old number
	dad	h	; H-L is now 8x the old number
	add	l	; add 8x the old number to A (A is now, in total, the original A plus 10*(the old number)
	mov	l, a	; return the new value in register l
	ret

mess1:	db	tab, tab, 'Welcome to the Range Finder!',lf, lf, cr
	db	'Classify 8 numbers in a jiffy!', lf, cr, '$'
mess2:	db	lf, cr, '>Please enter a number between 0 & 255 : $'
out1:	db	lf, lf, cr, 'Small numbers: $'
out2:	db	tab, 'Medium: $'
out3:	db	tab, 'Large: $'
mess4:	db	'$'
mess5:	db	'$'
mess6:	db	lf, lf, cr, 'Thank you for using the Range Finder!', lf, cr
	db	'Please consider donating to our Kickstarter campaign!$'

	ds	14	; At least 10 bits are needed, a little extra just to be safe
sp0	equ	$	; Stack pointer is initialized at this location
	end		; Needed for assembler to know when the program has stopped
				

