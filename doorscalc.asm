;Doors calculator By David Badiei
org 4000h

mov byte [controlSet],cl

continuetocontrol:
;Change to mode 12
mov ax,0012h
int 10h

;Set background color
call paintbg2

;Draw title bar
call drawtitlebar

;Draw widgets
call drawwidgets

cmp byte [controlSet],0
je keyboardControl

call mousedrvsetup
call mouse_enable

;Get first number
call drawfirstnumber
sti
progLoop:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick
draw:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing:
mov ah,1
int 16h
jz continueonon
mov ah,00
int 16h
jmp getinput1
continueonon:
hlt
keepkeepgoing:
jmp progLoop

keyboardControl:
call drawfirstnumber
call getoldlocation
keyloop1:
pusha
mov ah,00
int 16h
cmp ah,4bh
je goleft
cmp ah,4dh
je goright
cmp ah,50h
je godown
cmp ah,48h
je goup
cmp al,1bh
je endprogkey
cmp ax,3b00h
je f1keyclick
jmp userenterkey
continueon:
mov byte [cursorColor],00h
call drawcursor
jmp keyloop1

endprogkey:
popa

doneprog:
mov ah,00
mov al,3
int 10h
retf


keystep db 0
num1 dw 0
num2 dw 0
num11 times 6 db 0
num21 times 6 db 0
lineX dw 175
lineY dw 222
xpos dw 0
ypos dw 0
prevxpos dw 0
prevypos dw 0
tmpcursor dw 0
tmpcursor2 dw 0
curStat db 0
X dw 0
Y dw 0
Color db 0
titleString db 'Doors Calculator',0
firstNum db 'Enter first number:',0
secondNum db 'Enter second number:',0
biosColor db 0
controlSet db 0
cursorColor db 0
mousepropexists db 0
mouseupdated db 0
prevColor db 0
msoldloc times 8 db 0
bootdev db 0
counternum1 dw 0
bslast db 0
step db 1
%include 'calcsprites.inc'
fontlocation:
incbin 'fontdata.bin'

f1keyclick:
popa
cmp byte [keystep],2
jle lbuttonclick
jmp click3

userenterkey:
popa
cmp byte [keystep],0
je getinput1
cmp byte [keystep],1
je getinput2
jmp continueon

getinput2:
mov di,num21
jmp continueinput

getinput1:
push ax
mov ax,word [X]
mov bx,word [Y]
mov cx,word [lineX]
mov dx,word [lineY]
mov word [X],cx
mov word [Y],dx
pop ax
cmp al,0dh
je num2get ;Replace this with num2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
cmp al,08h
je backspace1
cmp word [counternum1],5
je continueonon
;cmp byte [bslast],1
;jne drawchar
add word [X],6
add word [lineX],6
mov byte [bslast],0
drawchar:
push dx
push di
cmp byte [step],2
je getinput2
mov di,num11
continueinput:
add di,word [counternum1]
stosb
mov dh,0
mov dl,al
call getfont
inc word [counternum1]
pop di
pop dx
add cx,6
mov word [lineX],cx
mov word [X],ax
mov word [Y],bx
jmp continueonon
backspace1:
cmp word [counternum1],0
je continueonon
pusha
mov byte [buttonornot],1
mov ax,cx
mov bx,word [Y]
add cx,5
add dx,7
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
popa
push di
mov di,num11
add di,word [counternum1]
mov byte [di],0
pop di
mov byte [Color],0
dec word [counternum1]
sub word [lineX],6
mov byte [bslast],1
jmp continueonon

