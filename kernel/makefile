HEADER_s:=header.s
HEADER:=header.S
MAIN:=main.c
MAIN_BIN:=$(subst .c,.o,$(MAIN))
HEADER_s:=$(subst .S,.s,$(HEADER))
HEADER_BIN:=$(subst .S,.o,$(HEADER))
KERNEL_BIN:=kernel.bin
OS:=os
CFLAGS:= -mcmodel=large  -fno-builtin  -m64
ASFLAGS:= --64
LDFLAGS:=-b elf64-x86-64 -z muldefs


all:$(OS)
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary $(OS) $(KERNEL_BIN)

$(OS):	$(HEADER_BIN) $(MAIN_BIN) printk.o
	ld $(LDFLAGS) -o $(OS) $(HEADER_BIN) $(MAIN_BIN) printk.o -T Kernel.lds 

$(HEADER_s) : $(HEADER)
	gcc -E $< -o $@

$(HEADER_BIN) : $(HEADER_s)
	as	$(ASFLAGS) $< -o $@

$(MAIN_BIN):$(MAIN)
	gcc $(CFLAGS) -c $<

printk.o: printk.c
	gcc  $(CFLAGS) -c printk.c


clean:
	rm -f $(HEADER_s) $(HEADER_BIN) $(OS) $(MAIN_BIN) $(KERNEL_BIN)