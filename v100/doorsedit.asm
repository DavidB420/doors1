;Doors text editor By David Badiei
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
jmp fileinput
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
lastbyte dw 0
curX dw 0
curY dw 0
curByte dw 0
X dw 0
Y dw 0
titleString db 'Doors Text editor',0
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
%include 'editsprites.inc'
fontlocation:
incbin 'fontdata.bin'

f1keyclick:
popa
jmp lbuttonclick

userenterkey:
popa
cmp byte [keystep],0
je fileinput
jmp continueon

doneenter:
call paintbg2
call drawtitlebar
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
mov ax,567
mov bx,2
mov cx,582
mov dx,11
mov byte [Color],02h
call drawbutton
mov word [X],570
mov word [Y],3
mov si,savespr
call dispsprites
mov byte [buttonornot],0
mov si,progFN
call makeCaps
mov word [X],115
mov word [Y],3
mov dh,0
mov dl,'-'
mov byte [Color],0fh
call getfont
add word [X],14
mov si,progFN
call print_string
call loadfile
mov bx,word [fileSize]
add bx,4000h
cmp bx,4000h
je notempty
push es
push ds
mov ax,3000h
mov ds,ax
mov es,ax
mov byte [bx],10
pop ds
pop es
inc bx
inc word [fileSize]
notempty:
mov word [lastbyte],bx
jmp editor
jmp draw

disablecursor:
call printoldlocation
jmp starteditor

editor:
call redrawtext
cmp byte [controlSet],0
je disablecursor
starteditor:
sti
progLoop1:
mov cx,word [xpos]
mov dx,word [ypos]
cmp byte [curStat],09h
je lbuttonclick2
draw1:
mov byte [cursorColor],0
call drawcursor
;Wait for keyboard input
keepgoing1:
mov al,1
test al,al
mov ah,1
int 16h
jz continueonon1
mov ah,00
int 16h
jmp editinput
continueonon1:
hlt
keepkeepgoing1:
jmp progLoop1
jmp draw

editinput:
cmp ah,4bh
je left
cmp ah,4dh
je right
cmp ah,50h
je down
cmp ah,48h
je up
cmp ax,3b00h
je doneprog
cmp ax,3c00h
je savefile
push ax
jmp keypress

savefile:
call deletefile
call writefile
jmp continueonon1

writefile:
pusha
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,fat
mov bx,si
int 13h
call createfile
popa
mov word [location],bx
mov di,freeclusts
mov cx,128
cleanroutine:
mov word [di],0
add di,2
loop cleanroutine
getclustamount:
mov word cx,[fileSize]
mov ax,cx
mov dx,0
mov bx,512
div bx
cmp dx,0
jg addaclust
jmp createentry
addaclust:
inc ax
createentry:
mov word [clustersneeded],ax
mov word bx,[fileSize]
cmp bx,0
je finishwrite
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,2
mov al,9
mov si,fat
mov bx,si
int 13h
mov si,fat+3
mov word cx,[clustersneeded]
mov bx,2
mov dx,0
findcluster:
lodsw
and ax,0fffh
jz foundeven
moreodd:
inc bx
dec si
lodsw
shr ax,4
or ax,ax
jz foundodd
moreeven:
inc bx
jmp findcluster
foundeven:
push si
mov si,freeclusts
add si,dx
mov word [si],bx
pop si
dec cx
cmp cx,0
je donefind
inc dx
inc dx
jmp moreodd
foundodd:
push si
mov si,freeclusts
add si,dx
mov word [si],bx
pop si
dec cx
cmp cx,0
je donefind
inc dx
inc dx
jmp moreeven
donefind:
mov cx,0
mov word [count],1
chainloop:
mov word ax,[count]
cmp word ax,[clustersneeded]
je lastcluster
mov di,freeclusts
add di,cx
mov word bx,[di]
mov ax,bx
mov dx,0
mov bx,3
mul bx
mov bx,2
div bx
mov si,fat
add si,ax
mov ax,word [ds:si]
or dx,dx
jz even3
odd3:
and ax,000fh
mov di,freeclusts
add di,cx
mov word bx,[di+2]
shl bx,4
add ax,bx
mov word [ds:si],ax
inc word [count]
add cx,2
jmp chainloop
even3:
and ax,0f000h
mov di,freeclusts
add di,cx
mov word bx,[di+2]
add ax,bx
mov word [ds:si],ax
inc word [count]
add cx,2
jmp chainloop
lastcluster:
mov di,freeclusts
add di,cx
mov word bx,[di]
mov ax,bx
mov dx,0
mov bx,3
mul bx
mov bx,2
div bx
mov si,fat
add si,ax
mov ax, word [ds:si]
or dx,dx
jz evenlast
oddlast:
and ax,000fh
add ax,0ff80h
jmp writefat
evenlast:
and ax,0f000h
add ax,0ff8h
writefat:
mov word [ds:si],ax
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,3
mov al,9
mov si,fat
mov bx,si
int 13h
mov word [location],4000h
mov cx,0
saveloop:
mov di,freeclusts
add di,cx
mov word ax,[di]
cmp ax,0
je writerootentry
pusha
call twelvehts
push es
mov ax,3000h
mov es,ax
mov word bx,[location]
mov ah,3
mov al,1
mov dl,byte [bootdev]
int 13h
pop es
popa
add word [location],512
inc cx
inc cx
jmp saveloop
writerootentry:
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,fat
mov bx,si
int 13h
mov di,fat
mov si,fat12fn
mov bx,0
mov ax,0
findfn4:
mov cx,11
cld
repe cmpsb
je foundfn4
inc bx
add ax,32
mov si,fat12fn
mov di,fat
add di,ax
cmp bx,224
jle findfn4
foundfn4:
mov ax,32
mul bx
mov di,fat
add di,ax
mov word ax,[freeclusts]
mov word [di+26],ax
mov word cx,[fileSize]
mov word [di+28],cx
mov byte [di+30],0
mov byte [di+31],0
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,fat
mov bx,si
int 13h
finishwrite:
ret
clustersneeded dw 0
freeclusts times 128 dw 0
count dw 0
location dw 0