drawstep3:
mov byte [buttonornot],1
mov ax,150
mov bx,200
mov cx,500
mov dx,250
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov word [X],247
mov word [Y],100
mov byte [Color],0
mov si,optionstr
call print_string
mov ax,100
mov bx,150
mov cx,200
mov dx,200
call drawbutton
mov word [X],145
mov word [Y],170
mov si,addspr
call dispsprites
mov ax,410
mov bx,150
mov cx,510
mov dx,200
call drawbutton
mov word [X],455
mov word [Y],170
mov si,subspr
call dispsprites
mov ax,100
mov bx,250
mov cx,200
mov dx,300
call drawbutton
mov word [X],145
mov word [Y],270
mov si,mulspr
call dispsprites
mov ax,410
mov bx,250
mov cx,510
mov dx,300
call drawbutton
mov word [X],455
mov word [Y],270
mov si,divspr
call dispsprites
mov ax,255
mov bx,350
mov cx,355
mov dx,400
call drawbutton
mov word [X],300
mov word [Y],370
mov si,sqrspr
call dispsprites
cmp byte [controlSet],0
je keyloop1
jmp continueonon
optionstr db 'Choose an option below:',0

num2get:
inc byte [keystep]
inc byte [step]
cmp byte [step],3
je drawstep3
call drawsecondnumber
mov byte [counternum1],0
mov word [lineX],175
mov word [lineY],222
jmp continueonon

drawsecondnumber:
mov ax,150
mov bx,200
mov cx,500
mov dx,250
call drawbutton
mov byte [buttonornot],1
mov ax,175
mov bx,220
mov cx,475
mov dx,232
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov word [X],152
mov word [Y],202
mov byte [Color],0
mov si,secondNum
call print_string
ret

drawfirstnumber:
mov ax,150
mov bx,200
mov cx,500
mov dx,250
call drawbutton
mov byte [buttonornot],1
mov ax,175
mov bx,220
mov cx,475
mov dx,232
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov word [X],152
mov word [Y],202
mov byte [Color],0
mov si,firstNum
call print_string
ret

paintbg2:
mov ax,0xc200
mov bh,0
int 15h
mov byte [buttonornot],1
mov ax,0
mov bx,0
mov cx,640
mov dx,480
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov ax,0xc200
mov bh,1
int 15h
ret


print_string_char:
mov ah,0eh
loop:
lodsb
test al,al
jz donestr
int 10h
jmp loop
donestr:
ret

print_string:
mov dx,0
loopprint:
lodsb
mov dl,al
test al,al
jz donestr
cmp al,0ah
je newline
call getfont
add word [X],6
continueprint:
jmp loopprint
newline:
mov word [X],0
add word [Y],8
jmp continueprint

goleft:
cmp word [xpos],4
jle continueon
call printoldlocation
sub word [xpos],7
popa
mov cx, word [xpos]
call getoldlocation
jmp continueon

goright:
cmp word [xpos],636
jge continueon
call printoldlocation
add word [xpos],7
popa
mov cx, word [xpos]
call getoldlocation
jmp continueon

godown:
cmp word [ypos],476
jge continueon
call printoldlocation
add word [ypos],7
popa
mov dx, word [ypos]
call getoldlocation
jmp continueon

goup:
cmp word [ypos],4
jle continueon
call printoldlocation
sub word [ypos],7
popa
mov dx, word [ypos]
call getoldlocation
jmp continueon

mouseSet:
mov byte [controlSet],1
jmp continuetocontrol

keyboardSet:
mov byte [controlSet],0
jmp continuetocontrol

drawcursor:
push ax
mov al,byte [cursorColor]
mov byte [Color],al
mov ax, word [xpos]
mov word [X],ax
mov ax, word [ypos]
mov word [Y],ax
pop ax
mov cx,word [X]
mov dx,word [Y]
call displayblackpixel
inc word [X]
call displayblackpixel
inc word [X]
call displayblackpixel
sub word [X],2
inc word [Y]
call displayblackpixel
inc word [Y]
call displayblackpixel
sub word [Y],2
inc word [X]
inc word [Y]
call displayblackpixel
inc word [X]
inc word [Y]
call displayblackpixel
inc word [X]
inc word [Y]
call displayblackpixel
sub word [X],3
sub word [Y],3
ret


