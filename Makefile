SRC!= ls *stage_1.nasm
OBJ!= ls *stage_1.nasm | sed -e 's/nasm/bin/'

all: stage1
	@echo "[1] Done."

stage1: ${OBJ}
	@echo "[0] Building Stage1"

${OBJ}: ${SRC}
	@nasm -f bin ${.ALLSRC} -o loader.bin

.PHONY: clean

clean:
	@echo "Cleaning"
	@rm -rf *.bin *.o
