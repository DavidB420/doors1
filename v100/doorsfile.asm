;Doors file manager By David Badiei
org 4000h

mov byte [controlSet],cl

;Get boot drive number
mov byte [bootdev],dl

continuetocontrol:
;Change to mode 12
mov ax,0012h
int 10h

;Set background color
call paintbg2

;Draw title bar
call drawtitlebar

cmp byte [controlSet],0
je keyboardControl

call mousedrvsetup
call mouse_enable

call drawfirstscreen
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
continueonon:
hlt
keepkeepgoing:
jmp progLoop

keyboardControl:
call drawfirstscreen
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
pop ax
pop bx
mov ax,2000h
mov ds,ax
mov es,ax
mov cl,byte [controlSet]
add sp,4
jmp 2000h:401dh

keystep db 0
fat12fn2 times 14 db 0
fat12fn times 14 db 0
progFN times 14 db 0
progFN2 times 14 db 0
SectorsPerTrack dw 18
Sides dw 2
fileSize dw 0
cluster dw 0
lineX dw 175
lineY dw 222
counterdel dw 0
xpos dw 0
ypos dw 0
prevxpos dw 0
prevypos dw 0
tmpcursor dw 0
tmpcursor2 dw 0
curStat db 0
X dw 0
Y dw 0
titleString db 'Doors File Manager',0
optionString db 'Please choose an option below:',0
enterPrompt db 'Enter file name:',0
Color db 0
tmp dw 0
biosColor db 0
controlSet db 0
cursorColor db 0
mousepropexists db 0
mouseupdated db 0
prevColor db 0
msoldloc times 8 db 0
bootdev db 0
bslast db 0
yesorno db 0
delorview db 0
errorfnf db 'Error: File not found!',0
ok db 'OK',0
disk_buffer equ 0000h
fat equ 0ac00h
file equ 4000h
%include 'filesprites.inc'
fontlocation:
incbin 'fontdata.bin'

drawfirstscreen:
mov word [X],213
mov word [Y],100
mov byte [Color],0
mov si,optionString
call print_string
mov ax,100
mov bx,150
mov cx,150
mov dx,200
call drawbutton
mov word [X],120
mov word [Y],170
mov si,listspr
call dispsprites
mov word [X],96
mov word [Y],210
mov si,liststr
call print_string
mov ax,200
mov bx,150
mov cx,250
mov dx,200
call drawbutton
mov word [X],220
mov word [Y],170
mov si,delspr
call dispsprites
mov word [X],207
mov word [Y],210
mov si,delstr
call print_string
mov ax,300
mov bx,150
mov cx,350
mov dx,200
call drawbutton
mov word [X],320
mov word [Y],170
mov si,renspr
call dispsprites
mov word [X],307
mov word [Y],210
mov si,renstr
call print_string
mov ax,400
mov bx,150
mov cx,450
mov dx,200
call drawbutton
mov word [X],420
mov word [Y],170
mov si,vwrspr
call dispsprites
mov word [X],407
mov word [Y],210
mov si,vwrstr
call print_string
ret
liststr db 'List files',0
delstr db 'Delete',0
renstr db 'Rename',0
vwrstr db 'Viewer',0

f1keyclick:
popa
cmp byte [keystep],0
je lbuttonclick
cmp byte [keystep],1
je lbuttonclick1
cmp byte [keystep],2
je lbuttonclick2
cmp byte [keystep],3
je lbuttonclick2
cmp byte [keystep],4
je lbuttonclick2

userenterkey:
popa
cmp byte [keystep],2
je delinput
cmp byte [keystep],3
je reninput
cmp byte [keystep],4
je delinput
jmp continueon

paintbg2:
mov byte [buttonornot],1
mov ax,0
mov bx,0
mov cx,640
mov dx,480
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
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
mov ax,0xc200
mov bh,1
int 15h
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

drawwidgets:
ret

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
cmp word [xpos],99
jle l2
cmp word [xpos],150
jg l2
cmp word [ypos],149
jle l2
cmp word [ypos],200
jg l2
jmp listsub
l2:
cmp word [xpos],199
jle l3
cmp word [xpos],250
jg l3
cmp word [ypos],149
jle l3
cmp word [ypos],200
jg l3
jmp delsub
l3:
cmp word [xpos],299
jle l4
cmp word [xpos],350
jg l4
cmp word [ypos],149
jle l4
cmp word [ypos],200
jg l4
jmp rensub
l4:
cmp word [xpos],399
jle l5
cmp word [xpos],450
jg l5
cmp word [ypos],149
jle l5
cmp word [ypos],200
jg l5
jmp viewsub
l5:
cmp byte [controlSet],0
je keyloop1
jmp draw