displayblackpixel:
pusha
push es
mov ax,0A000h
mov es,ax
pop es
pusha
call putpixel
popa
popa
ret

drawtitlebar:
mov byte [buttonornot],1
mov ax,0
mov bx,0
mov cx,640
mov dx,13
mov byte [Color],01h
call drawbutton
mov byte [buttonornot],0
pusha
mov word [X],1
mov word [Y],3
mov si,titleString
mov byte [Color],0xff
call print_string
popa
mov word [X],621
mov word [Y],2
mov byte [Color],04h
looper:
pusha
push es
mov ax,0A000h
mov es,ax
pop es
pusha
call putpixel
popa
popa
inc word [X]
cmp word [X],636
je addonelevel
cmp word [Y],11
je donedrawexit
jmp looper
donedrawexit:
mov word [X],621
mov byte [Color],01h
call discharpix
mov word [X],626
mov word [Y],3
xor dh,dh
mov dl,'X'
mov byte [Color],0xff
call getfont
ret
addonelevel:
inc word [Y]
mov word [X],621
jmp looper


putpixel:
pusha
push es
mov ax,0A000h
mov es,ax
mov ax,word [Y]
mov dx,80
mul dx
mov bx,word [X]
mov cl,bl
shr bx,03
add bx,ax
mov dx,03CEh
and cl,07h
xor cl,07h
mov ah,01h
shl ah,cl
mov al,08h
out dx,ax
mov ax,0205h
out dx,ax
mov al,[es:bx]
and byte [Color],0fh
mov al,byte [Color]
mov [es:bx],al
pop es
popa
ret

getpixel:
pusha
push es
mov ax,0A000h
mov es,ax
mov ax,80
mov dx,word [Y]
mul dx
mov si,word [X]
mov cx,si
shr si,3
add si,ax
and cl,07h
xor cl,07h
mov ch,1
shl ch,cl
mov dx,03CEh
mov ax,772
xor bl,bl
gp1:
out dx,ax
mov bh,[es:si]
and bh,ch
neg bh
rol bx,0001h
dec ah
jge gp1
mov al,bl
mov byte [prevColor],al
pop es
popa
ret


inttostr:
pusha
mov cx,0
mov bx,10
pushit:
xor dx,dx
div bx
inc cx
push dx
test ax,ax
jnz pushit
popit:
pop dx
add dl,30h
pusha
mov dh,0
call getfont
add word [X],6
popa
inc di
dec cx
jnz popit
popa
ret

getfont:
pusha
mov ax,7
mul dx
mov bx,ax
mov cx,0
printLine:
cmp cx,7
je discharend
inc cx
mov si,fontlocation
add si,bx
lodsb
inc bx
push ax
and al,128
cmp al,128
jne nxtprint
call discharpix
nxtprint:
pop ax
inc word [X]
push ax
and al,64
cmp al,64
jne nxtprintB
call discharpix
nxtprintB:
pop ax
inc word [X]
push ax
and al,32
cmp al,32
jne nxtprintC
call discharpix
nxtprintC:
pop ax
inc word [X]
push ax
and al,16
cmp al,16
jne nxtprintD
call discharpix
nxtprintD:
pop ax
inc word [X]
push ax
and al,8
cmp al,8
jne dislineend
call discharpix
dislineend:
pop ax
inc word [Y]
sub word [X],4
jmp printLine
discharend:
popa
sub word [Y],7
ret

discharpix:
pusha
push es
mov ax,0A000h
mov es,ax
call putpixel
pop es
popa
ret

disxandy:
mov ax,word [xpos]
call inttostr
add word [X],100
mov ax,word [ypos]
call inttostr
ret


mousedrvsetup:
push es
push bx
int 11h
test ax,4
jz nomousefound
mov bh,3
mov ax,0xc205
int 15h
jc nomousefound
mov bh,6
mov ax,0xc202
int 15h
jc nomousefound
mov ax,0xc203
mov bh,3
int 15h
jc nomousefound
push cs
pop es
mov bx,donemousehand
mov ax,0c207h
int 15h
jc nomousefound
clc
jmp donemssetup
nomousefound:
stc
donemssetup:
pop bx
pop es
ret

