
.686
.mmx
.model flat, stdcall
option casemap:none



include Library.inc
include about.asm
;include WaterEffect.asm

DialogProc 		proto 		:DWORD,:DWORD,:DWORD,:DWORD
WindowHandle 	proto 		:DWORD
Serial_Edit 		PROTO		:DWORD,:DWORD,:DWORD,:DWORD
DialogBoxTransparente			PROTO :DWORD,:DWORD


.data								
namebuffer	dd 32 dup (00)
playflag		dd 4 dup(00)
Font			dd 4 dup(00)
Transparency			dd 0
TransColor				COLORREF	00000FFh


.data?
	
	hInstance					HINSTANCE	?  
	MoveDlg					BOOL		?
	OldPos					POINT		<>
	NewPos					POINT		<>
	Rect						RECT		<>
	LGFont					LOGFONT	<>
	hSerial					dd			?
	MainProc					dd			?
	hFont				   DD ?
; Music
	nMusicSize				DWORD		?
	pMusic					LPVOID		?

.const
	DIALOG_1		equ   1
	ID_ICON			equ	 2
	IDC_APPNAME	equ   1001
	IDC_NAME		equ   1002
	IDC_SERIAL		equ   1003
	IDC_SERIAL2	         equ   1014
	BTN_EXIT  		equ   1004
	BTN_GENERATE	equ   1005
	BTN_PATCH	         equ   300h
	IDC_HEX			equ   1006
	ID_XM			equ	 2007


include DoKey.asm
include scroller.asm
include Bmp_Button_Class.asm

.code
include  an.inc

start:
	fn GetModuleHandle,NULL
	mov hInstance ,eax
	fn InitCommonControls        
	fn DialogBoxParam,hInstance,DIALOG_1,NULL,ADDR DialogProc,NULL
	
	fn ExitProcess,NULL
DialogProc Proc   hWnd:dword,uMsg:dword,wParam:dword,lParam:dword
	push hWnd
	pop handle
	mov eax,hWnd
	.if uMsg==WM_INITDIALOG
;fn CreateStorm, ADDR WTileStruct, STORMLENGTH, MAX_DROPS_AT_ONCE	
; fn AnimateWindow, hWnd, 1000, AW_ACTIVATE or AW_CENTER 

	fn LoadIcon, hInstance, 2
	fn SendMessage,hWnd,WM_SETICON,0,eax
	fn SetWindowText, hWnd, addr appname
	fn DialogBoxTransparente, hWnd, 200	;===========================>transparence
	fn BmpButton_, hWnd, 165,293,203,204,205,3EEh;generate
	fn BmpButton_, hWnd, 370,293,206,207,208,3EFh;exit
	fn BmpButton_, hWnd, 267,293,209,210,211,300h ; patch
	fn BmpButton_, hWnd, 4,187,212,213,214,400h

; Initialize MFMPLAYER:
	fn GetDlgItem,hWnd,1
	fn SetFocus,eax
;	fn SetDlgItemText,hWnd,IDC_APPNAME,addr appname
	push esi
	fn FindResource, hInstance, ID_XM, RT_RCDATA
	push eax
	fn SizeofResource, hInstance, eax
	mov nMusicSize, eax
	pop eax
	fn LoadResource, hInstance, eax
	fn LockResource, eax
	mov esi, eax
	mov eax, nMusicSize
	add eax, SIZEOF nMusicSize
	fn GlobalAlloc, GPTR, eax
	mov pMusic, eax
	mov ecx, nMusicSize
	mov dword ptr [eax], ecx
	add eax, SIZEOF nMusicSize
	mov edi, eax
	rep movsb
	pop esi
	fn mfmPlay, pMusic
	mov playflag,1
