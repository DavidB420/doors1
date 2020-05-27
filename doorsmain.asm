;Main Doors program By David Badiei
org 4000h

;Get drive number from DOS
mov byte [bootdev],dl

;Ask user for key or mouse
mov si,keyormouse
call print_string_char
mov ah,00
int 16h
cmp al,'1'
je keyboardSet
cmp al,1bh
je doneprog
jmp mouseSet

continuetocontrol:
;Change to mode 12
mov byte [controlSet],cl
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
sti
progLoop:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick
draw:
mov byte [loadcomp],1
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing:
mov ah,1
int 16h
jnz doneprog
hlt
keepkeepgoing:
jmp progLoop

keyboardControl:
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
ret

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
keyormouse db 'Press 1 for keyboard or any other key for mouse', 0
selectStr db 'Please choose an option below: ',0
titleString db 'Doors 1.0 Copyright (C) 2020 David Badiei',0
calcFN db 'DRCALC  COM',0
fileFN db 'DRFILE  COM',0
editFN db 'DREDIT  COM',0
biosColor db 0
controlSet db 0
cursorColor db 0
mousepropexists db 0
mouseupdated db 0
prevColor db 0
msoldloc times 8 db 0
bootdev db 0
loadcomp db 0
%include 'sprites.inc'

fontlocation:
incbin 'fontdata.bin'

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

f1keyclick:
popa
jmp lbuttonclick

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
mov cl,1
jmp continuetocontrol

keyboardSet:
mov cl,0
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
mov byte [msoldloc],al
inc word [X]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+1],al
inc word [X]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+2],al
sub word [X],2
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+3],al
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+4],al
sub word [Y],2
inc word [X]
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+5],al
inc word [X]
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+6],al
inc word [X]
inc word [Y]
call getpixel
mov al,byte [prevColor]
mov byte [msoldloc+7],al
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
call mouse_disable
jmp doneprog
l1:
cmp word [xpos],99
jle l2
cmp word [xpos],150
jg l2
cmp word [ypos],99
jle l2
cmp word [ypos],150
jg l2
jmp 0xffff:0000h
l2:
cmp word [xpos],279
jle l3
cmp word [xpos],330
jg l3
cmp word [ypos],99
jle l3
cmp word [ypos],150
jg l3
mov ax,5300h
mov bx,0
int 15h
mov ax,5301h
mov bx,0
int 15h
mov ax,530eh
mov bx,0
mov cx,0102h
int 15h
mov ax,5307h
mov cx,0003h
mov bx,0001h
int 15h
mov ax,0003h
int 10h
hlt
jmp $
l3:
cmp word [xpos],459
jle l4
cmp word [xpos],510
jg l4
cmp word [ypos],99
jle l4
cmp word [ypos],150
jg l4
jmp distime
l4:
cmp word [xpos],459
jle l5
cmp word [xpos],510
jg l5
cmp word [ypos],199
jle l5
cmp word [ypos],250
jg l5
jmp loadprogramsub
l5:
cmp word [xpos],279
jle l6
cmp word [xpos],330
jg l6
cmp word [ypos],299
jle l6
cmp word [ypos],350
jg l6
mov si,calcFN
mov di,fat12fn
mov cx,12
repe movsb
mov byte [loadcomp],1
jmp skipmakefat12
l6:
cmp word [xpos],99
jle l7
cmp word [xpos],150
jg l7
cmp word [ypos],199
jle l7
cmp word [ypos],250
jg l7
mov si,fileFN
mov di,fat12fn
mov cx,12
repe movsb
mov byte [loadcomp],1
jmp skipmakefat12
l7:
cmp word [xpos],279
jle l8
cmp word [xpos],330
jg l8
cmp word [ypos],200
jle l8
cmp word [ypos],250
jg l8
mov si,editFN
mov di,fat12fn
mov cx,12
repe movsb
mov byte [loadcomp],1
jmp skipmakefat12
l8:
jmp draw

loadprogramsub:
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
mov si,loadstr
call print_string
mov di,progFN
call getuserlineinput
jmp loadprog
doneloadprog:
call paintbg2
mov word [xpos],0
mov word [ypos],0
mov byte [curStat],0
call drawtitlebar
call drawwidgets
mov ax,0xc200
mov bh,1
int 15h
cmp byte [controlSet],0
je keyloop1
jmp draw
loadstr db 'Enter file name:',0
counter db 0

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