viewsub:
mov byte [keystep],4
call paintbg2
call drawtitlebar
call getoldlocation
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
mov byte [Color],0
mov word [X],152
mov word [Y],202
mov byte [delorview],1
mov si,enterPrompt
call print_string
cmp byte [controlSet],0
je keyloop1
sti
progLoop4:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick2
draw4:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing4:
mov ah,1
int 16h
jz continueonon4
mov ah,00
int 16h
jmp delinput
continueonon4:
hlt
keepkeepgoing4:
jmp progLoop4

printviewstring:
mov ax,0xc200
mov bh,0
int 15h
mov dx,0
redraw:
cmp cx,0
je loopy
dec cx
loopprint1:
push ds
mov ax,3000h
mov ds,ax
lodsb
pop ds
cmp al,10
jne loopprint1
jmp redraw
loopy:
push ds
mov ax,3000h
mov ds,ax
lodsb
pop ds
cmp al,10
jne skipreturn
jmp newline1
jmp redraw
skipreturn:
mov dl,al
test al,al
jz donestr1
cmp al,0ah
je newline1
cmp byte [cutter],1
je dontwrite
call getfont
dontwrite:
add word [X],6
cmp word [X],636
jg cutline
continueprint1:
cmp word [Y],472
jge donestr
jmp loopy
newline1:
mov byte [cutter],0
cmp word [Y],472
jge donestr
mov word [X],0
add word [Y],8
jmp redraw
donestr1:
mov ax,0xc200
mov bh,1
int 15h
mov byte [skipper],1
ret
cutline:
mov byte [cutter],1
jmp continueprint1
skiplines dw 0
cutter db 0

viewercontrols:
cmp ah,48h
je uparrowview
cmp byte [skipper],0
jne continueonon5
cmp ah,50h
je downarrowview
jmp continueonon5
downarrowview:
mov word [X],1
mov word [Y],15
mov byte [Color],0fh
mov si,file
mov word cx,[skiplines]
call printviewstring
inc word [skiplines]
mov word cx,[skiplines]
mov word [X],1
mov word [Y],15
mov byte [Color],0
mov si,file
call printviewstring
mov byte [curStat],0
cmp byte [controlSet],0
je viewkeyinput
jmp continueonon5
uparrowview:
cmp word [skiplines],0
je continueonon5
mov byte [skipper],0
mov word [X],1
mov word [Y],15
mov byte [Color],0fh
mov si,file
mov word cx,[skiplines]
call printviewstring
dec word [skiplines]
mov word cx,[skiplines]
mov word [X],1
mov word [Y],15
mov byte [Color],0
mov si,file
call printviewstring
mov byte [curStat],0
cmp byte [controlSet],0
je viewkeyinput
jmp continueonon5
skipper db 0

viewer:
call paintbg2
call drawtitlebar
call getoldlocation
call loadfile
mov byte [buttonornot],1
mov ax,603
mov bx,2
mov cx,618
mov dx,11
mov byte [Color],0bh
call drawbutton
mov word [X],610
mov word [Y],3
xor dh,dh
mov dl,'>'
mov byte [Color],0xff
call getfont
mov ax,585
mov bx,2
mov cx,600
mov dx,11
mov byte [Color],0bh
call drawbutton
mov word [X],592
mov word [Y],3
xor dh,dh
mov dl,'<'
mov byte [Color],0xff
call getfont
mov byte [buttonornot],0
mov word [X],1
mov word [Y],15
mov byte [Color],0
mov si,file
mov cx,0
call printviewstring
cmp byte [controlSet],0
je viewkeyinput
sti
progLoop5:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick3
draw5:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing5:
mov ah,1
int 16h
jz continueonon5
mov ah,00
int 16h
jmp viewercontrols
continueonon5:
hlt
keepkeepgoing5:
jmp progLoop5

viewkeyinput:
mov ah,00
int 16h
cmp ah,48h
je uparrowview
cmp ah,50h
je downarrowview
cmp ax,3b00h
je closeview 
jmp viewkeyinput

