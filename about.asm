

;


;******************************************************************************
;* PROTOTYPES                                                                 *
;******************************************************************************

AboutProc 			proto :dword,:dword,:dword,:dword
UpdateScroller			proto
CreateTVBox 			proto :dword
UpdateTVBox 			proto
Random 				proto :dword
BallSize 				proto :dword,:dword
BallFpu 				proto
;******************************************************************************
;* DATA & CONSTANTS                                                           *
;******************************************************************************
.const


.data
AboutFont			LOGFONT <16, 7, 0, 0, FW_BOLD, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_CHARACTER_PRECIS, 										CLIP_DEFAULT_PRECIS,PROOF_QUALITY,DEFAULT_PITCH,"courier new">

szAboutText_   db " TeaM  xtx présente",13,13
			db " KeyfileMaker pour le ASTRALCrackme1 ",13
			db "  codé par ++Meat  ",13,13
			db " Remerçiements à  :",13,13
			db" ++Meat pour ce crackme ",13
			db " Salutations à  :",13,13
			db "Coolmen,Kirjo,Z!PPer,mars,Burner, ",13,13
			db "Taloche,hibou28,LinSkull,sorcier21,",13,13
			db " stephio59,SpiNa,gortex3D, le fouineur,",13,13
			db " goliat17,et tout ceux que j'ai oublié... ",13,13
			db " GFX & Keygen by :Sp0ke ",13,13
			db "@++ ",13,13,13
			db " ----------------",13
			db " TeaM  xtx",13
			db " Juillet 2010",13
			db " ----------------",13,13,13
			db " ",13,13,13,13,13,13,13,13,13
			db " ",13,13,13,0

nrandom_seed dd "O63."

.data?

szbla	dd 30 dup (?)

WX	equ 300
WY	equ 90
top	equ 0
left	equ 0

ppv	dd ?
srcdc	dd ?
hdcx	dd ?
thread	dd ?
threadID	dd ?
;******************************************************************************
;* CODE                                                                       *
;******************************************************************************
.code



divisor:
dd 700.000
dd 25.00000
dd 435.000
dd 22.00000
dd 480.000
dd 42.00000
dd 412.000
dd 22.00000
dd 450.000
dd 25.00000
dd 435.000
dd 41.00000
dd 410.000
dd 65.00000
dd 475.000
dd 21.00000

position:
dd WX/2
dd WX/5
dd WY
dd WX/4
dd WX/2
dd WX/6
dd WX/2
dd WX/5


align 4


align 4
AboutProc proc uses ebx esi edi hWnd:dword,message:dword,wparam:dword,lparam:dword
	local rect:RECTL
	mov eax,message
	.if eax==WM_INITDIALOG
		
		fn GetParent,hWnd
		mov ecx,eax
		fn GetWindowRect,ecx,addr rect
		mov edi,rect.left
		mov esi, rect.top
		add edi,2
		add esi,22
		fn SetWindowPos,hWnd,HWND_TOP,570,424, 296,80,0
		fn CreateTVBox,hWnd
;	 fn AnimateWindow, hWnd, 1000, AW_ACTIVATE or AW_CENTER 			
;		fn uFMOD_PlaySong,OFFSET xm,xm_length,XM_MEMORY
	.elseif eax==WM_COMMAND

	.elseif eax == WM_LBUTTONDOWN
		fn  SendMessage,hWnd,WM_CLOSE,0,0
	.elseif eax==WM_CLOSE
		fn TerminateThread,threadID,0
		fn DeleteDC,srcdc
; fn AnimateWindow, hWnd, 1000,   AW_HIDE     or AW_CENTER			
;		fn uFMOD_PlaySong,0,0,0
		fn EndDialog,hWnd,0
	.endif
	xor eax,eax
	ret 	                         
AboutProc endp

align 4
UpdateScroller proc 
	local rect:RECT
	local int_position:dword
	local local_match:dword

	mov int_position, WY
	mov local_match,2

	@@:

      	fn UpdateTVBox
	fn SetRect,addr rect, left,  int_position, WX, WY
	fn lstrlen,addr szAboutText_
	mov edi,eax
	fn DrawText,srcdc,addr szAboutText_,edi,addr rect,DT_CENTER or DT_TOP
	fn  BitBlt, hdcx, left, top, WX, WY, srcdc, 0, 0, SRCCOPY

        	.if int_position == -0190h
	mov int_position, WY
	.endif

	dec local_match

	 .if local_match == 1
	dec int_position
	mov local_match,4
	.endif

	fn Sleep,10

	jmp @B
	ret
UpdateScroller endp

