CC=gcc
ASMBIN=nasm
FUNC=draw_triangle
IMG=image
OUT=mst
MAIN=main

all : asm cc image link
asm : 
	$(ASMBIN) -o $(FUNC).o -f elf -g -F dwarf -l $(FUNC).lst $(FUNC).asm
cc :
	$(CC) -m32 -c -g -O0 $(MAIN).c -o $(MAIN).o &> errors_$(MAIN).txt
image :
	$(CC) -m32 -c -g -O0 $(IMG).c -o $(IMG).o &> errors_$(IMG).txt
link :
	$(CC) -m32 -g -o $(OUT) $(FUNC).o $(IMG).o $(MAIN).o

clean :
	rm *.o
	rm errors_$(MAIN).txt
	rm errors_$(IMG).txt	
	rm $(FUNC).lst

clean_all :
	rm *.o
	rm $(OUT)
	rm errors_$(MAIN).txt
	rm errors_$(IMG).txt
	rm $(FUNC).lst
