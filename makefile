BOOT_FOLDER:=bootloader/
KERNEL_FOLDER:=kernel/
BOOT_BIN:=boot.bin
BOOT:=$(BOOT_FOLDER)$(BOOT_BIN)
LOADER_BIN:=loader.bin
LOADER:=$(BOOT_FOLDER)$(LOADER_BIN)
KERNEL_BIN:=kernel.bin
KERNEL:=$(KERNEL_FOLDER)$(KERNEL_BIN)
OS:=os
IMG:=boot.img
FLOPPY:=/media/
MAKE:= make -w
CLEAN:=make clean
.PHONY:all

all: $(BOOT) $(LOADER) $(KERNEL)
	dd if=$(BOOT) of=$(IMG) bs=512 count=1 conv=notrunc
	-mount $(IMG) $(FLOPPY) -t vfat -o loop
	rm -f $(FLOPPY)$(LOADER_BIN) -v
	rm -f $(FLOPPY)$(KERNEL_BIN) -v
	cp $(LOADER) $(FLOPPY) -v
	cp $(KERNEL) $(FLOPPY) -v
	sync
	umount $(FLOPPY)

$(BOOT) $(LOADER):
	cd $(BOOT_FOLDER) && $(MAKE)

$(KERNEL):
	cd $(KERNEL_FOLDER) && $(MAKE)

clean:
	cd $(BOOT_FOLDER) && $(CLEAN)
	cd $(KERNEL_FOLDER) && $(CLEAN)

