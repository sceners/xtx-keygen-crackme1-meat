.code

_strlen proc
	push	edi
	push	ecx
	mov	edi,dword ptr [esp+0Ch]
	xor	eax,eax
	xor	ecx,ecx
	dec	ecx
	repne	scasb
	not	ecx
	dec	ecx
	mov	eax,ecx
	pop	ecx
	pop	edi
	ret	4
_strlen endp

scrollCreate proc lpSS : DWORD
	LOCAL sz : SIZEL
	LOCAL hBkgBrush : DWORD
	LOCAL hBkgPen : DWORD
	LOCAL ddLen : DWORD

	pushad

	mov	edi, lpSS
	assume	edi : ptr SCROLLSTRUCT

        push	[edi].hBkgDC
        call	CreateCompatibleDC
	mov	[edi].hInDC, eax

	mov	ebx, eax
	mov	esi, SelectObject

	push	[edi].hFont
	push	eax
	call	esi			;SelectObject

	lea	eax, sz
	push	eax
	push	[edi].lpstrText
	call	_strlen
	mov	ddLen, eax
	push	eax
	push	[edi].lpstrText
	push	ebx			;[edi].hInDC
	call	GetTextExtentPoint32

	push	sz.y
	pop	[edi].ddHeight

	push	sz.x
	pop	[edi].ddTxtWidth

	push	sz.y
	push	sz.x
	mov	eax, [edi].ddWidth
	shl	eax, 1
	add	dword ptr [esp], eax
	push	[edi].hBkgDC;ebx			;[edi].hInDC
	call	CreateCompatibleBitmap
	mov	[edi].hTxtBmp, eax


	push	eax
	push	ebx
	call	esi			;SelectObject


        push	TRANSPARENT
        push	ebx			;[edi].hInDC
        call	SetBkMode

	push	[edi].ddTxtColor
	push	ebx
	call	SetTextColor


	push	[edi].ddBkgColor
	call	CreateSolidBrush
	mov	hBkgBrush, eax

	push	eax
	push	ebx			;[edi].hInDC
	call	esi			;SelectObject
	push	eax


	push	[edi].ddBkgColor
	push	1
	push	PS_SOLID
	call	CreatePen
	mov	hBkgPen, eax

	push	eax
	push	ebx
	call	esi			;SelectObject
	push	eax


	push	sz.y
	push	sz.x
	mov	eax, [edi].ddWidth
	shl	eax, 1
	add	dword ptr [esp], eax
	push	0
	push	0
	push	ebx
	call	Rectangle


	push	ddLen
	push	[edi].lpstrText
	push	0
	push	[edi].ddWidth
	push	ebx
	call	TextOut


	push	ebx
	call	esi			;SelectObject
	push	ebx
	call	esi			;SelectObject

	push	hBkgPen
	call	DeleteObject
	push	hBkgBrush
	call	DeleteObject


	push	sz.y
	push	[edi].ddWidth
	push	[edi].hBkgDC		;[edi].hInDC
	call	CreateCompatibleBitmap
	mov	[edi].hBakTmpBmp, eax

	push	eax
	push	ebx			;[edi].hInDC
	call	esi			;SelectObject
	push	eax


	push	SRCCOPY
	push	[edi].Y
	push	[edi].X
	push	[edi].hBkgDC
	push	sz.y
	push	[edi].ddWidth
	push	0
	push	0
	push	ebx			;[edi].hInDC
	call	BitBlt

	push	ebx
	call	esi


	push	sz.y
	push	[edi].ddWidth
	push	[edi].hBkgDC		;[edi].hInDC
	call	CreateCompatibleBitmap
	mov	[edi].hTmpBmp, eax

	mov	[edi].ddPos, 0
	mov	[edi].dbStop, 0

	popad
	ret	4
scrollCreate endp

scrollPaint proc lpSS : DWORD
	pushad

	mov	edi, lpSS
	assume	edi : ptr SCROLLSTRUCT

	mov	ebx, [edi].ddTxtWidth
	add	ebx, [edi].ddWidth
	cmp	ebx, [edi].ddPos
	jne	_n
	mov	[edi].ddPos, 0
_n:


	push	[edi].hInDC
	call	CreateCompatibleDC
	push	eax

	push	[edi].hBakTmpBmp
	push	eax
	call	SelectObject


	push	[edi].hTmpBmp
	push	[edi].hInDC
	call	SelectObject

	xor	ebx, ebx

	pop	esi
	push	esi

	push	SRCCOPY
	push	ebx
	push	ebx
	push	esi
	push	[edi].ddHeight
	push	[edi].ddWidth
	push	ebx
	push	ebx
	push	[edi].hInDC
	call	BitBlt



        push	[edi].hTxtBmp
	push	esi
	call	SelectObject


	push	[edi].ddROP
	push	ebx
	push	[edi].ddPos
	push	esi
	push	[edi].ddHeight
	push	[edi].ddWidth
	push	ebx
	push	ebx
	push	[edi].hInDC
	call	BitBlt


	push	SRCCOPY
	push	ebx
	push	ebx
	push	[edi].hInDC
	push	[edi].ddHeight
	push	[edi].ddWidth
	push	[edi].Y
	push	[edi].X
	push	[edi].hBkgDC
	call	BitBlt


	call	DeleteDC

	cmp	[edi].dbStop, 1
	je	_e
	inc	[edi].ddPos
_e:


	popad
	ret	4
scrollPaint endp

scrollPause proc lpSS : DWORD
	push	edi

	mov	edi, lpSS
	assume	edi : ptr SCROLLSTRUCT

	cmp	[edi].dbStop, 1
	je	_z
	inc	[edi].dbStop
	jmp	_e
_z:
	dec	[edi].dbStop

_e:	pop	edi
	ret
scrollPause endp

scrollDestroy proc lpSS : DWORD
	pushad

	mov	edi, lpSS
	assume	edi : ptr SCROLLSTRUCT
	mov	esi, DeleteObject

	push	[edi].hInDC
	call	DeleteDC

	push	[edi].hTmpBmp
	call	esi			;DeleteObject

	push	[edi].hTxtBmp
	call	esi			;DeleteObject

	push	[edi].hBakTmpBmp
	call	esi			;DeleteObject

	popad
	ret	4
scrollDestroy endp
