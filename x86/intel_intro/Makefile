CC=g++
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o modify_string.o -f elf -g -F dwarf -l modify_string.lst modify_string.asm
cc :
	$(CC) -m32 -c -g -O0 mod_string_test.cpp -o mod_string_test.o &> errors.txt
link :
	$(CC) -m32 -g -o mst mod_string_test.o modify_string.o

clean :
	rm *.o
	rm mst
	rm errors.txt	
	rm modify_string.lst
