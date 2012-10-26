SRC = $(wildcard */*.s + *.s)
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
ifeq ($(shell uname -m),x86_64)
	arm-elf-ld $(ldflags) -Ttext=0 support/sys.o $(OBJ) -o prog
else	
	ld $(ldflags) $(OBJ) -o prog
endif
assembly:
	make $(OBJ)
%.o: %.s
	$(arm-as) $(asflags) $< -o $@
clean:
	rm prog $(OBJ)
run: link
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