mouse_enable:
push es
push bx
call mouse_disable
push cs
pop es
mov bx,mouse_handler
mov ax,0xc207
int 15h
mov ax,0xc200
mov bh,1
int 15h
pop bx
pop es
ret

mouse_disable:
push es
push bx
mov ax,0xc200
xor bx,bx
int 15h
mov es,bx
mov ax,0xc207
int 15h
pop bx
pop es
ret

getoldlocation:
;pusha
mov ax,word [xpos]
mov word [prevxpos],ax
mov word [X],ax
mov ax,word [ypos]
mov word [prevypos],ax
mov word [Y],ax
call getpixel
mov al,byte [prevColor]
mov [msoldloc],al
inc word [X]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+1],al
inc word [X]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+2],al
sub word [X],2
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+3],al
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+4],al
sub word [Y],2
inc word [X]
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+5],al
inc word [X]
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+6],al
inc word [X]
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov [msoldloc+7],al
;popa
ret

printoldlocation:
;pusha
mov ax,word [prevxpos]
mov word [X],ax
mov ax,word [prevypos]
mov word [Y],ax
mov al,byte [msoldloc]
mov byte [Color],al
call discharpix
inc word [X]
mov al,byte [msoldloc+1]
mov byte [Color],al
call discharpix
inc word [X]
mov al,byte [msoldloc+2]
mov byte [Color],al
call discharpix
sub word [X],2
inc word [Y]
mov al,byte [msoldloc+3]
mov byte [Color],al
call discharpix
inc word [Y]
mov al,byte [msoldloc+4]
mov byte [Color],al
call discharpix
sub word [Y],2
inc word [X]
inc word [Y]
mov al,byte [msoldloc+5]
mov byte [Color],al
call discharpix
inc word [X]
inc word [Y]
mov al,byte [msoldloc+6]
mov byte [Color],al
call discharpix
inc word [X]
inc word [Y]
mov al,byte [msoldloc+7]
mov byte [Color],al
call discharpix
;popa
ret

mouse_handler:
push bp
mov bp,sp
push ds
push ax
push bx
push cx
push dx
push cs
pop ds
pusha
call printoldlocation
popa
mov al,[bp+6+6]
mov bl,al
mov cl,3
shl al,cl
sbb dh,dh
cbw
mov dl,[bp+6+2]
mov al,[bp+6+4]
neg dx
mov cx,[ypos]
add dx,cx
mov cx,[xpos]
add ax,cx
mov [curStat],bl
cmp ax,0
jle skipset
cmp ax,636
jge skipset
mov [xpos],ax
cmp dx,0
jle skipset
cmp dx,476
jge skipset
mov [ypos],dx
skipset:
call getoldlocation
mov ax,[xpos]
mov dx,[ypos]
mov [tmpcursor],ax
mov [tmpcursor2],dx
mov word [xpos],0
mov word [ypos],0
mov byte [cursorColor],01h
pusha
call drawcursor
popa
mov [xpos],ax
mov [ypos],dx
mov word [X],3
mov word [Y],3
mov byte [Color],0fh
call putpixel
pop dx
pop cx
pop bx
pop ax
pop ds
pop bp
donemousehand:
retf