createfile:
mov di,fat
mov cx,224
findemptyrootentry:
mov byte al,[di]
cmp al,0
je foundempty
cmp al,0e5h
je foundempty
add di,32
loop findemptyrootentry
foundempty:
mov si,fat12fn
mov cx,11
rep movsb
sub di,11
mov byte [di+11],0
mov byte [di+12],0
mov byte [di+13],0
mov byte [di+14],0c6h
mov byte [di+15],07eh
mov byte [di+16],0
mov byte [di+17],0
mov byte [di+18],0
mov byte [di+19],0
mov byte [di+20],0
mov byte [di+21],0
mov byte [di+22],0c6h
mov byte [di+23],07eh
mov byte [di+24],0
mov byte [di+25],0
mov byte [di+26],0
mov byte [di+27],0
mov byte [di+28],0
mov byte [di+29],0
mov byte [di+30],0
mov byte [di+31],0
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,fat
mov bx,si
int 13h
ret
savefile1:
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,2
mov al,14
mov si,fat
mov bx,si
int 13h
mov di,fat
mov si,fat12fn
mov bx,0
mov ax,0
findfn6:
mov cx,11
cld
repe cmpsb
je foundfn6
inc bx
add ax,32
mov si,fat12fn
mov di,fat
add di,ax
cmp bx,224
jle findfn6
cmp bx,224
je continuesave
foundfn6:
mov ax,32
mul bx
mov di,fat
add di,ax
mov byte [di],229
mov ch,0
mov cl,2
mov dh,1
mov dl,byte [bootdev]
mov ah,3
mov al,14
mov si,fat
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
mov si,fat
mov bx,si
int 13h
pop ax
moreCluster1:
mov bx,3
mul bx
mov bx,2
div bx
mov si,fat
add si,ax
mov ax, word [si]
test dx,dx
jz even2
odd2:
push ax
and ax,0x000F
mov word [si],ax
pop ax
shr ax,4
jmp calcclustcount1
even2:
push ax
and ax,0xF000
mov word [si],ax
pop ax
and ax,0x0fff
calcclustcount1:
mov word [tmp],ax
cmp ax,0ff8h
jae donefat1
jmp moreCluster1
donefat1:
mov ch,0
mov cl,2
mov dh,0
mov dl,byte [bootdev]
mov ah,3
mov al,9
mov si,fat
mov bx,si
int 13h
continuesave:
mov ax,fat12fn
mov word cx,[fileSize]
push bx
mov bx,4000h
call writefile
pop bx
mov word bx,[skiplines]
jmp redrawtext

deletefile:
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
ret

