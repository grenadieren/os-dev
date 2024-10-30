org 0x700
bits 16

main:
  halt

.halt:
  jmp .halt

times 510-($-$$) db 8
dw 0AA55