;scroller
	xor	eax,eax
	push	0
	push	esp
	push	eax
	push	hWnd
	push	offset thProc
	push	eax
	push	eax
	call	CreateThread
	pop	eax
	
       fn keygen_routine,hWnd
       
       		fn GetDlgItem,hWnd,IDC_SERIAL
       		fn SendMessage, eax, WM_SETFONT,hFont,1
       		
        		fn GetDlgItem,hWnd,IDC_SERIAL2
       		fn SendMessage, eax, WM_SETFONT,hFont,1      		
       		
       		fn GetDlgItem,hWnd,IDC_NAME
       		fn SendMessage, eax, WM_SETFONT,hFont,1
		mov hSerial, eax
		fn SetWindowLong,eax,GWL_WNDPROC,ADDR Serial_Edit
		mov MainProc, eax
		
	
	.elseif uMsg==WM_CTLCOLOREDIT
		fn GetDlgCtrlID,lParam
		.if ax==IDC_NAME

			fn SetBkMode,wParam, TRANSPARENT
			fn SetBkColor,wParam,00FFffffh
			fn SetTextColor,wParam,0004F2FFh
			fn GetStockObject,NULL_BRUSH
			ret
		.elseif ax==IDC_SERIAL
			fn SetBkMode,wParam, TRANSPARENT
			fn SetBkColor,wParam,00Ffffffh
			fn SetTextColor,wParam,00A9DA29h
			fn GetStockObject,NULL_BRUSH
			ret
		.elseif ax==IDC_SERIAL2
			fn SetBkMode,wParam, TRANSPARENT
			fn SetBkColor,wParam,00Ffffffh
			fn SetTextColor,wParam,0030FF04h
			fn GetStockObject,NULL_BRUSH
			ret			
		.endif
	.elseif uMsg==WM_LBUTTONDOWN
		mov MoveDlg,TRUE
		fn SetCapture,hWnd
		fn GetCursorPos,addr OldPos
		
	.elseif uMsg==WM_MOUSEMOVE		
		
		.if MoveDlg==TRUE
			fn GetWindowRect,hWnd,addr Rect
			fn GetCursorPos,addr NewPos
			mov eax,NewPos.x
			mov ecx,eax
			sub eax,OldPos.x
			mov OldPos.x,ecx
			add eax,Rect.left
			mov ebx,NewPos.y
			mov ecx,ebx
			sub ebx,OldPos.y
			mov OldPos.y,ecx
			add ebx,Rect.top
			mov ecx,Rect.right
			sub ecx,Rect.left
			mov edx,Rect.bottom
			sub edx,Rect.top
			fn MoveWindow,hWnd,eax,ebx,ecx,edx,TRUE
			
		.endif
		
	.elseif uMsg==WM_LBUTTONUP
			mov MoveDlg,FALSE
			fn ReleaseCapture  ;================> rappel les fonctions capture
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		.if ax==3EEh
;fn GetDlgItemText, hWnd, IDC_NAME,ADDR PublicKey, sizeof  PublicKey		
		
			fn keygen_routine,hWnd
	
	fn SetDlgItemText,hWnd,IDC_SERIAL,addr UserKey2	
    fn exist, "ASTRALKEY"
    fn DeleteFile,	addr KeyfileName
 ;================ partie keyfile ========================================
fn CreateFile, ADDR KeyfileName, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, CREATE_NEW, FILE_ATTRIBUTE_ARCHIVE, NULL
mov hFile, EAX ;On récupère le handle du fichier
fn WriteFile, hFile, ADDR UserKey2, 32, ADDR Nbr_Octet_Ecrit, 0
fn CloseHandle, hFile
;fn MessageBox, NULL, addr MsgBoxTextOk, addr MsgBoxCaptionOk, MB_OK
                                                            
;================================================================================================================  	
	fn SetDlgItemText,hWnd,IDC_SERIAL2,chr$("Keyfile 'ASTRALKEY' créé avec succès!")

;			jmp @close
   		.elseif eax==BTN_EXIT
	jmp @close
;			fn keygen_routine,hWnd
		.elseif eax==3EFh
			cmp playflag, 0
			je @f
			fn mfmPlay, 0
			@@:
			jmp @close
		.elseif eax==300h
