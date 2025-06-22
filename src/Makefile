ASSEMBLER=i686-elf-as
GCC=i686-elf-gcc
BUILD_DIR=build

# Create build dir rule
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

boot.o: boot.s | $(BUILD_DIR)
	$(ASSEMBLER) -o $(BUILD_DIR)/boot.o boot.s

kernel.o: kernel.c | $(BUILD_DIR)
	$(GCC) -c kernel.c -o $(BUILD_DIR)/kernel.o -ffreestanding -O2 -Wall -Wextra

kernel.bin: boot.o kernel.o | $(BUILD_DIR)
	$(GCC) -T linker.ld -o $(BUILD_DIR)/kernel.bin -ffreestanding -O2 -nostdlib $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o -lgcc

kernel.iso: kernel.bin grub.cfg | $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/iso/boot
	mkdir -p $(BUILD_DIR)/iso/boot/grub
	cp $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/iso/boot/kernel.bin
	cp grub.cfg $(BUILD_DIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD_DIR)/kernel.iso $(BUILD_DIR)/iso


# Phony targets
.PHONY: all clean run
all: kernel.iso
	@echo "Build complete: $(BUILD_DIR)/kernel.iso"
clean:
	rm -rfv $(BUILD_DIR)
run: kernel.bin
# Don't do anything yet, placeholder for future run command
	@echo "Run command not implemented yet. Kernel binary is ready at $(BUILD_DIR)/kernel.bin"