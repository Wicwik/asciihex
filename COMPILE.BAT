tasm /l/zi/c FILES.ASM
tasm /l/zi/c ATOH.ASM
tasm /l/zi/c PROJECT.ASM
tasm /l/zi/c TIME.ASM

tlink /l/i/v PROJECT.OBJ FILES.OBJ ATOH.OBJ TIME.OBJ

PROJECT.EXE