keypress:
cmp al,8
je skipahead2
cmp ah,53h
je skipahead2
cmp al,0dh
je skipahead2
cmp word [curX],105
je continueonon1
skipahead2:
mov word cx,[skiplines]
mov byte [Color],0fh
call rendertext
call drawcaret
pop ax
cmp al,8
je backspace2
cmp ah,53h
je deletekey
cmp al,0dh
je enterkey
call charforward
mov cx,word [curByte]
mov si,file
add si,cx
push es
push ds
mov bx,3000h
mov es,bx
mov ds,bx
mov byte [si],al
pop ds
pop es
inc word [curByte]
inc word [curX]
mov word cx,[skiplines]
mov byte [Color],0h
call rendertext
call drawcaret
jmp continueonon1
backspace2:
cmp word [curByte],0
je skipahead3
cmp word [curX],0
je skipahead3
dec word [curX]
dec word [curByte]
mov si,file
add si,word [curByte]
cmp si,word [lastbyte]
je skipahead3
cmp byte [si],0ah
je atnewline
call charbackward
jmp skipahead3
atnewline:
call charbackward
call charbackward
skipahead3:
mov word cx,[skiplines]
mov byte [Color],0h
call rendertext
call drawcaret
jmp continueonon1
deletekey:
mov si,4001h
add si,word [curByte]
cmp si,word [lastbyte]
je skipahead3
push es
push ds
mov bx,3000h
mov es,bx
mov ds,bx
mov al,byte [si]
pop ds
pop es
cmp al,0Ah
je atnewline1
call charbackward
jmp skipahead3
atnewline1:
call charbackward
call charbackward
jmp skipahead3
enterkey:
call charforward
mov word cx,[curByte]
mov di,file
add di,cx
push es
push ds
mov bx,3000h
mov es,bx
mov ds,bx
mov byte [di],0Ah
pop ds
pop es
mov word cx,[skiplines]
mov byte [Color],0h
call rendertext
call drawcaret
jmp down

charbackward:
pusha
mov si,file
add si,word [curByte]
loopbackward:
push es
push ds
mov bx,3000h
mov es,bx
mov ds,bx
mov byte al,[si+1]
mov byte [si],al
pop ds
pop es
inc si
cmp si,word [lastbyte]
jne loopbackward
dec word [fileSize]
dec word [lastbyte]
popa
ret


charforward:
pusha
mov si,file
add si,word [fileSize]
mov di,file
add di,word [curByte]
loopforward:
push es
push ds
mov bx,3000h
mov es,bx
mov ds,bx
mov byte al,[si]
mov byte [si+1],al
pop ds
pop es
dec si
cmp si,di
jl doneforward
jmp loopforward
doneforward:
inc word [fileSize]
inc word [lastbyte]
popa
ret

up:
pusha
mov byte [curStat],0
mov word cx,[curByte]
mov si,file
add si,cx
cmp si,file
je startoffile
push ds
push es
mov ax,3000h
mov ds,ax
mov es,ax
mov al,byte [si]
pop es
pop ds
cmp al,0Ah
je startonnewline
jmp goback2
startonnewline:
cmp si,4001h
je startoffile
push ds
push es
mov ax,3000h
mov ds,ax
mov es,ax
mov al,byte [si-1]
pop es
pop ds
cmp al,0Ah
je anothernewlinebefore
dec si
dec cx
jmp goback2
anothernewlinebefore:
push ds
push es
mov ax,3000h
mov ds,ax
mov es,ax
mov al,byte [si-2]
pop es
pop ds
cmp al,0Ah
je gotostartline
dec word [curByte]
jmp displaymove
gotostartline:
dec si
dec cx
cmp si,file
je startoffile
dec si
dec cx
cmp si,file
je startoffile
jmp loop2
goback2:
cmp si,file
je startoffile
push ds
push es
mov ax,3000h
mov ds,ax
mov es,ax
mov byte al,[si]
pop es
pop ds
cmp al,0Ah
je foundnewline
dec cx
dec si
jmp goback2
foundnewline:
dec si
dec cx
loop2:
cmp si,file
je startoffile
push ds
push es
mov ax,3000h
mov ds,ax
mov es,ax
mov byte al,[si]
pop es
pop ds
cmp al,0Ah
je founddone
dec cx
dec si
jmp loop2
founddone:
inc cx
mov word [curByte],cx
jmp displaymove
startoffile:
mov word [curByte],0
mov word [curX],0
displaymove:
popa
cmp word [curY],0
je scrollfileup
mov byte [Color],0fh
call drawcaret
dec word [curY]
mov word [curX],0
mov byte [Color],0
call drawcaret
jmp continueonon1
scrollfileup:
cmp word [skiplines],0
jle continueonon1
mov word cx,[skiplines]
mov byte [Color],0fh
call rendertext
dec word [skiplines]
mov word cx,[skiplines]
mov byte [Color],0
call rendertext
jmp continueonon1

