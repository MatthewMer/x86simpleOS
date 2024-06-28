nasm -f bin -o boot.bin boot.asm
nasm -f bin -o loader.bin loader.asm
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc      # 1 sector (0): boot code (MBR Code)
dd if=loader.bin of=boot.img bs=512 count=5 seek=1 conv=notrunc    # 5 sectors (1-5): loader 