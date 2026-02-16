@echo off

echo "It will now start to compile Assembly to an .img for QEMU and .iso for VirtualBox!"

echo "Looking for old boot files and deleting them..."
echo "Successfully deleted!"

echo "Starting to compile Assemly..."

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
sh -c "dd if=/dev/zero of=floppy.img bs=512 count=2880"
sh -c "dd if=boot.bin of=floppy.img conv=notrunc"
sh -c "dd if=kernel.bin of=floppy.img bs=512 seek=1 conv=notrunc"

echo "Finished compiling Assembly to floppy.img, it can now be used in QEMU!"

mkdir iso_root
mkdir boot
copy floppy.img .\boot
move /y floppy.img .\iso_root
mkisofs -o rusos-x86_64.iso -b floppy.img -c boot.catalog iso_root
move rusos-x86_64.iso .\boot

echo "Finished compiling floppy.img to rusos-x86_64.iso for usage in VirtualBox!"

read -p "Do you want to start the OS now in QEMU, or later manually in VirtualBox? (now/later): " antwort

if ["$antwort" = "now" then
    echo "Starting in QEMU..."

    qemu-system-x86_64 -fda .\iso_root\floppy.img
	
    echo "Started RusOS in QEMU!"
else
    echo "Understandable, have a great day! You will find the .iso in the 'boot' folder."
fi

pause

Oh... you ask why? So... I dont't know hehe :3 I just do it because Low-Level coding makes fun :D or maybe it is just what programmers doing when they are depressed... learning Assembly and making an OS in it... NAHHHH just kidding I am not depressed I am just having so much fun seeing how my own OS fully written in Assembly grows :D also shoutout to that dude called @gotssl on YouTube, you are the best, thanks! Even if you are just having 2 tutorials, you helped me a lot! So... YOU ARE IN THE CREDTS YAYYYY :P