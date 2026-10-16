# C 语言版本的实际反汇编与注释

本文件注释基于本次编译产生的 `ASCII_C.OBJ`，使用 Visual Studio 的 DUMPBIN 实际反汇编。原始输出保留在 `C_RAW.TXT`，调用符号的重定位记录保留在 `C_RELOC.TXT`。这里的地址是目标文件代码节内的偏移，不是 EXE 运行时的内存地址。

编译目标为 32 位 x86 Windows，使用 `/Od /Oy- /GS-` 关闭优化、保留栈帧并关闭本例的栈安全检查代码，便于对照 C 源码。汇编作业的另两个版本为 DOS 下的 16 位 8086 程序，所以寄存器宽度和输出接口有所不同。

## 局部变量与栈帧

| 位置 | C 变量 | 用途 |
| --- | --- | --- |
| `[ebp-0Ch]` | `ch` | 当前字符，从 ASCII 61h（a）递增 |
| `[ebp-8]` | `row` | 外层行号，取 0、1 |
| `[ebp-4]` | `col` | 内层列号，取 0 至 12 |

## 逐条注释

以下保留实际反汇编的机器码、地址和指令，分号后为补充的中文解释。

```asm
_print_ascii:
  00000000: 55                 push        ebp  ; 保存调用者的 EBP
  00000001: 8B EC              mov         ebp,esp  ; EBP 指向当前栈帧
  00000003: 83 EC 0C           sub         esp,0Ch  ; 为三个 int 局部变量预留 12 字节
  00000006: C7 45 F4 61 00 00  mov         dword ptr [ebp-0Ch],61h  ; ch = 0x61，即字符 'a'
            00  ; 上一条机器指令的最后一个字节
  0000000D: C7 45 F8 00 00 00  mov         dword ptr [ebp-8],0  ; row = 0
            00  ; 上一条机器指令的最后一个字节
  00000014: EB 09              jmp         0000001F  ; 首次直接检查外层条件，不先递增 row
  00000016: 8B 45 F8           mov         eax,dword ptr [ebp-8]  ; 读取 row
  00000019: 83 C0 01           add         eax,1  ; row + 1
  0000001C: 89 45 F8           mov         dword ptr [ebp-8],eax  ; 写回 row，完成 ++row
  0000001F: 83 7D F8 02        cmp         dword ptr [ebp-8],2  ; 比较 row 与 2
  00000023: 7D 4B              jge         00000070  ; row >= 2 则跳到函数收尾
  00000025: C7 45 FC 00 00 00  mov         dword ptr [ebp-4],0  ; 每一行开始时 col = 0
            00  ; 上一条机器指令的最后一个字节
  0000002C: EB 09              jmp         00000037  ; 首次直接检查内层条件，不先递增 col
  0000002E: 8B 4D FC           mov         ecx,dword ptr [ebp-4]  ; 读取 col
  00000031: 83 C1 01           add         ecx,1  ; col + 1
  00000034: 89 4D FC           mov         dword ptr [ebp-4],ecx  ; 写回 col，完成 ++col
  00000037: 83 7D FC 0D        cmp         dword ptr [ebp-4],0Dh  ; 比较 col 与 13（0Dh）
  0000003B: 7D 27              jge         00000064  ; col >= 13 则结束这一行，转去输出换行
  0000003D: 8B 55 F4           mov         edx,dword ptr [ebp-0Ch]  ; 读取当前字符 ch
  00000040: 52                 push        edx  ; 将 ch 作为参数压栈
  00000041: E8 00 00 00 00     call        _putchar  ; 调用 putchar(ch)；目标地址由链接器重定位
  00000046: 83 C4 04           add         esp,4  ; 调用者回收 4 字节参数空间
  00000049: 8B 45 F4           mov         eax,dword ptr [ebp-0Ch]  ; 读取 ch
  0000004C: 83 C0 01           add         eax,1  ; ch + 1
  0000004F: 89 45 F4           mov         dword ptr [ebp-0Ch],eax  ; 写回 ch，完成 ++ch
  00000052: 83 7D FC 0C        cmp         dword ptr [ebp-4],0Ch  ; 比较 col 与 12（0Ch）
  00000056: 7D 0A              jge         00000062  ; col >= 12 时跳过空格，避免行尾空格
  00000058: 6A 20              push        20h  ; 压入空格的 ASCII 码 20h
  0000005A: E8 00 00 00 00     call        _putchar  ; 调用 putchar(' ')
  0000005F: 83 C4 04           add         esp,4  ; 回收参数空间
  00000062: EB CA              jmp         0000002E  ; 跳到 ++col，继续内层循环
  00000064: 6A 0A              push        0Ah  ; 压入换行符 LF 的 ASCII 码 0Ah
  00000066: E8 00 00 00 00     call        _putchar  ; 调用 putchar('\n')
  0000006B: 83 C4 04           add         esp,4  ; 回收参数空间
  0000006E: EB A6              jmp         00000016  ; 跳到 ++row，继续外层循环
  00000070: 8B E5              mov         esp,ebp  ; 回收当前栈帧的局部变量空间
  00000072: 5D                 pop         ebp  ; 恢复调用者的 EBP
  00000073: C3                 ret  ; 返回调用者
  ; 00000074 至 0000007F 为 CC 填充字节，用于函数对齐，不属于正常循环流程。
_main:
  00000080: 55                 push        ebp  ; main：保存调用者的 EBP
  00000081: 8B EC              mov         ebp,esp  ; 建立 main 的栈帧
  00000083: E8 00 00 00 00     call        _print_ascii  ; 调用 print_ascii()
  00000088: 33 C0              xor         eax,eax  ; EAX = 0，对应 return 0
  0000008A: 5D                 pop         ebp  ; 恢复 EBP
  0000008B: C3                 ret  ; main 返回
```

## 对照 C 源码理解循环

- 外层 `for (row = 0; row < 2; ++row)` 对应初始化 row、`CMP row,2`、`JGE` 退出、递增 row 和 `JMP` 回跳。
- 内层 `for (col = 0; col < 13; ++col)` 对应初始化 col、`CMP col,0Dh`、`JGE` 退出、递增 col 和 `JMP` 回跳。
- `if (col < 12)` 编译为比较 col 与 0Ch；大于或等于 12 时用 `JGE` 跳过输出空格。
- `putchar` 接收一个 int 参数，因此调用前压入 4 字节，调用后由调用者用 `ADD ESP,4` 回收，符合此处的 x86 C 调用约定。
- 目标文件中的 `CALL` 机器码暂为 `E8 00 00 00 00`；调用目标已由符号和重定位记录指定，链接后会填入正确位移。它不是调用空地址。
- 编译器使用条件跳转实现 C 的 `for` 循环，没有使用 8086 的 `LOOP` 指令。这不影响 C 源码的循环含义。
- C 程序通过运行库的 `putchar` 输出字符；16 位汇编版本通过 `INT 21H / AH=02H` 输出字符。

## 复现

在 Windows 中双击 `BUILD_C.cmd`，会重新编译和链接 C 程序、导出 `C_RAW.TXT` 与 `C_RELOC.TXT`，并运行生成 `CRESULT.TXT`。`ASCII_C.COD` 是编译器生成的源码与汇编对照列表，可辅助阅读；本文件的注释依据是 DUMPBIN 的实际反汇编。

如修改 C 源码或编译选项，指令及地址可能改变，本注释文件需按新的 `C_RAW.TXT` 同步更新。
