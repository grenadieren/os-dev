## Chapter 1: Creating a Bootable Disk from Scratch
 In this chapter, we’ll start from scratch and guide you through creating a simple bootable disk that displays a "Hello, World!" message. Along the way, we’ll explain important concepts and provide easy-to-follow steps for beginners.

### 1.1 What is a Bootable Disk?

A bootable disk is any storage device that a computer can use to start an operating system or program. It contains a small program called a bootloader in its boot sector (first 512 bytes of the disk), which the BIOS (Basic Input/Output System) executes when the computer starts.

  - **BIOS:** The firmware that initializes your computer's hardware and looks for a bootable disk to load.
  - **Boot Sector:** The first 512 bytes of a disk. If this sector contains a specific signature, the BIOS considers the disk bootable.
   - **Bootloader:** A small program in the boot sector that can load a more complex program or operating system.
To make a disk bootable, we’ll write a small bootloader that displays "Hello, World!" when the computer starts.

### 1.2 Tools You Need

To work with low-level assembly code, create disk images, and test our bootloader, we need to set up several essential tools.

  - NASM (Netwide Assembler): An assembler for converting our assembly code into machine code.
  
     ```sudo apt-get install nasm```
  
  - QEMU: A virtual machine emulator that lets us test our bootable disk image without restarting our computer.
 
     ```sudo apt-get install qemu```
    
  - GCC and G++: Compilers for C and C++ code, which may be useful later for creating more advanced bootable programs.
   
       ```sudo apt-get install gcc g++```
    
  - Vim: A text editor available on most systems, which will help us write and edit assembly code.
    
       ```sudo apt-get install vim```

### 1.3 Writing Your First Boot Sector Program

The bootloader program we write will be in assembly language, which is very low-level code that interacts closely with the computer’s hardware. The steps below will guide you through writing a program that displays "Hello, World!" on boot.

#### **Step-by-Step Code Explanation**
  1. Create a File Called boot.asm
    
      Open your code editor and create a new file called boot.asm. This will be the code that gets assembled into our bootloader.

  2. Write the Bootloader Code
    
     Copy and paste the following code into **boot.asm**:
  ```bash
; boot.asm - Bootloader code to display "Hello, World!"

BITS 16                  ; Tell assembler to use 16-bit mode (BIOS works in 16-bit)
org 0x7c00               ; Set memory origin to 0x7C00, where BIOS loads the boot sector

; Step 1: Load the message address into SI register
mov si, message          ; SI will point to the message string
call print_string        ; Call the print function

; Step 2: Keep the program running with an infinite loop
hang:
    jmp hang             ; Jump to 'hang' to loop indefinitely

; Step 3: Define the print function to display the message
print_string:
    mov ah, 0x0E         ; Set up BIOS teletype function to print characters
.print_char:
    lodsb                ; Load byte from [SI] into AL and increase SI
    cmp al, 0            ; Check if the byte is 0 (end of message)
    je .done             ; If yes, jump to '.done' (end of function)
    int 0x10             ; Call BIOS interrupt 0x10 to print character in AL
    jmp .print_char      ; Repeat for next character
.done:
    ret

; Step 4: Define the message string
message db 'Hello, World!', 0 ; String ends with 0 to mark its end

; Step 5: Pad remaining bytes with 0s to reach 512 bytes and add boot signature
times 510 - ($ - $$) db 0      ; Fill the remaining space with zeros
dw 0xAA55                      ; Boot sector signature that BIOS looks for

  ```
  3. Understanding the Code:
     
   - **BITS 16:** This tells NASM to assemble the code in 16-bit mode since the BIOS runs in this mode.
   - **org 0x7C00:** Sets the origin address where the BIOS will load the boot sector (0x7C00 in memory).
   - **Message and Print Function:** The print_string function uses a BIOS interrupt to display each character in the message "Hello, World!".
   - **Boot Sector Signature:** The last two bytes (0xAA55) mark this sector as bootable for the BIOS.

### 1.4 Assembling the Bootloader Code

Now that we have written our bootloader code, let’s turn it into a binary file that can be used as a boot sector.

- Open your terminal or command prompt.
- Run the following command to assemble boot.asm: ```nasm -f bin boot.asm -o boot.bin```

This will generate a binary file named boot.bin. This file contains the machine code that the BIOS can execute.

### 1.5 Creating a Bootable Disk Image

With our bootloader ready, we now need to place it in a disk image that can be used to boot a virtual machine.

 1. Create an Empty Disk Image
  - Run the following command to create a blank 1.44 MB disk image:
   - ```dd if=/dev/zero of=boot.img bs=512 count=2880```     
    - ```if=/dev/zero``` tells ``dd`` to fill the image with zeroes.    
    - ```of=boot.img```specifies the output file  
    - ```bs=512``` and ```count=2880``` create a 1.44 MB file, the standard size of a floppy disk.

2. Write the Boot Sector to the Disk Image
 - Now, we’ll add our bootloader (boot sector) to the beginning of this disk image:
  - ```dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc``` 
    - ```if=boot.bin``` specifies our assembled bootloader.
    - ```of=boot.img``` is the disk image we created.
    - ```conv=notrunc``` ensures the file is not truncated, preserving the entire 1.44 MB.
    
This disk image (boot.img) is now bootable and contains our bootloader in the first 512 bytes.

## 1.6 Testing the Bootable Disk Image

We’ll use QEMU to test our bootable disk image in a virtual machine environment. This will let us see our "Hello, World!" message on boot without restarting our computer.
 - run the following command to launch QEMU:
   - ```qemu-system-x86_64 -fda boot.img```
  
 - Expected Output::
 
If everything is set up correctly, you should see "Hello, World!" displayed in the QEMU window. This confirms that the BIOS recognized our boot sector and executed our bootloader code.
