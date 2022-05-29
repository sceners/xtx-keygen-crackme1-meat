szText MACRO Name, Text:VARARG
	LOCAL lbl
		jmp lbl
		Name db Text,0
	lbl:
ENDM

.data	
BUF			dd 5 dup(00)

.code
BmpButton_ proc hwnd:DWORD,loc_X:DWORD,loc_Y:DWORD,UP:DWORD,OVER:DWORD,DOWN:DWORD,button_id:DWORD

LOCAL hModule		:DWORD
LOCAL hNew 			:DWORD
LOCAL hImage		:DWORD
LOCAL Btn_Rect		:RECT
LOCAL Wnd_Class		:WNDCLASSEX
LOCAL hUP			:DWORD
LOCAL hDOWN 		:DWORD
LOCAL hOVER			:DWORD

fn GetModuleHandle, NULL
mov hModule, eax

fn LoadBitmap, eax, UP
mov hUP, eax

fn LoadBitmap, hModule, DOWN
mov hDOWN, eax

fn LoadBitmap, hModule, OVER
mov hOVER, eax

szText BMP_CLASS,"Bmp_Button_Class_sp0ke"

mov Wnd_Class.cbSize, sizeof WNDCLASSEX
mov Wnd_Class.style, CS_BYTEALIGNWINDOW
mov Wnd_Class.lpfnWndProc, offset BitmapButtonProc
mov Wnd_Class.cbClsExtra, NULL
mov Wnd_Class.cbWndExtra, 20
mov eax, hModule
mov Wnd_Class.hInstance, eax
mov Wnd_Class.hbrBackground,  COLOR_BTNFACE+1
mov Wnd_Class.lpszMenuName,NULL
mov Wnd_Class.lpszClassName, offset BMP_CLASS
mov  Wnd_Class.hIcon, NULL
	
fn LoadCursor, NULL, IDC_ARROW
mov Wnd_Class.hCursor,eax
mov Wnd_Class.hIconSm,NULL

lea eax, Wnd_Class
	
fn RegisterClassEx, eax

fn CreateWindowEx, WS_EX_TRANSPARENT,offset BMP_CLASS, NULL, WS_CHILD or WS_VISIBLE, loc_X,loc_Y, 100,100, hwnd, button_id, hModule, NULL

	    
mov hNew, eax

	fn SetWindowLong,hNew,0,hUP
	fn SetWindowLong,hNew,4,hDOWN
	fn SetWindowLong,hNew,8,hOVER
	
szText St_CLASS,"STATIC"

	fn CreateWindowEx,0,	addr St_CLASS,NULL,WS_CHILD or WS_VISIBLE or SS_BITMAP,0,0,0,0,hNew, button_id,hModule,NULL
mov hImage,eax


fn SendMessage,eax,STM_SETIMAGE,IMAGE_BITMAP,hUP
lea edi,Btn_Rect
assume edi:ptr RECT
fn GetWindowRect,hImage,edi
fn SetWindowLong,hNew,12,hImage

	mov ecx,[edi].bottom
	sub ecx,[edi].top
	
	mov eax,[edi].right
	sub eax,[edi].left


fn SetWindowPos,hNew,HWND_TOP,0,0,eax,ecx,SWP_NOMOVE
fn ShowWindow,hNew,SW_SHOW
mov eax,hNew

xor esi,esi
xor edi,edi

ret
BmpButton_ Endp


BitmapButtonProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	LOCAL Rct    :RECT
	LOCAL pt     :POINT
	
	.data?
	cFlag db ?
	oFlag db ?
	
	.code
	mov eax,uMsg
	.if eax == WM_LBUTTONDOWN
		fn GetWindowLong,hWin,4
		mov ebx, eax
		fn GetWindowLong,hWin,12
		fn SendMessage,eax,STM_SETIMAGE,IMAGE_BITMAP,ebx
		fn SetCapture,hWin
		mov cFlag, 1
	
	.elseif eax==WM_MOUSEMOVE
		
		lea esi,Rct
		assume esi:ptr RECT
		lea edi,pt
		assume edi:ptr POINT
		
		fn GetWindowRect,hWin,esi
		
		mov eax,lParam
		and eax,0FFFFh
		mov [edi].x,eax
		
		mov eax,lParam
		and eax,0FFFF0000h
		shr eax,16
		mov [edi].y,eax
		
		mov eax,[esi].right
		sub eax,[esi].left
		
		mov edx,[esi].bottom
		sub edx,[esi].top
				
		.if ([edi].x<0 || [edi].y<0 || [edi].x>eax || [edi].y>edx) && !cFlag
			fn GetWindowLong,hWin,0	;up
			mov ebx, eax
			fn GetWindowLong,hWin,12
			fn SendMessage,eax,STM_SETIMAGE,IMAGE_BITMAP,ebx
			fn ReleaseCapture
			
			mov oFlag,0
			
		.else 
			.if cFlag || oFlag
				ret	
			.endif
			
			fn SetCapture,hWin
			fn GetWindowLong,hWin,8
			mov ebx, eax
			fn GetWindowLong,hWin,12
			fn SendMessage,eax,STM_SETIMAGE,IMAGE_BITMAP,ebx
			
			mov oFlag,1
			
		.endif
		
		assume esi:nothing
		assume edi:nothing
		
	.elseif eax == WM_LBUTTONUP
	
		.if cFlag==0
			ret
		.else
			mov cFlag,0
			mov oFlag,0
			
			fn GetWindowLong,hWin,0
			mov ebx, eax
			fn GetWindowLong,hWin,12
			fn SendMessage,eax,STM_SETIMAGE,IMAGE_BITMAP,ebx
			
			mov eax,lParam
			cwde
			mov edi, eax
			mov eax, lParam
			rol eax, 16
			cwde
			mov ebx, eax
			
			fn GetWindowRect,hWin,ADDR Rct
			
			lea esi,Rct
			assume esi:ptr RECT
			
			mov eax,[esi].right
			sub eax,[esi].left
				
			mov edx, [esi].bottom
			sub edx, [esi].top
			
			cmp edi, 0
			jle @F
			
			cmp ebx, 0
			jle @F
			
			cmp edi,eax
			jge @F
			
			cmp ebx,edx
			jge @F
			
			fn GetParent,hWin
			mov ebx,eax
			
			fn GetDlgCtrlID,hWin
		
			fn SendMessage,ebx,WM_COMMAND,eax,hWin
			
			@@:
			
			fn ReleaseCapture
			
			assume esi:nothing
			
		.endif
		
	.endif
	
	fn DefWindowProc,hWin,uMsg,wParam,lParam
	ret
BitmapButtonProc endp