lbuttonclick:
cmp word [xpos],619
jle l1
cmp word [xpos],636
jg l1
cmp word [ypos],1
jle l1
cmp word [ypos],13
jg l1
;call mouse_disable
jmp doneprog
l1:
cmp byte [step],3
je click2
cmp byte [step],5
je click3
cmp byte [controlSet],0
je keyloop1
jmp draw
click2:
cmp word [xpos],99
jle l2
cmp word [xpos],200
jg l2
cmp word [ypos],149
jle l2
cmp word [ypos],200
jg l2
inc byte [step]
call drawanswerstep
mov si,num11
mov di,num1
call stringtoint
mov word [num1],ax
mov si,num21
mov di,num2
call stringtoint
mov word [num2],ax
mov ax,word [num1]
mov bx,word [num2]
add ax,bx
mov word [X],290
mov word [Y],210
mov byte [Color],00h
call inttostr
jmp endloop
l2:
cmp word [xpos],409
jle l3
cmp word [xpos],510
jg l3
cmp word [ypos],149
jle l3
cmp word [ypos],200
jg l3
inc byte [step]
call drawanswerstep
mov si,num11
mov di,num1
call stringtoint
mov word [num1],ax
mov si,num21
mov di,num2
call stringtoint
mov word [num2],ax
mov ax,word [num1]
mov bx,word [num2]
sub ax,bx
mov word [X],290
mov word [Y],210
mov byte [Color],00h
call inttostr
jmp endloop
l3:
cmp word [xpos],99
jle l6
cmp word [xpos],200
jg l6
cmp word [ypos],250
jle l6
cmp word [ypos],300
jg l6
inc byte [step]
call drawanswerstep
mov si,num11
mov di,num1
call stringtoint
mov word [num1],ax
mov si,num21
mov di,num2
call stringtoint
mov word [num2],ax
mov ax,word [num1]
mov bx,word [num2]
mul bx
mov word [X],290
mov word [Y],210
mov byte [Color],00h
call inttostr
jmp endloop
l6:
cmp word [xpos],254
jle l7
cmp word [xpos],355
jg l7
cmp word [ypos],354
jle l7
cmp word [ypos],400
jg l7
inc byte [step]
call drawanswerstep
mov si,num11
mov di,num1
call stringtoint
mov word [num1],ax
mov bx,word [num1]
mov cx,1
mov ax,1
sqrtloop:
inc cx
mov ax,cx
mul cx
cmp bx,ax
jae sqrtloop
dec cx
mov ax,cx
mov word [X],290
mov word [Y],210
mov byte [Color],00h
call inttostr
jmp endloop
l7:
cmp word [xpos],409
jle l7
cmp word [xpos],510
jg l7
cmp word [ypos],249
jle l7
cmp word [ypos],300
jg l7
inc byte [step]
call drawanswerstep
mov byte [Color],0
mov word [X],247
mov word [Y],220
mov si,remainderstr
call print_string
mov si,num11
mov di,num1
call stringtoint
mov word [num1],ax
mov si,num21
mov di,num2
call stringtoint
mov word [num2],ax
mov ax,word [num1]
mov bx,word [num2]
mov dx,0
div bx
mov word [X],290
mov word [Y],210
mov byte [Color],00h
call inttostr
mov ax,dx
mov word [X],310
mov word [Y],220
mov byte [Color],00h
call inttostr
jmp endloop
click3:
cmp word [xpos],619
jle l4
cmp word [xpos],636
jg l4
cmp word [ypos],1
jle l4
cmp word [ypos],13
jg l4
;call mouse_disable
jmp doneprog
l4:
cmp word [xpos],309
jle l5
cmp word [xpos],345
jg l5
cmp word [ypos],289
jle l5
cmp word [ypos],305
jg l5
mov byte [counter],0
mov word [lineX],175
mov word [counternum1],0
mov byte [step],1
mov byte [keystep],0
mov cx,0
clearcursor:
mov di,msoldloc
add di,cx
mov byte [di],0x0f
inc cx
cmp cx,8
jle clearcursor
mov cx,0
clearnummem:
mov di,num11
add di,cx
mov byte [di],0
inc cx
cmp cx,11
jle clearnummem
mov cl,byte [controlSet]
jmp 1000h:4000h
l5:
cmp byte [controlSet],0
je keyloop1
jmp draw

answerstr db 'Answer:',0
remainderstr db 'Remainder:',0
multiplier dw 0
tmp dw 0

