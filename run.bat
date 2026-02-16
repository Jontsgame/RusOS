@echo off
echo "It will now start to compile Assembly to an .img for QEMU and .iso for VirtualBox!"

echo "Looking for old boot files and deleting them..."
del boot.bin kernel.bin floppy.img
del .\boot\floppy.img
del .\boot\rusos-x86_64.iso
del .\iso_root\floppy.img
echo "Successfully deleted!"

echo "Starting to compile Assembly..."

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin

:: Falls du unter Windows kein 'sh' hast, musst du sicherstellen, dass dd im Pfad ist
sh -c "dd if=/dev/zero of=floppy.img bs=512 count=2880"
sh -c "dd if=boot.bin of=floppy.img conv=notrunc"
sh -c "dd if=kernel.bin of=floppy.img bs=512 seek=1 conv=notrunc"

echo "Finished compiling Assembly to floppy.img, it can now be used in QEMU!"

mkdir iso_root 2>nul
mkdir boot 2>nul
copy floppy.img .\boot
move /y floppy.img .\iso_root
mkisofs -o rusos-x86_64.iso -b floppy.img -c boot.catalog iso_root
move rusos-x86_64.iso .\boot

echo "Finished compiling floppy.img to rusos-x86_64.iso for usage in VirtualBox!"

:: --- HIER LIEGT DER FEHLER-FIX ---
set /p antwort="Do you want to start the OS now in QEMU, or later manually in VirtualBox? (now/later): "

if /i "%antwort%"=="now" (
    echo "Starting in QEMU..."
    qemu-system-x86_64 -fda .\iso_root\floppy.img
    echo "Started RusOS in QEMU!"
) else (
    echo "Understandable, have a great day! You will find the .iso in the 'boot' folder."
)

pause