distime:
mov byte [buttonornot],1
mov ax,0
mov bx,0
mov cx,640
mov dx,480
mov byte [Color],0fh
call drawbutton
mov word [xpos],0
mov word [ypos],0
mov word [cursorColor],0fh
call drawcursor
mov byte [buttonornot],0
mov word [X],265
mov word [Y],200
mov byte [Color],00h
mov si,timeprogStr
call print_string
mov word [X],265
mov word [Y],210
mov si,dateprogStr
call print_string
;Display time
restarttimeddraw:
mov word [X],290
mov word [Y],200
mov ah,02h
int 1ah
mov al,ch
call bcdtoint
mov ch,al
mov al,cl
call bcdtoint
mov cl,al
mov al,dh
call bcdtoint
mov dh,al
xor ax,ax
mov al,ch
call outputnum
add word [X],7
push dx
xor dh,dh
mov dl,':'
mov byte [Color],0
call getfont
pop dx
xor ax,ax
mov al,cl
call outputnum
add word [X],7
push dx
xor dh,dh
mov dl,':'
mov byte [Color],0
call getfont
pop dx
xor ax,ax
mov al,dh
call outputnum
;Display date
mov word [X],290
mov word [Y],210
mov ah,04
int 1ah
mov al,dl
call bcdtoint
mov dl,al
mov al,dh
call bcdtoint
mov dh,al
mov al,ch
call bcdtoint
mov ch,al
mov al,cl
call bcdtoint
mov cl,al
mov al,dl
call outputnum
add word [X],7
push dx
xor dh,dh
mov dl,'/'
mov byte [Color],0
call getfont
pop dx
mov al,dh
call outputnum
add word [X],7
push dx
xor dh,dh
mov dl,'/'
mov byte [Color],0
call getfont
pop dx
mov al,ch
call outputnum
mov al,cl
call outputnum
;Draw white box
mov cx,1
mov dx,86A0h
mov ah,86h
int 15h
mov byte [buttonornot],1
mov ax,295
mov bx,200
mov cx,365
mov dx,217
mov byte [Color],0fh
call drawbutton
mov byte [buttonornot],0
mov ah,1
int 16h
jz restarttimeddraw
mov ah,0
int 16h
call paintbg2
mov word [xpos],0
mov word [ypos],0
mov byte [curStat],0
call drawtitlebar
call drawwidgets
cmp byte [controlSet],0
je keyloop1
jmp draw
timeprogStr db 'Time:',0
dateprogStr db 'Date:',0

bcdtoint:
push cx
push ax
and al,11110000b
shr al,4
mov cl,10
mul cl
pop cx
and cl,00001111b
add al,cl
pop cx
ret

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
mov word [X],230
mov word [Y],50
mov byte [Color],0
mov si,selectStr
call print_string
mov ax,100
mov bx,100
mov cx,150
mov dx,150
call drawbutton
mov byte [Color],0fh
call discharpix
mov word [X],120
mov word [Y],120
mov si,restartspr
call dispsprites
mov word [X],105
mov word [Y],160
mov byte [Color],0
mov si,restartStr
call print_string
mov ax,280
mov bx,100
mov cx,330
mov dx,150
call drawbutton
mov word [X],300
mov word [Y],120
mov si,sdspr
call dispsprites
mov word [X],278
mov word [Y],160
mov byte [Color],0
mov si,sdStr
call print_string
mov ax,460
mov bx,100
mov cx,510
mov dx,150
call drawbutton
mov word [X],480
mov word [Y],120
mov si,tispr
call dispsprites
mov word [X],454
mov word [Y],160
mov byte [Color],0
mov si,timeStr
call print_string
mov ax,100
mov bx,200
mov cx,150
mov dx,250
call drawbutton
mov word [X],120
mov word [Y],220
mov si,fmspr
call dispsprites
mov word [X],91
mov word [Y],260
mov byte [Color],0
mov si,fmStr
call print_string
mov ax,280
mov bx,200
mov cx,330
mov dx,250
call drawbutton
mov word [X],300
mov word [Y],220
mov si,tespr
call dispsprites
mov word [X],273
mov word [Y],260
mov byte [Color],0
mov si,teStr
call print_string
mov ax,460
mov bx,200
mov cx,510
mov dx,250
call drawbutton
mov word [X],480
mov word [Y],220
mov si,progspr
call dispsprites
mov word [X],451
mov word [Y],260
mov byte [Color],0
mov si,progStr
call print_string
mov ax,280
mov bx,300
mov cx,330
mov dx,350
call drawbutton
mov word [X],300
mov word [Y],320
mov si,calcspr
call dispsprites
mov word [X],277
mov word [Y],360
mov byte [Color],0
mov si,calcStr
call print_string
ret
restartStr db 'Restart',0
sdStr db 'Shut down',0
timeStr db 'Time & date',0
fmStr db 'File manager',0
teStr db 'Text editor',0
progStr db 'Load program',0
calcStr db 'Calculator',0

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

loadprog:
mov si,progFN
mov di,fat12fn
call makefnfat12
skipmakefat12:
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
cmp bx,224
jae filenotfound
foundfn:
mov ax,32
mul bx
mov di,disk_buffer
add di,ax
push ax
mov ax,word [di+1ch]
mov word[fileSize],ax
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
mov ax,1000h
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
jnz odd
even:
and dx,0fffh
jmp end
odd:
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
mov ax,1000h
mov es,ax
mov ax,0201h
int 13h
pop es
mov dx,word [cluster]
mov ax,dx
cmp dx,0ff0h
jb loadnextclust
mov dl,byte [bootdev]
mov ax,0003h
int 10h
push ds
push es
mov cl,byte [controlSet]
mov ax,1000h
mov ds,ax
mov es,ax
call 1000h:4000h
pop es
pop ds
mov ax,0012h
int 10h
cmp byte [loadcomp],1
je endcomp
jmp doneloadprog
endcomp:
call mousedrvsetup
call mouse_enable
jmp doneloadprog
filenotfound:
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
jmp doneloadprog
errorfnf db 'Error: File not found!',0
ok db 'OK',0

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

SectorsPerTrack dw 18
Sides dw 2
fileSize dw 0
cluster dw 0
fat12fn times 13 db 0
progFN times 13 db 0
disk_buffer equ 2000h
fat equ 0ac00h
file equ 4000h

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