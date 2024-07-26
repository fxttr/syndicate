BINDIR = @bindir@
SRC=$(shell ls boot.nasm)
OBJ=$(shell ls boot.nasm | sed -e 's/nasm/bin/')

all: compile
	@echo "[1] Done."

compile: ${OBJ}
	@echo "[0] Compiling loader.bin"

${OBJ}: ${SRC}
	@nasm -f bin $< -o loader.bin

.PHONY: clean install

install:
	install -d $(BINDIR)
	install -t $(BINDIR) loader.bin

clean:
	@echo "Cleaning"
	@rm -rf *.bin *.o *.img
