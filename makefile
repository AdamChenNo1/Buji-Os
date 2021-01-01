BOOT:=boot.asm
LOADER:=loader.asm
HEADER_s:=header.s
HEADER:=header.S
MAIN:=main.c
MAIN_BIN:=$(subst .c,.o,$(MAIN))
BOOT_BIN:=$(subst .asm,.bin,$(BOOT))
LOADER_BIN:=$(subst .asm,.bin,$(LOADER))
HEADER_s:=$(subst .S,.s,$(HEADER))
HEADER_BIN:=$(subst .S,.o,$(HEADER))
KERNEL_BIN:=kernel.bin
OS:=os
IMG:=boot.img
FLOPPY:=/media/

.PHONY:all

all:$(BOOT_BIN) $(LOADER_BIN) $(OS)
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	mount $(IMG) $(FLOPPY) -t vfat -o loop
	rm -f $(FLOPPY)$(LOADER_BIN) -v
	cp $(LOADER_BIN) $(FLOPPY) -v
	objcopy	-I	elf64-x86-64	-S -R	".eh_frame"	-R 	".comment"	-O	binary	$(OS)	$(KERNEL_BIN)
	rm -f $(FLOPPY)$(KERNEL_BIN) -v
	cp $(KERNEL_BIN) $(FLOPPY) -v
	sync
	umount $(FLOPPY)
clean:
	rm -f $(BOOT_BIN) $(LOADER_BIN)

$(BOOT_BIN) : $(BOOT)
	nasm $< -o $@

$(LOADER_BIN) : $(LOADER)
	nasm $< -o $@

$(HEADER_s) : $(HEADER)
	gcc -E $< -o $@

$(HEADER_BIN) : $(HEADER_s)
	as	--64	$< -o $@

$(MAIN_BIN):$(MAIN)
	gcc -mcmodel=large  -fno-builtin  -m64 -c $<

$(OS):$(HEADER_BIN) $(MAIN_BIN)
	ld -b elf64-x86-64 -o $@ header.o main.o -T Kernel.lds