lbuttonclick3:
cmp word [xpos],619
jle l31
cmp word [xpos],636
jg l31
cmp word [ypos],1
jle l31
cmp word [ypos],13
jg l31
closeview:
mov byte [skipper],0
mov word [skiplines],0
mov word [lineX],175
mov word [counterdel],0
mov byte [cutter],0
mov byte [delorview],0
mov byte [keystep],0
call paintbg2
call drawtitlebar
call drawfirstscreen
call getoldlocation
cmp byte [controlSet],0
je keyloop1
jmp draw
l31:
cmp word [xpos],584
jle l32
cmp word [xpos],600
jg l32
cmp word [ypos],1
jle l32
cmp word [ypos],13
jg l32
jmp uparrowview
l32:
cmp word [xpos],602
jle l32
cmp word [xpos],618
jg l32
cmp word [ypos],1
jle l32
cmp word [ypos],13
jg l32
cmp byte [skipper],0
jne continueonon5
jmp downarrowview
l33:
cmp byte [controlSet],0
je keyloop1
jmp draw2

loadfile:
mov si,progFN
mov di,fat12fn
call makefnfat12
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov di,disk_buffer
mov si,fat12fn
mov bx,0
mov ax,0
findfn1:
mov cx,11
cld
repe cmpsb
je foundfn1
inc bx
add ax,32
mov si,fat12fn
mov di,disk_buffer
add di,ax
cmp bx,224
jle findfn1
cmp bx,224
jae fnnotfound
foundfn1:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
push ax
mov ax,word [di+1ch]
mov word [fileSize],ax
pop ax
mov ax,word [di+1Ah]
mov word [cluster],ax
push ax
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,2
mov al,9
mov si,fat
mov bx,si
int 13h
pop ax
push ax
mov di,file
mov bx,di
call twelvehts
push es
mov ax,3000h
mov es,ax
mov ax,0201h
int 13h
pop es
mov bp,0
pop ax
loadnextclust:
mov cx,ax
mov dx,ax
shr dx,1
add cx,dx
mov bx,fat
add bx,cx
mov dx,word [bx]
test ax,1
jnz odd1
even1:
and dx,0fffh
jmp end
odd1:
shr dx,4
end:
mov ax,dx
mov word [cluster],dx
call twelvehts
add bp,512
mov si,file
add si,bp
mov bx,si
push es
mov ax,3000h
mov es,ax
mov ax,0201h
int 13h
pop es
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust
ret

twelvehts:
add ax,31
push bx
push ax
mov bx,ax
mov dx,0
div word [SectorsPerTrack]
add dl,01h
mov cl,dl
mov ax,bx
mov dx,0
div word [SectorsPerTrack]
mov dx,0
div word [Sides]
mov dh,dl
mov ch,al
pop ax
pop bx
mov dl,byte [bootdev]
ret

rensub:
mov byte [keystep],3
call paintbg2
call drawtitlebar
call getoldlocation
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
mov byte [Color],0
mov word [X],152
mov word [Y],202
mov si,origPrompt
call print_string
cmp byte [controlSet],0
je keyloop1
sti
progLoop3:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick2
draw3:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing3:
mov ah,1
int 16h
jz continueonon3
mov ah,00
int 16h
jmp reninput
continueonon3:
hlt
keepkeepgoing3:
jmp progLoop3
origPrompt db 'Enter old file name:',0
newPrompt db 'Enter new file name:',0
stepRen db 0

renamefile:
mov byte [stepRen],0
mov si,progFN
mov di,fat12fn
call makefnfat12
mov si,progFN2
mov di,fat12fn2
call makefnfat12
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov di,disk_buffer
mov si,fat12fn
mov bx,0
mov ax,0
findfn:
mov cx,11
cld
repe cmpsb
je foundfn
inc bx
add ax,32
mov si,fat12fn
mov di,disk_buffer
add di,ax
cmp bx,224
jle findfn
foundfn:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
mov bx,ax
mov cx,11
mov si,fat12fn2
replacefn:
mov dh, byte [si]
mov byte [di], dh
inc si
inc di
loop replacefn
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
jmp donedel

nextstep:
inc byte [stepRen]
cmp byte [stepRen],2
je renamefile
cmp byte [stepRen],1
jne notsecondstep
mov word [X],152
mov word [Y],202
mov byte [Color],07h
mov si,origPrompt
call print_string
mov byte [Color],0
mov word [X],152
mov word [Y],202
mov si,newPrompt
call print_string
mov byte [buttonornot],1
mov ax,175
mov bx,220
mov cx,475
mov dx,232
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov word [lineX],175
mov word [lineY],222
mov byte [counterdel],0
jmp continueonon3
notsecondstep:
mov byte [stepRen],0
jmp donedel

