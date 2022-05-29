
.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

INCLUDE    \masm32\INCLUDE\gdi32.inc
INCLUDELIB \masm32\LIB\gdi32.lib


; Определение дочерних контролов из RC
; ------------------------------------
IDE_TXT   EQU 201
IDB_B64   EQU 202
IDB_ASCII EQU 203
IDB_EXIT  EQU 204

DlgProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD
.data
;include data.inc



.DATA


tit db "Animation value: "

buffer1   db 120 dup (?)


hInst dd ?

hWin dd ?
.CODE
include an.inc

start:
     invoke GetModuleHandle,0
     mov hInst,eax
     
     invoke DialogBoxParam,eax,134,0,OFFSET DlgProc,0
     invoke ExitProcess,0

DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
     mov eax,uMsg
     .IF eax == WM_COMMAND
         mov eax,wParam
         cmp ax,IDB_EXIT
         je @exit
         
         cmp ax,1
         je @exit
         
         .IF ax == IDB_ASCII

          
             

         .ELSEIF ax == IDB_B64

            

         .ENDIF
     
     .elseif eax==WM_INITDIALOG
     
    
       
         
        push hWnd 
        call AnimOpen 
        

     push offset buffer1
     mov eax,anim
     push eax
     call dword2hexstr
     
     invoke SetWindowText,hWnd,addr tit;buffer1
     
     
     .ELSEIF eax == WM_CLOSE
@exit:   
push hWnd
call AnimClose

invoke EndDialog,hWnd,0
     .ENDIF
@R:  xor eax,eax
     ret
DlgProc ENDP




dword2hexstr proc lHex:dword,lpString:dword

	push	ebx

	xor	ecx,ecx
	mov	eax,lHex
	mov	ebx,lpString
	mov	edx,ecx

_next_byte:
	rol	eax,4
	mov	dl,al
	and	dl,0Fh
	mov	dl,byte ptr[edx+offset HexTab]
	mov	byte ptr[ebx],dl
	inc	cl
	inc	ebx
	cmp	cl,8
	jnz	_next_byte

	mov	byte ptr[ebx],0

	pop	ebx
	ret

HexTab  db '0123456789ABCDEF'

dword2hexstr endp








END start