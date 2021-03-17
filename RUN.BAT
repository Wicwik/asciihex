tasm /l/zi/c FILES.ASM
tasm /l/zi/c ATOH.ASM
tasm /l/zi/c PROJECT.ASM

tlink /l/i/v PROJECT.OBJ FILES.OBJ ATOH.OBJ

PROJECT.EXE