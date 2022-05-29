.const
KeySize equ  33

.data
	KeyfileName         db	"ASTRALKEY",0
	hFile		HANDLE ?
	UserKey         dd ?
	BufSize=( $ - UserKey  )
	Nbr_Octet_Ecrit	db 		32 dup(?)

	appname					db		"xtxTeam",0
	ParentWindow				db 		"Application",0
	HandleString				db 		2000 dup(?)


	Table       db "ASTRL",0

scrAbout SCROLLSTRUCT <485,SRCPAINT,3,8,0,offset szAboutText_,0,0004F2FFh>

keygen_routine proto hWnd:dword

.data?

	UserKey2 db 32 dup (?)
	whandle	db 10 dup (?)	
	PublicKey       db KeySize dup (?)
	PrivateKey      db KeySize dup (?)	
	handle          HWND                ?
	szSerial               db 512 dup(?)

.code


GETV MACRO dVar
	mov eax,dVar
  EXITM <eax>
ENDM 
;random_number proc uses ecx edx _min_number:dword,_max_number:dword
;    @@:
;    rdtsc
;    
;    mov ecx,_max_number
;    .if ecx!=0FFFFFFFFh
;        inc ecx
;    .endif
;        
;    xor edx,edx
;    div ecx
;    mov eax,edx
;    
;    cmp eax,_min_number
;    jl @B
;    
;    ret
;random_number endp
keygen_routine proc hWnd:HWND

push hWnd
pop handle
fn GetDlgItemText, hWnd, IDC_NAME,ADDR PublicKey, sizeof  PublicKey	


;======================== ripped code =========================================

    xor ecx, ecx
    .WHILE ecx < KeySize
        sub byte ptr [offset PublicKey+ecx], '0'
        movzx eax, byte ptr [offset PublicKey+ecx]
        mov bl, byte ptr [offset Table+eax]
        mov byte ptr [offset PrivateKey+ecx], bl
        inc ecx
    .ENDW
;============================================================================
fn lstrcpy,addr UserKey ,addr PrivateKey
fn lstrcpy,addr UserKey2 ,addr UserKey

	fn InvalidateRect,hWnd,0,0
	fn EnumWindows, addr WindowHandle,0
	test eax,eax
	jne @f
	fn SendDlgItemMessage, dword ptr whandle, 194h,WM_SETTEXT, 0, addr namebuffer
	fn SendDlgItemMessage, dword ptr whandle, 195h,WM_SETTEXT, 0, addr UserKey
	@@:
	

	fn SendDlgItemMessage,hWnd,IDC_SERIAL,EM_SETSEL,0,-1 
	fn SendDlgItemMessage, hWnd, IDC_SERIAL, WM_COPY, 0,0

 
	@finish:

		fn RtlZeroMemory,addr PrivateKey,sizeof PrivateKey

	ret
keygen_routine endp