;			cmp playflag, 0
;			je @f
		fn DialogBoxParam,hInstance,2,hWnd,ADDR AboutProc,NULL	
;			mov playflag,0
			@@:
		.elseif eax==400h
			cmp playflag, 1
			je @f
			fn mfmPlay, pMusic
			mov playflag,1
			@@:
		.elseif ax==IDC_NAME
		push eax
			fn InvalidateRect,hWnd,0,0
		pop eax
;			shr eax,16
;			.if ax==EN_CHANGE
;					fn keygen_routine,hWnd
;			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		@close:
		
 fn AnimateWindow, hWnd, 1000,   AW_HIDE     or AW_CENTER		
;fn AnimClose,hWnd
;push hWnd
		fn EndDialog,hWnd,NULL
		push	offset scrAbout
		call	scrollDestroy
;		popad
		xor eax,eax
		ret
	.else
;		popad
		mov eax,FALSE
		ret	
	.endif
;            	popad
            	xor eax,eax
            	ret                           
DialogProc endp

WindowHandle proc Handles:DWORD
	fn GetWindowText, Handles, addr HandleString, 200
	fn lstrcmp, addr HandleString, addr ParentWindow
	je @f
	mov eax,1
	jmp wdEnd
	@@:
	mov eax,Handles
	mov dword ptr [whandle],eax
	xor eax,eax
	wdEnd:
	ret
WindowHandle EndP

Serial_Edit proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
	
	.if uMsg==WM_CHAR
		fn GetParent,hWnd
		fn InvalidateRect,eax,0,0
		ret
	.endif
	fn CallWindowProc,MainProc,hWnd,uMsg,wParam,lParam
	ret
Serial_Edit endp
max_ConvertBytesToAscii proc uses ebx esi edi lpDst:DWORD, lpSrc:DWORD, nSrcLen:DWORD
	
	mov esi,lpSrc
	mov edi,lpDst
	
@@:
	movzx eax,byte ptr[esi]
	fn wsprintf,edi,chr$("%02x"),EAX
	add edi,2
	inc esi
	dec nSrcLen
	mov ecx,nSrcLen
	test ecx,ecx
	jne @b
	
	Ret
	
max_ConvertBytesToAscii EndP
thProc proc hWnd : DWORD
	LOCAL l : DWORD

	mov	l, 0

	push	100
	call	Sleep

	push	hWnd
	call	GetDC
	mov	scrAbout.hBkgDC, eax


	push	SYSTEM_FIXED_FONT
	call	GetStockObject
        mov	 scrAbout.hFont, eax


	push	offset scrAbout
	call	scrollCreate

_st:
	push	offset scrAbout
	call	scrollPaint

	push	20
	call	Sleep

	inc	l
	cmp	l, -1
	jnz	_st


	ret
thProc endp
DialogBoxTransparente proc _handle:dword,_transvalue:dword
		
	LOCAL local_retvalue:byte ;variable locale
	
	pushad
	mov local_retvalue,0
	
	fn GetModuleHandle,chr$("user32.dll")
	fn GetProcAddress,eax,chr$("SetLayeredWindowAttributes")
	.if eax!=0
		mov edi,eax
		mov esi,_handle ; pousse l'handle
		
		fn	GetWindowLong,esi,GWL_EXSTYLE			;get EXSTYLE
		.if eax!=0
			or eax,WS_EX_LAYERED				;eax = oldstlye + new style(WS_EX_LAYERED)
			
			fn SetWindowLong,esi,GWL_EXSTYLE,eax
			.if eax!=0
				push LWA_ALPHA
				push 230;_transvalue			;pousse la valeur du taux de  transparence
				push 0					;transparent color 0-255 (0=transparent)
				push esi				;window handle
				call edi				;call SetLayeredWindowAttributes
				.if eax!=0
					mov local_retvalue,1
				.endif	
			.endif
		.endif
	.endif	
	
	popad
	movzx eax,local_retvalue
	ret
DialogBoxTransparente endp
end start