align 4
CreateTVBox proc hWnd:dword
	local bmpi:BITMAPINFO

	fn GetWindowDC,hWnd
	mov hdcx,eax
	fn CreateCompatibleDC, eax
	mov srcdc, eax
	fn RtlZeroMemory,addr bmpi, sizeof BITMAPINFO
	mov bmpi.bmiHeader.biSize, sizeof bmpi.bmiHeader
	mov bmpi.bmiHeader.biBitCount, 32
	mov eax,WX
	imul eax,eax,4
	imul eax,eax,WY
	mov bmpi.bmiHeader.biSizeImage, eax
	mov bmpi.bmiHeader.biPlanes, 1
	mov bmpi.bmiHeader.biWidth, WX
	mov bmpi.bmiHeader.biHeight, WY
 	fn  CreateDIBSection, srcdc, addr bmpi, DIB_RGB_COLORS, addr ppv, 0, 0
	fn  SelectObject, srcdc, eax
	fn CreateFontIndirect,addr AboutFont
	fn  SelectObject, srcdc, eax
	fn  SetBkMode, srcdc, TRANSPARENT
	fn  SetTextColor, srcdc, 00BAF999h
	fn CreateThread,0,0,offset UpdateScroller,0,0,addr thread
	mov threadID,eax
	fn SetThreadPriority,eax,THREAD_PRIORITY_LOWEST
	ret
CreateTVBox endp

align 4
UpdateTVBox proc uses edi esi ebx

	mov edi,ppv
        	xor ecx,ecx
	xor esi,esi

	.while ecx != WX*WY

		.if ebx  == 1 && esi  == 0  &&  ebx == WX-1 && esi == WY-1
		xor eax, eax
		.else
		push ecx
		fn Random, 150
		add al, 9
		mov ah, al
		shl eax, 8
		mov al, ah
		pop ecx
		.endif
		stosd
		inc ebx
		.if ebx == WX
		xor ebx, ebx
		inc esi
		.endif
		inc ecx
		.endw

	fn BallFpu
	mov edi,ppv
	xor  ecx, ecx
	xor ebx,ebx
	xor esi,esi

	.while ecx != WX*WY

		inc ebx

		.if ebx == WX
		xor ebx,ebx
		inc esi
		.endif

		.if ebx  > 1 && esi  > 0  &&  ebx < WX-1 && esi < WY-1

		push ecx
		fn BallSize,ebx,esi

		.if eax > 500

		mov eax,dword ptr [edi]
		and eax,00BFFFh
		shr eax,1
		mov dword ptr [edi],eax

		.else

		.if eax > 400

		mov eax,dword ptr [edi]
		and eax,1
		add eax,1
		shr eax,1
		mov dword ptr [edi],eax

		.endif
		.endif

		pop ecx

		.endif

		add edi,4
		inc ecx
	.endw
	ret
UpdateTVBox endp

align 4
Random proc uses edx ecx, base:dword

	mov eax, nrandom_seed
	xor edx, edx
	mov ecx, 999999
	div ecx
	mov ecx, eax
	mov eax, 16807
	mul edx
	mov edx, ecx
	mov ecx, eax
	mov eax, 2836
	mul edx
	sub ecx, eax
	xor edx, edx
	mov eax, ecx
	mov nrandom_seed, ecx
	div base
	mov eax, edx
	ret
Random endp

align 4
BallFpu proc
	local local_match:dword
	local local_result:dword

	fn GetTickCount
	mov local_match,eax
	mov local_result,0
	xor edi,edi
	xor edx,edx
       
	.while edi != 16
		fild local_match
		fdiv dword ptr [divisor+edi*4]
		fcos
		inc edi	
		fmul dword ptr [divisor+edi*4]
		fistp local_result
		push local_result
		pop dword ptr [szbla+edx*4]
		mov eax,dword ptr [position+edx*4]
		add dword ptr [szbla+edx*4],eax
		fild local_match
		inc edi
		fdiv  dword ptr [divisor+edi*4]
		fsin
		inc edi
		fmul  dword ptr [divisor+edi*4]
		fistp local_result
		push local_result
		inc edx
		pop dword ptr [szbla+edx*4]
		mov eax,dword ptr [position+edx*4]
		add dword ptr [szbla+edx*4],eax
		inc edi
		inc edx
	.endw

	ret

BallFpu endp

align 4
BallSize proc uses esi edi ebx a:dword,b:dword

	mov esi,offset szbla
	xor edi,edi
	xor ebx,ebx

	.while edi != 4
		mov eax,dword ptr [esi]
		sub eax,a
		cdq
		mul eax
		mov ecx,eax
		mov eax,dword ptr [esi+4]
		sub eax,b
		cdq
		mul eax
		add eax,ecx
		.if !eax
		mov eax,-1
		ret
		.endif
		xor edx,edx
		mov ecx,eax
		mov eax,00FFFF00h
		div ecx
		add ebx,eax
		add esi,8
		inc edi
	.endw
	mov eax,ebx
	ret
BallSize endp

	popad

