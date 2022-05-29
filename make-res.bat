\masm32\bin\ml /c /coff Keygen.asm
\masm32\bin\cvtres /machine:ix86 rsrc.res
\masm32\bin\Link /SUBSYSTEM:WINDOWS Keygen.obj rsrc.obj

if exist src.obj del Keygen.obj
if exist rsrc.obj del rsrc.obj

PAUSE 
CLS