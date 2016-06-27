;Rich Pauls
;June 18, 2016
;ECE 033
;Prof Wagh
;
;Prog2
;
;"The Enhanced Sentence Editor"
;
;Input:
;	A sentence ending in a period or question mark
;	A word ending with the <CR> key
;	A 1-2 digit number
;
;Function:
;	Insert the word after the word in the sentence
;	corresponding to the number entered
;	i.e.    1 = after the first word
;	        0 = before the first word
;	a number >= the number of words in the sentence = after the last word
;
;	This program implements what is essentially an array in
;	order to hold the user's words. The size for each of these arrays is
;	predetermined by the 'length' variable defined at 10 now
;	
;	The array is stored in memory, and is accessed by a print function that
;	relies on function 2 and indirect addressing in order to print dollar signs
;	Instead of dollar signs, the print function stops when it reads a space 
;	or punctuation. The punctuation is not printed, but the space is.
;	Punctuation is stored in memory until the end when it is needed.

bdos	equ    	5h        	; CP/M function call address
boot	equ    	0h        	; address to get back to CP/M
string	equ    	9h          	; string print function number
cr	equ    	0Dh          	; value of ASCII code of <CR>
lf	equ   	0Ah          	; value of ASCII code of line feed
cin	equ	1		; character input function number
cout	equ	2		; character output function number
length	equ	10		; the maximum length for a user's entered word (punctuation counts)

	org	100h		; standard origin for CP/M
	lxi	sp, sp0		; initialize stack pointer at sp0, defined at the end of the program

	mvi	c, string	; prepare to output welcome message
	lxi	d, mess1	; load welcome message pointer into register pair d-e
	call 	bdos		; run print string function, printing the welcome message

	lxi	h, buffer	; set the H-L reg to point to the buffer
	mvi	b, 0		; set b to zero in order to use it as a counter
	mvi	c, cin		
loop1:	call 	bdos		; get user's input
	mov	m, a
	inx	h
	cpi	' '		; check if the character is a space
	jz	movbuf
	
period:	cpi	'.'		; check if the char is a '.' or '?'
	jz	endwrd
	cpi	'?'
	jnz	loop1		; if not, get next char
	
		
endwrd:	lxi	h, punct
	mov	m, a		; store the punctuation in memory
	inr	b
	jmp	usrwrd		; sentence done, jump ahead

movbuf:	inr	b		; first, ++b for another word
	push	psw		; adjusts the pointer in H-L pair so that the next word
	push	d		; will be 'length' locations after the beginning of this word
	lxi	d, length
	lxi	h, buffer
	mov	a, b
	
loop1b:	dad	d		; adds 'length' to buffer for each word in the sentence so far
	dcr	a
	cpi	0
	jnz	loop1b
	
	pop	d
	pop	psw
	jmp	loop1		; get next word of string
				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get user's word

usrwrd:	mvi	c, string	; print getword message
	lxi	d, mess2	
	call 	bdos		

	mvi	c, cin
	lxi	h, buffr2	; load in the buffer for the word
	call 	bdos
	mov	m, a		; move that character to the memory at location in H-L
	inx	h		; point H-L to the next location in memory

loop2:	call	bdos		; loop2 gets the user's inserted word
	cpi	cr		; check if the character is a carriage return
	jz	enter

	mov	m, a		; move that character to the memory at location in H-L
	inx	h		; point H-L to the next location in memory
	jmp	loop2		; get next letter
	
enter:	mvi	m, ' '		; insert a space for formatting

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get user's number

	mvi	c, string	; print getnumber message
	lxi	d, mess3	
	call 	bdos

	mvi	c, cin		; get user's first digit
	call	bdos
	sui	'0'		; convert from ASCII > integer
	mov	l, a		