reninput:
push ax
mov ax,word [X]
mov bx,word [Y]
mov cx,word [lineX]
mov dx,word [lineY]
mov word [X],cx
mov word [Y],dx
pop ax
cmp al,0dh
je nextstep
cmp al,08h
je backspace2
cmp word [counterdel],13
je continueonon3
add word [X],6
add word [lineX],6
mov byte [bslast],0
drawchar2:
push dx
push di
cmp byte [stepRen],1
jne skipthis
mov di,progFN2
jmp continueinput2
skipthis:
mov di,progFN
continueinput2:
add di,word [counterdel]
stosb
mov dh,0
mov dl,al
call getfont
inc word [counterdel]
pop di
pop dx
add cx,6
mov word [lineX],cx
mov word [X],ax
mov word [Y],bx
jmp continueonon3
backspace2:
cmp word [counterdel],0
je continueonon3
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
cmp byte [stepRen],1
jne ogfileset
mov di,progFN2
jmp skipthis2
ogfileset:
mov di,progFN
skipthis2:
add di,word [counterdel]
mov byte [di],0
pop di
mov byte [Color],0
dec word [counterdel]
sub word [lineX],6
mov byte [bslast],1
jmp continueonon3

delsub:
mov byte [keystep],2
call paintbg2
call drawtitlebar
call getoldlocation
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
mov byte [Color],0
mov word [X],152
mov word [Y],202
mov si,enterPrompt
call print_string
cmp byte [controlSet],0
je keyloop1
sti
progLoop2:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick2
draw2:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing2:
mov ah,1
int 16h
jz continueonon2
mov ah,00
int 16h
jmp delinput
continueonon2:
hlt
keepkeepgoing2:
jmp progLoop2

deletefile:
cmp byte [delorview],1
je viewer
mov si,progFN
mov di,fat12fn
call makefnfat12
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov di,disk_buffer
mov si,fat12fn
mov bx,0
mov ax,0
rmrootdir:
mov cx,11
cld
repe cmpsb
je foundit
inc bx
add ax,32
mov si,fat12fn
mov di,disk_buffer
add di,ax
cmp bx,224
jle rmrootdir
cmp bx,224
jae fnnotfound
foundit:
cmp bx,0
je subtract
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
jmp finishdel
subtract:
mov di,disk_buffer
finishdel:
mov byte [di],229
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov ax, word [es:di+26]
mov word [tmp],ax
push ax
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,2
mov al,9
mov si,disk_buffer
mov bx,si
int 13h
pop ax
moreCluster:
mov bx,3
mul bx
mov bx,2
div bx
mov si,disk_buffer
add si,ax
mov ax, word [si]
test dx,dx
jz even
odd:
push ax
and ax,0x000F
mov word [si],ax
pop ax
shr ax,4
jmp calcclustcount
even:
push ax
and ax,0xF000
mov word [si],ax
pop ax
and ax,0x0fff
calcclustcount:
mov word [tmp],ax
cmp ax,0ff8h
jae donefat
jmp moreCluster
donefat:
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,3
mov al,9
mov si,disk_buffer
mov bx,si
int 13h
donedel:
jmp closedel

fnnotfound:
mov ax,0xc200
mov bh,0
int 15h
call paintbg2
mov ax,150
mov bx,200
mov cx,500
mov dx,250
call drawbutton
mov byte [buttonornot],1
mov ax,290
mov bx,227
mov cx,338
mov dx,241
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov word [X],200
mov word [Y],218
mov si,fnfspr
call dispsprites
mov word [X],306
mov word [Y],229
mov si,ok
call print_string
mov word [X],247
mov word [Y],215
mov si,errorfnf
call print_string
mov ah,00
int 16h
mov ax,0xc200
mov bh,1
int 15h
jmp closedel

makefnfat12:
call getStringLength
xor dh,dh
sub si,dx
call makeCaps
sub si,dx
mov cx,0
mov bx,di
copytonewstr:
lodsb
cmp al,'.'
je extfound
stosb
inc cx
jmp copytonewstr
extfound:
cmp cx,8
je addext
addspaces:
mov byte [di],' '
inc di
inc cx
cmp cx,8
jl addspaces
addext:
lodsb
stosb
lodsb
stosb
lodsb
stosb
mov al,0
stosb
ret

