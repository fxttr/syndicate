SRC!= ls boot.nasm
OBJ!= ls boot.nasm | sed -e 's/nasm/bin/'

all: stage1
	@echo "[1] Done."

stage1: ${OBJ}
	@echo "[0] Building Stage1"

${OBJ}: ${SRC}
	@nasm -f bin ${.ALLSRC} -o loader.bin

.PHONY: clean run

img: clean all
	@echo "[2] Building Image"
	@truncate -s 128m os.img
	@mdconfig os.img
	@gpart create -s mbr md0
	@gpart add -t \!11 md0
	@newfs_msdos -F32 -b 512 /dev/md0s1
	@dd if=loader.bin of=os.img seek=0 count=1 bs=512 conv=notrunc
#@mount -t msdosfs /dev/md0s1 /mnt
#@cp /home/florian/Devel/MSON/build/kernel/MSON /mnt
#@umount /mnt

run: img
	qemu-system-x86_64 -hda /dev/md0

clean:
	@echo "Cleaning"
	@-mdconfig -du md0
	@rm -rf *.bin *.o *.img