endloop:
cmp byte [controlSet],0
je keyloop1
sti
progLoop1:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je click3
draw1:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing1:
mov ah,1
int 16h
jz continueonon1
mov ah,00
int 16h
continueonon1:
hlt
keepkeepgoing1:
jmp progLoop

drawanswerstep:
inc byte [step]
call paintbg2
call drawtitlebar
mov ax,100
mov bx,150
mov cx,550
mov dx,350
call drawbutton
mov byte [buttonornot],1
mov ax,140
mov bx,190
mov cx,510
mov dx,310
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov byte [Color],00h
mov si,answerstr
mov word [X],247
mov word [Y],210
call print_string
mov byte [buttonornot],1
mov ax,310
mov bx,290
mov cx,345
mov dx,305
mov byte [Color],08h
call drawbutton
mov byte [buttonornot],0
mov byte [Color],0fh
mov word [X],322
mov word [Y],293
mov si,ok
call print_string
call getoldlocation
ret
ok db 'OK',0

stringtoint:
pusha
mov ax,si
call getStringlength
add si,ax
dec si
mov cx,ax
xor bx,bx
xor ax,ax
mov word [multiplier],1
loopconvert:
mov ax,0
mov byte al,[si]
sub al,30h
mul word [multiplier]
add bx,ax
push ax
mov word ax,[multiplier]
mov dx,10
mul dx
mov word [multiplier],ax
pop ax
dec cx
cmp cx,0
je finish
dec si
jmp loopconvert
finish:
mov word [tmp],bx
popa
mov word ax,[tmp]
ret

getStringlength:
	pusha
	mov bx,ax
	mov cx,0
more:
	cmp byte [bx],0
	je donelength
	inc bx
	inc cx
	jmp more
donelength:
	mov word [tmp],cx
	popa
	mov ax,[tmp]
	ret

getuserlineinput:
mov word [X],175
mov word [Y],222
mov byte [Color],0
mov byte [counter],0
loopuserInput:
mov ah,00
int 16h
cmp al,08h
je delchar
cmp al,0dh
je doneuserInput
cmp byte [counter],12
je loopuserInput
add word [X],6
stosb
xor dh,dh
mov dl,al
call getfont
inc byte [counter]
jmp loopuserInput
doneuserInput:
mov al,0
stosb
ret
eol:
mov word [X],175
jmp loopuserInput

delchar:
add word [X],6
cmp byte [counter],0
je eol
sub word [X],6
mov byte [buttonornot],1
mov ax,word [X]
mov bx,word [Y]
mov cx,ax
add cx,5
mov dx,232
mov byte [Color],0fh
pusha
call drawbutton
popa
mov word [X],ax
mov word [Y],bx
mov byte [Color],0
mov byte [buttonornot],0
dec byte [counter]
sub word [X],6
dec di
mov byte [di],0
jmp loopuserInput
counter db 0

outputnum:
mov ah,0
mov bl,10
div bl
mov bh,ah
add al,'0'
add word [X],7
push dx
xor dx,dx
mov dl,al
mov byte [Color],0
call getfont
pop dx
mov al,bh
add al,'0'
add word [X],7
push dx
xor dx,dx
mov dl,al
mov byte [Color],0
call getfont
pop dx
ret

drawwidgets:
ret

drawbutton:
pusha
mov word [X],ax
mov word [Y],bx
cmp byte [buttonornot],0
jne drawbutton1
mov byte [Color],07h
drawbutton1:
call discharpix
inc word [X]
cmp word [X],cx
jne drawbutton1
mov word [X],ax
inc word [Y]
cmp word [Y],dx
jne drawbutton1
popa
ret
buttonornot db 0

dispsprites:
pusha
loopsprite:
lodsb
cmp al,0
je skipahead
cmp al,1
je printonesprite
cmp al,2
je nextline
popa
ret
skipahead:
inc word [X]
jmp loopsprite
printonesprite:
mov byte [Color],00h
call discharpix
inc word [X]
jmp loopsprite
nextline:
sub word [X],10
inc word [Y]
jmp loopsprite