getStringLength:
mov dl,0
loopstrlength:
cmp byte [si],0
jne inccounter
cmp byte [si],0
je donestrlength
jmp loopstrlength
inccounter:
inc dl
inc si
jmp loopstrlength
donestrlength:
ret

makeCaps:
cmp byte [si],0
je doneCaps
cmp byte [si],61h
jl notatoz
cmp byte [si],7ah
jg notatoz
sub byte [si],20h
notatoz:
inc si
jmp makeCaps
doneCaps:
ret

delinput:
push ax
mov ax,word [X]
mov bx,word [Y]
mov cx,word [lineX]
mov dx,word [lineY]
mov word [X],cx
mov word [Y],dx
pop ax
cmp al,0dh
je deletefile
cmp al,08h
je backspace1
cmp word [counterdel],13
je continueonon2
add word [X],6
add word [lineX],6
mov byte [bslast],0
drawchar:
push dx
push di
mov di,progFN
continueinput:
add di,word [counterdel]
stosb
mov dh,0
mov dl,al
call getfont
inc word [counterdel]
pop di
pop dx
add cx,6
mov word [lineX],cx
mov word [X],ax
mov word [Y],bx
jmp continueonon2
backspace1:
cmp word [counterdel],0
je continueonon2
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
mov di,progFN
add di,word [counterdel]
mov byte [di],0
pop di
mov byte [Color],0
dec word [counterdel]
sub word [lineX],6
mov byte [bslast],1
jmp continueonon2

lbuttonclick2:
cmp word [xpos],619
jle l21
cmp word [xpos],636
jg l21
cmp word [ypos],1
jle l21
cmp word [ypos],13
jg l21
closedel:
mov word [lineX],175
mov word [counterdel],0
call paintbg2
call drawtitlebar
call drawfirstscreen
call getoldlocation
mov byte [keystep],0
mov byte [curStat],0
cmp byte [controlSet],0
je keyloop1
jmp draw
l21:
cmp byte [controlSet],0
je keyloop1
jmp draw2

;MAX PER SCREEN: 456
listsub:
call paintbg2
call drawtitlebar
call getoldlocation
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,disk_buffer
mov bx,si
int 13h
mov word [X],1
mov word [Y],20
mov byte [Color],0
mov cx,0
readroot:
lodsb
cmp al,229
je skipfn
cmp al,0fh
je skipfn
cmp cx,8
je adddot
cmp byte [yesorno],0
jne skipaheaddir
add si,10 ;KEEP THIS!!!
lodsb
cmp al,0fh
je skipsvi
cmp al,18h
je skipsvi
cmp al,16h
je skipsvi
sub si,0ch
lodsb
skipaheaddir:
cmp al,0
je exitdir
drawlist:
mov dl,al
xor dh,dh
call getfont
inc cx
cmp cx,11
je donereadfn
mov byte [yesorno],1
add word [X],6
jmp readroot
exitdir:
mov byte [keystep],1
cmp byte [controlSet],0
je keyloop1
sti
progLoop1:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick1
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
jmp progLoop1
jmp draw
skipspace:
inc cx
cmp cx,8
je adddot
jmp readroot
adddot:
mov dl,'.'
xor dh,dh
call getfont
add word [X],6
jmp drawlist
skipfn:
add si,31
jmp readroot
donereadfn:
add si,21
push ax
mov ax,0e20h
mov dl,' '
xor dh,dh
call getfont
add word [X],6
call getfont
add word [X],6
call getfont
pop ax
mov cx,0
mov byte [yesorno],0
inc byte [filelisted]
inc byte [totalfilelisted]
cmp byte [filelisted],7
je nextlistline
jmp readroot
skipsvi:
add si,14h
mov byte [yesorno],0
jmp readroot
nextlistline:
mov word [X],1
add word [Y],8
mov byte [filelisted],0
jmp readroot
filelisted db 0
totalfilelisted db 0

lbuttonclick1:
cmp word [xpos],619
jle l11
cmp word [xpos],636
jg l11
cmp word [ypos],1
jle l11
cmp word [ypos],13
jg l11
call paintbg2
call drawtitlebar
call drawfirstscreen
mov byte [filelisted],0
mov byte [keystep],0
mov byte [curStat],0
cmp byte [controlSet],0
je keyloop1
jmp draw
l11:
cmp byte [controlSet],0
je keyloop1
jmp draw1

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

