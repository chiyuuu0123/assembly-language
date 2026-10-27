# 作业4：C 实现的实际反汇编与中文注释

本文件对本次 MSVC 编译产生的 `MUL9_C.OBJ` 执行 DUMPBIN 后的真实指令加注释。原始输出见 [C_RAW.TXT](C_RAW.TXT)，重定位信息见 [C_RELOC.TXT](C_RELOC.TXT)。地址为目标文件代码节内的偏移，不是运行时地址。

使用 x86 32 位编译目标及 `/Od /Oy- /GS- /MT`，关闭优化、保留栈帧，使乘法、双重循环、过程调用和返回都能直接对照源码。下文逐条注释三个用户函数，函数之间的 CC 对齐填充和标准库包装函数未重复列出，完整指令保留在原始文件中。

## 1. print_cell：乘法、输出和定宽补空格

| 栈帧位置 | 含义 |
| --- | --- |
| `[EBP+8]` | 参数 row |
| `[EBP+0Ch]` | 参数 col |
| `[EBP-8]` | product |
| `[EBP-4]` | padding |
| `[EBP-0Ch]` | 条件表达式的临时值 |

```asm
_print_cell:
  00000000: 55                 push        ebp  ; 保存调用者 EBP
  00000001: 8B EC              mov         ebp,esp  ; 建立 print_cell 栈帧
  00000003: 83 EC 0C           sub         esp,0Ch  ; 分配 12 字节局部变量与临时值空间
  00000006: 8B 45 08           mov         eax,dword ptr [ebp+8]  ; 读取参数 row
  00000009: 0F AF 45 0C        imul        eax,dword ptr [ebp+0Ch]  ; EAX = row * col，保存乘积低 32 位
  0000000D: 89 45 F8           mov         dword ptr [ebp-8],eax  ; 保存 product 到 [EBP-8]
  00000010: 8B 4D F8           mov         ecx,dword ptr [ebp-8]  ; 读取 product
  00000013: 51                 push        ecx  ; 压入 printf 的 product 参数
  00000014: 8B 55 0C           mov         edx,dword ptr [ebp+0Ch]  ; 读取 col
  00000017: 52                 push        edx  ; 压入 col
  00000018: 8B 45 08           mov         eax,dword ptr [ebp+8]  ; 读取 row
  0000001B: 50                 push        eax  ; 压入 row
  0000001C: 68 00 00 00 00     push        offset $SG10021  ; 压入 %u*%u=%u 格式字符串地址
  00000021: E8 00 00 00 00     call        _printf  ; 调用 printf 输出一个算式
  00000026: 83 C4 10           add         esp,10h  ; 调用者回收四个参数，共 16 字节
  00000029: 8B 4D 0C           mov         ecx,dword ptr [ebp+0Ch]  ; 读取 col
  0000002C: 3B 4D 08           cmp         ecx,dword ptr [ebp+8]  ; 比较 col 与 row
  0000002F: 73 37              jae         00000068  ; col >= row 则为末列，跳过补空格
  00000031: 83 7D F8 0A        cmp         dword ptr [ebp-8],0Ah  ; 比较 product 与 10
  00000035: 73 09              jae         00000040  ; product >= 10 时使用三个空格
  00000037: C7 45 F4 04 00 00  mov         dword ptr [ebp-0Ch],4  ; 个位数乘积：临时值设为 4
            00  ; 上一条机器指令的续行字节
  0000003E: EB 07              jmp         00000047  ; 跳过另一个分支
  00000040: C7 45 F4 03 00 00  mov         dword ptr [ebp-0Ch],3  ; 两位数乘积：临时值设为 3
            00  ; 上一条机器指令的续行字节
  00000047: 8B 55 F4           mov         edx,dword ptr [ebp-0Ch]  ; 读取选中的空格数
  0000004A: 89 55 FC           mov         dword ptr [ebp-4],edx  ; 赋值给 padding（[EBP-4]）
  0000004D: 83 7D FC 00        cmp         dword ptr [ebp-4],0  ; 检查 padding 是否还有剩余
  00000051: 76 15              jbe         00000068  ; padding 为 0 时结束补空格
  00000053: 6A 20              push        20h  ; 压入空格的 ASCII 码 20h
  00000055: E8 00 00 00 00     call        _putchar  ; 调用 putchar 输出空格
  0000005A: 83 C4 04           add         esp,4  ; 回收一个参数
  0000005D: 8B 45 FC           mov         eax,dword ptr [ebp-4]  ; 读取 padding
  00000060: 83 E8 01           sub         eax,1  ; padding - 1
  00000063: 89 45 FC           mov         dword ptr [ebp-4],eax  ; 写回 padding
  00000066: EB E5              jmp         0000004D  ; 回到 while 条件
  00000068: 8B E5              mov         esp,ebp  ; 释放局部变量空间
  0000006A: 5D                 pop         ebp  ; 恢复调用者 EBP
  0000006B: C3                 ret  ; 返回 print_table
```

源码的 `unsigned int product = row * col` 在本次结果中使用双操作数 `IMUL` 得到乘积低 32 位。虽然这条指令名称含有 signed，本题输入均为 1～9，乘积不超过 81，与无符号乘法结果相同。手写 8086 版本明确使用 `MUL BL`，将 AL×BL 的完整乘积放到 AX。

`printf` 的四个参数按从右至左的顺序压栈，返回后由调用者 `ADD ESP,10h` 回收。末列跳过补空格，其他列根据乘积位数补 4 或 3 个空格，保持列宽 9。

## 2. print_table：双重循环和过程调用