down:
pusha
mov byte [curStat],0
mov word cx,[curByte]
mov si,file
add si,cx
downloop:
inc si
cmp word si,[lastbyte]
je donothingdown
dec si
push ds
mov ax,3000h
mov ds,ax
lodsb
pop ds
inc cx
cmp al,0ah
jne downloop
mov word [curByte],cx
nowheretogo:
popa
cmp word [curY],57
je scrollfiledown
mov byte [Color],0fh
call drawcaret
inc word [curY]
mov word [curX],0
mov byte [Color],0
call drawcaret
jmp continueonon1
scrollfiledown:
mov word cx,[skiplines]
mov byte [Color],0fh
call rendertext
call drawcaret
inc word [skiplines]
mov word cx,[skiplines]
mov byte [Color],0
call rendertext
mov word [curX],0
call drawcaret
jmp continueonon1
donothingdown:
popa
jmp continueonon1

left:
cmp word [curX],0
je nothingtodo1
mov byte [Color],0fh
call drawcaret
dec word [curX]
dec word [curByte]
mov byte [Color],0
call drawcaret
nothingtodo1:
jmp continueonon1

right:
pusha
cmp word [curX],105
je nothingtodo
mov word bx,[curByte]
mov si,file
add si,bx
inc si
cmp word si,[lastbyte]
je nothingtodo
dec si
push ds
push es
mov ax,3000h
mov ds,ax
mov es,ax
mov al,byte [si]
cmp byte [si],0Ah
je nothingtodo2
pop es
pop ds
inc word [curByte]
mov byte [Color],0fh
call drawcaret
inc word [curX]
popa
mov byte [Color],0
call drawcaret
jmp continueonon1

nothingtodo:
popa
jmp continueonon1

nothingtodo2:
pop es
pop ds
popa
jmp continueonon1

redrawtext:
mov byte [Color],0fh
call rendertext
call drawcaret
mov byte [Color],0
call rendertext
call drawcaret
ret

drawcaret:
mov ax,word [curX]
mov dx,6
mul dx
mov word [X],ax
mov ax,word [curY]
mov dx,8
mul dx
add ax,15
mov word [Y],ax
mov cx,7
caretLoop:
call displayblackpixel
inc word [Y]
loop caretLoop
ret


rendertext:
mov word [X],1
mov word [Y],15
mov ax,0xc200
mov bh,0
int 15h
mov si,file
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
mov word [X],1
add word [Y],8
jmp redraw
donestr1:
mov ax,0xc200
mov bh,1
int 15h
ret
cutline:
mov byte [cutter],1
jmp continueprint1
skiplines dw 0
cutter db 0

fileinput:
push ax
mov ax,word [X]
mov bx,word [Y]
mov cx,word [lineX]
mov dx,word [lineY]
mov word [X],cx
mov word [Y],dx
pop ax
cmp al,0dh
je doneenter
cmp al,08h
je backspace1
cmp word [counterdel],13
je continueonon
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
jmp continueonon
backspace1:
cmp word [counterdel],0
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
mov di,progFN
add di,word [counterdel]
mov byte [di],0
pop di
mov byte [Color],0
dec word [counterdel]
sub word [lineX],6
mov byte [bslast],1
jmp continueonon

drawfirstscreen:
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
mov si,enterPrompt
call print_string
ret

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
jmp draw

lbuttonclick2:
cmp word [xpos],619
jle l21
cmp word [xpos],636
jg l21
cmp word [ypos],1
jle l21
cmp word [ypos],13
jg l21
;call mouse_disable
jmp doneprog
l21:
cmp word [xpos],584
jle l22
cmp word [xpos],600
jg l22
cmp word [ypos],1
jle l22
cmp word [ypos],13
jg l22
jmp up
l22:
cmp word [xpos],602
jle l23
cmp word [xpos],618
jg l23
cmp word [ypos],1
jle l23
cmp word [ypos],13
jg l23
jmp down
l23:
cmp word [xpos],566
jle l24
cmp word [xpos],582
jg l24
cmp word [ypos],1
jle l24
cmp word [ypos],13
jg l24
jmp savefile
l24:
jmp draw


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
jae newfile
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

newfile:
mov di,file
xor al,al
push es
mov bx,3000h
mov es,bx
mov cx,0xffff
rep stosb
pop es
mov word [fileSize],1
mov bx,file
push es
push ds
mov ax,3000h
mov es,ax
mov ds,ax
mov byte [bx],0ah
pop ds
pop es
inc bx
mov word [lastbyte],bx
mov cx,0
mov word [skiplines],0
mov word [curX],0
mov word [curY],0
mov word [curByte],0
mov ax,fat12fn
mov word cx,[fileSize]
mov bx,file
call writefile
mov word [lastbyte],1
ret

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
mov word [lineX],175
mov word [counterdel],0
call paintbg2
call drawtitlebar
call drawfirstscreen
call getoldlocation
jmp draw

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

