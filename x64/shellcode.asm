BITS 64

section .text
  global _start

_start:
  jmp MESSAGE

MAIN:
  mov  rax,0x1
  mov  rdi,0x1
  pop  rsi
  call len
  syscall
  

  mov rax, 0x1
  xor rbx, rbx
  int 0x80


len:
  push rsi
  mov rdx, 0
  dec rsi
  count:
    inc rdx
    inc rsi
    cmp byte[rsi], 0
    jnz count
  dec rdx
  pop rsi
  ret

MESSAGE:
  call MAIN
  db 'hello there!', 0xA, 0xD, 0x0

section .data