loop3:	call	bdos		; gets the user's second digit or a carriage return
	cpi	cr		
	jz	output		; if <CR> was entered, jump to output step
	
	sui	'0'		; these lines multiply the two digits into one number and stores it in L reg
	dad 	h		; double the old number
	add	l		; add 2x previous number (A <- <A> + 2*<H-L>)
	dad	h		
	dad	h		; L is now 8x the old number
	add	l		; add 8x the old number to A (A is now, in total, original A plus 10*(old number)
	mov	l, a		; return the new value in register L
	jmp	loop3		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Output sentence++
	
output:	mvi	c, string	; print output message
	lxi	d, mess4	
	call 	bdos

	mov	a, l
		
	cmp	b		; check if the word should be entered at the end of the word
	jc	zero		
	mov	a, b		; if so, replace the user's position with the last position
	jmp	simple		; jump to the loop that doesn't check if it's time to input the word until the end
	
zero:	cpi	0		; if the position is zero, print the first letter as capital
	jnz	notzro
	push	psw		; reg A is being destroyed, protect it

	lxi	h, buffr2	; get the first character of the user's input
	mov	a, m
	cpi	'a'		; if the character is a lowercase letter,
	jc	good1
	cpi	'z' + 1
	jnc	good1
	adi	'A' - 'a'	; convert to uppercase
	mov	m, a		; store it back in the buff2

good1:	lxi	h, buffer	; get the first character of the user's sentence
	mov	a, m
	cpi	'A'		; if the character is a lowercase letter,
	jc	good2
	cpi	'Z' + 1
	jnc	good2
	adi	'a' - 'A'	; convert to uppercase
	mov	m, a		; store it back in the buff2
	
good2:	pop	psw
	mov	a, b		; put the counter for 'words left to print' in A
	mvi	b, 0		; set b to zero so the code at 'chlast' will not print the word
	lxi	h, buffr2
	call	print		; prints the word
	jmp	simple

notzro:	lxi 	h, buffer	; If the word is not being inserted first or last
loop4:	call	print		; this loop prints and checks if it's time to print the word
	call	newbuf
	dcr	a		; decrement counter
	dcr	b		; decrement number of words left to print
	
	cpi	0		; check if it's time to insert the word
	jnz	loop4
	push	h
	lxi	h, buffr2
	call	print		; if yes, print it
	pop	h
	mov	a, b
	mvi	b, 0		; set b to zero so the code at 'chlast' will not print the word
	jmp	loop5

simple: lxi	h, buffer	; load the user's sentence
loop5:	cpi	0
	jz	chlast
	call	print		; this loop prints and DOES NOT check if it's time to print the word
				; this loop is used when the word is printed at the end
				; or if the word has already been printed
	call	newbuf
	dcr	a		; decrement number of words left to print
	jmp	loop5
chlast:	cmp	b		; checks if the word should be printed last
	jnc	final
	mvi	e, ' '		; print a space first
	mvi	c, cout
	call	bdos
	lxi	h, buffr2	; print the word
loop6:	mov	a, m		; this is a modified version of the print subroutine
	cpi	' '		; it does not print spaces
	jz	final
	inx	h
	mov	e, a		
	call	bdos
	jmp	loop6	

final:	lxi	h, punct	; print punctuation from memory
	mov	e, m
	mvi	c, cout
	call	bdos
	jmp	boot		; end of program

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SUBROUTINES

;Print subroutine
;	INPUT	:	H-L pair containing the address of a string to be printed with function 9
;	ACTION	:	Prints the word starting at the location stored in reg pair H-L
;			Uses function 2 and indirect addressing of the buffer
;			Requires a space ' ' in order to determine the end of a word
;			Also prints dollar signs that the user inputted
;			Returns the number of characters printed (reg D)
;	Reg destroyed :	H-L (incremented by however many characters are printed)
;			D - Returns the number of characters printed
;			E - Not necessary to preserve	
print:	push 	psw
	mvi	c, cout
	mvi	d, 0		; a counter for how many characters are printed
				; more accurately, how many times H-L is incremented
	
repeat:	mov	a, m
	inx	h
	inr	d
	cpi	'.'		; If a period or question mark is retrieved,
	jz	done		; end the subroutine ( do not print it )
	cpi	'?'
	jz	done
	mov	e, a		; print the char
	call	bdos
	cpi	' '		; if a space is printed, the word is completed
	jz	done
	jmp	repeat		; print next char if not punctuation
done:	pop	psw
	ret			; if it is punctuation, return
	

;newbuf subroutine
;	input	: pointer in H-L pair
;		  counter in reg D corresponding to how many
;		    times the H-L pair has already been incremented	
;	actions	: increment that pointer by 'length'
;	reg dest: H-L (it is incremented by length)
;	limits	: 

newbuf:	push	psw
	mvi	a, length
	sub	d
	adc	l
	jnc	nocrry
	inr	h
nocrry:	mov	l, a
	pop	psw
	ret
	
;MESSAGES

mess1:	db	'        Welcome to the ENHANCED Sentence Editor!',lf, lf, cr
	db	lf, cr, 'Enter     your    boring    sentence : $'
mess2:	db	lf, cr, 'Type a word for ENHANCEMENT: $'
mess3:	db	lf, cr, 'Insert word after how many words : $'
mess4:	db	lf, lf, cr, 'ENHANCED sentence: $'

punct:	ds	2
buffr2:	ds 	15

buffer:	ds 	100	; where the user's sentence is stored.
			; it's big because small words take up the same
			; space as big words

	ds 10
sp0 	equ 	$
	end