row 位于 `[EBP-4]`，col 位于 `[EBP-8]`。编译器把循环变量保存在当前函数的栈帧中，调用输出过程后重新取出。

```asm
_print_table:
  00000070: 55                 push        ebp  ; 保存调用者 EBP
  00000071: 8B EC              mov         ebp,esp  ; 建立 print_table 栈帧
  00000073: 83 EC 08           sub         esp,8  ; 为 row、col 分配 8 字节
  00000076: 68 00 00 00 00     push        offset $SG10034  ; 压入标题字符串地址
  0000007B: E8 00 00 00 00     call        _puts  ; puts 输出标题并换行
  00000080: 83 C4 04           add         esp,4  ; 回收标题参数
  00000083: C7 45 FC 09 00 00  mov         dword ptr [ebp-4],9  ; row = 9，保存于 [EBP-4]
            00  ; 上一条机器指令的续行字节
  0000008A: EB 09              jmp         00000095  ; 首次直接检查外层条件
  0000008C: 8B 45 FC           mov         eax,dword ptr [ebp-4]  ; 读取 row
  0000008F: 83 E8 01           sub         eax,1  ; row - 1
  00000092: 89 45 FC           mov         dword ptr [ebp-4],eax  ; 写回 row
  00000095: 83 7D FC 01        cmp         dword ptr [ebp-4],1  ; 比较 row 与 1
  00000099: 72 38              jb          000000D3  ; 无符号 row < 1 时结束表格
  0000009B: C7 45 F8 01 00 00  mov         dword ptr [ebp-8],1  ; 每行开始时 col = 1，保存于 [EBP-8]
            00  ; 上一条机器指令的续行字节
  000000A2: EB 09              jmp         000000AD  ; 首次直接检查内层条件
  000000A4: 8B 4D F8           mov         ecx,dword ptr [ebp-8]  ; 读取 col
  000000A7: 83 C1 01           add         ecx,1  ; col + 1
  000000AA: 89 4D F8           mov         dword ptr [ebp-8],ecx  ; 写回 col
  000000AD: 8B 55 F8           mov         edx,dword ptr [ebp-8]  ; 读取 col
  000000B0: 3B 55 FC           cmp         edx,dword ptr [ebp-4]  ; 比较 col 与 row
  000000B3: 77 12              ja          000000C7  ; col > row 时结束当前行
  000000B5: 8B 45 F8           mov         eax,dword ptr [ebp-8]  ; 读取 col
  000000B8: 50                 push        eax  ; 先压入第二个参数 col
  000000B9: 8B 4D FC           mov         ecx,dword ptr [ebp-4]  ; 读取 row
  000000BC: 51                 push        ecx  ; 再压入第一个参数 row
  000000BD: E8 00 00 00 00     call        _print_cell  ; 调用 print_cell(row, col)
  000000C2: 83 C4 08           add         esp,8  ; 返回后回收两个参数，共 8 字节
  000000C5: EB DD              jmp         000000A4  ; 回到 ++col，继续内层循环
  000000C7: 6A 0A              push        0Ah  ; 压入换行符 LF（0Ah）
  000000C9: E8 00 00 00 00     call        _putchar  ; 调用 putchar 换行
  000000CE: 83 C4 04           add         esp,4  ; 回收一个参数
  000000D1: EB B9              jmp         0000008C  ; 回到 --row，继续外层循环
  000000D3: 8B E5              mov         esp,ebp  ; 释放局部变量空间
  000000D5: 5D                 pop         ebp  ; 恢复调用者 EBP
  000000D6: C3                 ret  ; 返回 main
```

外层通过 `SUB` 递减 row，在 row<1 时用无符号 `JB` 退出；内层通过 `ADD` 递增 col，在 col>row 时用 `JA` 退出。000000BD 处的 `CALL` 对应源码的 `print_cell(row,col)`，000000C2 处回收参数后继续循环。

## 3. main：调用与返回

```asm
_main:
  000000E0: 55                 push        ebp  ; main：保存 EBP
  000000E1: 8B EC              mov         ebp,esp  ; 建立 main 栈帧
  000000E3: E8 00 00 00 00     call        _print_table  ; 调用 print_table()
  000000E8: 33 C0              xor         eax,eax  ; EAX = 0，对应 return 0
  000000EA: 5D                 pop         ebp  ; 恢复 EBP
  000000EB: C3                 ret  ; 返回 C 运行库
```

main 调用 print_table，print_table 再多次调用 print_cell；各函数用 `RET` 返回到调用者的下一条指令。建立栈帧时保存 EBP、结束时恢复，确保上层函数仍能用自己的 EBP 定位局部变量。

## 4. 与手写汇编的寄存器保护对照

手写汇编的内层 `LOOP` 依赖 CX，而输出过程也使用 CX 计算补空格数量，因此过程必须显式保存并恢复 CX。C 版本的循环变量在栈帧中，编译器按调用约定管理它们；不能假设一次 C 函数调用后 EAX、ECX、EDX 仍不变。

本题汇编过程的约定是 AX、BX、CX、DX、SI 返回时保持原值，BP 和 DI 不修改，SP 平衡，FLAGS 不保证保持。实际对全部 45 组参数检查了这些寄存器及 SP，详见 [验证记录](VERIFY_REPORT.md)。

目标文件中的 `E8 00 00 00 00` 和字符串地址是链接前占位，实际调用目标已由符号和重定位记录确定，生成 EXE 时会填入相对位移或地址。它们不是运行时调用空地址。

修改 C 源码、编译器或选项后应重新运行 `BUILD_C.cmd`，并根据新的 `C_RAW.TXT` 核对本注释文件。
