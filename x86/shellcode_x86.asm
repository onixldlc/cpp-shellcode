section .text
  global _start

_start:
  jmp MESSAGE

MAIN:
  mov  eax,0x4
  mov  ebx,0x1
  pop  ecx
  call len
  int  0x80
  

  mov eax, 0x1
  mov ebx, 0x0
  int 0x80


len:
  push ecx
  mov edx, 0
  dec ecx
  count:
    inc edx
    inc ecx
    cmp byte[ecx], 0
    jnz count
  dec edx
  pop ecx
  ret

MESSAGE:
  call MAIN
  db 'hello there!', 0xA, 0xD, 0x0

section .data
