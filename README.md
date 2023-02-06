# cpp-shellcode
this repo is a documentation of what i've learned about shellcodes and what not, while this might not be complete, but this would be usefull if you forgot a thing or two about running shellcode in cpp

## how to use

### shellcode setup
to compile the shell code you can use this command
```bash
# for 32 bit:
nasm -f elf32 -g -F dwarf <shellcode-file>.asm && ld -m elf_i386 -o <shellcode-file> <shellcode-file>.o

# for 64 bit:
nasm -f elf64 -g -F dwarf <shellcode-file>.asm && ld -m elf_x86_64 -o <shellcode-file> <shellcode-file>.o
```

next, you can convert it from binary to either string or array with these command
```bash
# array
objdump -d <shellcode-file> | grep '[0-9a-f]:' | grep -v 'file' | cut -f2 -d:|tr '\t' ' ' | sed 's/\(\( [0-9a-f][0-9a-f]\)\+\)\( \+\)\(.*\)/\1/g'| paste -d '' -s | sed 's/ /, 0x/g' | sed 's/, \(.*\)/{\1}/'

# multiline string
objdump -d <shellcode-file> | grep '[0-9a-f]:' | grep -v 'file' | cut -f2 -d:|tr '\t' ' ' | sed 's/\(\( [0-9a-f][0-9a-f]\)\+\)\( \+\)\(.*\)/"\1"/g' | sed 's/ /\\x/g'
```


### main program setup
then after you copy the shellcodes we can paste it in the cpp file like so
```
unsigned char shellcode[] = {0xeb, 0x35, 0xb8, 0x01, 0x00, 0x00, 0x00, 0xbf, 0x01, 0x00, 0x00, 0x00, 0x5e, 0xe8, 0x0c, 0x00, 0x00, 0x00, 0x0f, 0x05, 0xb8, 0x01, 0x00, 0x00, 0x00, 0x48, 0x31, 0xdb, 0xcd, 0x80, 0x56, 0xba, 0x00, 0x00, 0x00, 0x00, 0x48, 0xff, 0xce, 0x48, 0xff, 0xc2, 0x48, 0xff, 0xc6, 0x80, 0x3e, 0x00, 0x75, 0xf5, 0x48, 0xff, 0xca, 0x5e, 0xc3, 0xe8, 0xc6, 0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x74, 0x68, 0x65, 0x72, 0x65, 0x21, 0x0a, 0x0d, 0x00};
```

next we just need to call the shellcode like so
```cpp
int main(){
    void (*shellcode_ptr)() = (void (*)()) shellcode;
    shellcode_ptr();
}
```

and the final main code would look like this
```
unsigned char shellcode[] = {0xeb, 0x35, 0xb8, 0x01, 0x00, 0x00, 0x00, 0xbf, 0x01, 0x00, 0x00, 0x00, 0x5e, 0xe8, 0x0c, 0x00, 0x00, 0x00, 0x0f, 0x05, 0xb8, 0x01, 0x00, 0x00, 0x00, 0x48, 0x31, 0xdb, 0xcd, 0x80, 0x56, 0xba, 0x00, 0x00, 0x00, 0x00, 0x48, 0xff, 0xce, 0x48, 0xff, 0xc2, 0x48, 0xff, 0xc6, 0x80, 0x3e, 0x00, 0x75, 0xf5, 0x48, 0xff, 0xca, 0x5e, 0xc3, 0xe8, 0xc6, 0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x74, 0x68, 0x65, 0x72, 0x65, 0x21, 0x0a, 0x0d, 0x00};

int main(){
    void (*shellcode_ptr)() = (void (*)()) shellcode;
    shellcode_ptr();
}
```

or you can be a little bit more safer by using momving the shellcode to an executable memory region like so
```
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <sys/mman.h>

unsigned char shellcode[] = {0xeb, 0x35, 0xb8, 0x01, 0x00, 0x00, 0x00, 0xbf, 0x01, 0x00, 0x00, 0x00, 0x5e, 0xe8, 0x0c, 0x00, 0x00, 0x00, 0x0f, 0x05, 0xb8, 0x01, 0x00, 0x00, 0x00, 0x48, 0x31, 0xdb, 0xcd, 0x80, 0x56, 0xba, 0x00, 0x00, 0x00, 0x00, 0x48, 0xff, 0xce, 0x48, 0xff, 0xc2, 0x48, 0xff, 0xc6, 0x80, 0x3e, 0x00, 0x75, 0xf5, 0x48, 0xff, 0xca, 0x5e, 0xc3, 0xe8, 0xc6, 0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x74, 0x68, 0x65, 0x72, 0x65, 0x21, 0x0a, 0x0d, 0x00};

int main() {
    int length = sizeof(shellcode);
    void *exec_mem = mmap(NULL, length, PROT_EXEC | PROT_WRITE | PROT_READ, MAP_ANON | MAP_PRIVATE, -1, 0);
    memcpy(exec_mem, shellcode, length);

    void (*shellcode_ptr)() = (void (*)()) exec_mem;
    shellcode_ptr();

    munmap(exec_mem, length);
    return 0;
}
``` 


### compile and run
to compile and run the code we just made you need to use some flags that disables stack protection with this command
```bash
# for 32 bit
g++ -m32 runShellcode.cpp -g -Wall -fno-stack-protector -z execstack -o runShellcode

# for 64 bit
g++ runShellcode.cpp -g -Wall -fno-stack-protector -z execstack -o runShellcode
```

if you were using the memcopy to copy the shellcode to executable region, you can run it without flag like so
```
# for 32 bit
g++ -m32 runShellcode.cpp -g -o runShellcode

# for 64 bit
g++ runShellcode.cpp -g -o runShellcode
```

#### NOTE!
here are some of the things you might want to look for:

- with that being said if you are using a more sophisticated shellcode, you will need to use the flags

- you also would need to change the shell code based on what platform you are targetting, for instance the api used by the linux kernel is different, in the 32bit version you would need to use this instruction `int 0x80` or `int 80h` while in 64bit you would need to use `syscall` and the argument that used to call the syscall is different too,

- in 32bit, to print text to screen you would use these instruction
  ```nasm
  mov eax, 0x4  ;point to the write api
  mov ebx, 0x1  ;give write permission
  pop ecx       ;pull char pointer from the stack
  mov edx, 0xE  ;length of the string
  ```
  while in 64bit, it would look more like this
  ```nasm
  mov rax, 0x1  ;equivalent to `mov eax,0x4`
  mov rdi, 0x1  ;equivalent to `mov ebx,0x1`
  pop rsi       ;equivalent to `pop ecx`
  mov rdx, 0xE  ;equivalent to `mov edx, 0xE`
  ```
  so not only the argument might change, the register used by the argument might also need to be change
