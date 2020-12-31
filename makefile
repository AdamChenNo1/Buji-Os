BOOT:=boot.asm
LOADER:=loader.asm
BOOT_BIN:=$(subst .asm,.bin,$(BOOT))
LOADER_BIN:=$(subst .asm,.bin,$(LOADER))
IMG:=boot.img
FLOPPY:=/media/

.PHONY:all

all:$(BOOT_BIN) $(LOADER_BIN)
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	mount $(IMG) $(FLOPPY) -t vfat -o loop
	rm -f $(FLOPPY)$(LOADER_BIN) -v
	cp $(LOADER_BIN) $(FLOPPY) -v
	sync
	umount $(FLOPPY)

clean:
	rm -f $(BOOT_BIN) $(LOADER_BIN)

$(BOOT_BIN) : $(BOOT)
	nasm $< -o $@

$(LOADER_BIN) : $(LOADER)
	nasm $< -o $@
