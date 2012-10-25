SRC = $(wildcard *.s)
OBJ = $(SRC:.s=.o)

arm-as := as
arm-ld := ld

ifeq ($(shell uname -m),x86_64)
arm-as := arm-elf-as
arm-ld := arm-elf-ld
endif
asflags := -g
ldflags := -g

all:  link
link: assembly
ifeq ($(shell uname -m),x86_x64)
	arm-elf-as $(ldflags) -Ttext=0 ../lab7/sys.o $(OBJ) -o prog
else	
	ld $(ldflags) $(OBJ) -o prog
endif
assembly:
	make $(OBJ)
%.o: %.s
	$(arm-as) $(asflags) $< -o $@
clean:
	rm prog $(OBJ)
run: links
ifeq ($(shell uname -m),x86_64)
	arm-sim --load=prog -cycles=10000
else	
	./prog
endif
gdb: link
ifeq ($(shell uname -m),x86_64)
	#killall arm-sim
	armv5e-elf-gdb ./prog
else	
	gdb ./prog
endif

gdb-host: link
	arm-sim --load=prog -cycles=10000 -enable-gdb -gdb-port=5928 -debug-core