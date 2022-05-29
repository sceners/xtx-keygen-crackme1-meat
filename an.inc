;                                                                           
;[= THE ===========================================================================]  
;[] _________ ____   ____ _______  _____  _____  _____                 ____  ____ []  
;[] \       / \   | |   / \      \ \    \ \    \ \    \     /\     /\  \   \/   / []  
;[] /   ___/   |  | |  |   |   > / /   > \ |  > \ |    \   /  \   /  \  |      |  []  
;[] \   \___   |  |_|  |   |   > \ \  ___/ | |  / |  >  \ / /\ \ / /\ \ | |\/| |  []  
;[]  \____  \   \_   _/    |___  /  \___ \ |_|\ \ |___  / \__  / \__  / |_|  | |  []  
;[]       \/      | |          \/       \/     \/     \/     \/     \/        \|  []  
;[=============== |/ =============================================== SYSTEMS ======]  
;                             Presents:                                               
;                            Animate Window
;                            Author: CyberDoom


.686p

.data
anim dd 40000h


.code

AnimOpen proc hWnd:dword
                              invoke GetTickCount
                              movzx eax,al
                              bswap eax
                              rol eax,2
                              movzx eax,al
                              or al,al
                              jnz @F
                              
                              add anim,10h
                              
                         @@:
                              add anim,eax
                       
                      
                               push    anim
                               push    1F4h
                               push    hWnd
                               call    AnimateWindow
                               ret
AnimOpen endp

AnimClose proc hWnd:dword
                               mov eax,anim
                               sub eax,30000h
                               
                               push    eax
                               push    1F4h
                               push    hWnd
                               call    AnimateWindow
                               ret


AnimClose endp
