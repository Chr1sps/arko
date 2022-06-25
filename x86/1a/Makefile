CC=g++
ASMBIN=nasm
FILE=modify_string
OUT=mst

all : asm cc link
asm : 
	$(ASMBIN) -o $(FILE).o -f elf -g -F dwarf -l $(FILE).lst $(FILE).asm
cc :
	$(CC) -m32 -c -g -O0 main.cpp -o main.o &> errors.txt
link :
	$(CC) -m32 -g -o $(OUT) main.o $(FILE).o

clean :
	rm *.o
	rm errors.txt	
	rm $(FILE).lst

clean_all :
	rm *.o
	rm $(OUT)
	rm errors.txt	
	rm $(FILE).lst
