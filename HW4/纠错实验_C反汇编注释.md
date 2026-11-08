# 实验二：C 反汇编与全局、局部数组对照

以下地址和指令来自本次 MSVC x86 `/Od /Oy- /GS- /MT` 编译后对 `FIX9_C.OBJ` 执行的实际反汇编。完整输出见 [FIX_RAW.TXT](FIX_RAW.TXT)，重定位见 [FIX_REL.TXT](FIX_REL.TXT)。这里的地址是代码节偏移；`CALL` 的零位移和全局符号的零地址是链接前占位。

## 全局数组：将 `.data` 中的符号地址作为参数

用 `DUMPBIN /SYMBOLS FIX9_C.OBJ` 检查，`_global_table` 和 `.data` 均属 `SECT3`。全局数组有静态存储期，题目数据由可执行文件的已初始化数据提供。调用 `check_global` 不需要逐项复制表格。

```asm
000000B0: push ebp                    ; 保存调用者栈帧
000000B1: mov ebp,esp
000000B3: push offset _global_table   ; 压入全局数组首地址
000000B8: call _check_table           ; 传地址，不传 81 个元素
000000BD: add esp,4                   ; 回收 4 字节指针参数
000000C0: pop ebp
000000C1: ret
```

`FIX_REL.TXT` 的 `000000B4 DIR32 ... _global_table` 指向 `push` 指令的地址操作数字段，链接器填入符号地址。

## 局部数组：在栈帧中构造表格，再传首地址

`local_table` 是自动局部数组。本次反汇编中 `sub esp,54h` 为栈帧留出 84 字节，其中 81 字节为表项；每次调用 `check_local` 都执行逐字节的初始化指令。

```asm
000000D0: push ebp
000000D1: mov ebp,esp
000000D3: sub esp,54h                     ; 分配栈帧空间
000000D6: mov byte ptr [ebp-54h],7        ; local_table[0][0]
000000DA: mov byte ptr [ebp-53h],2        ; local_table[0][1]
; ...中间 78 项初始化见原始反汇编...
00000216: mov byte ptr [ebp-4],51h        ; local_table[8][8]，81
0000021A: lea eax,[ebp-54h]               ; 计算数组首地址，不读取元素
0000021D: push eax
0000021E: call _check_table
00000223: add esp,4
00000226: mov esp,ebp                     ; 释放本次调用的局部空间
00000228: pop ebp
00000229: ret
```

两种方式都只把首地址传给检查过程。全局数组在整个程序运行期间存在，局部数组只在所属函数的这次调用期间有效。栈帧大小和逐字节 `MOV` 是本次编译结果，不是 C 语言规定的初始化方式。

## 共用检查过程：双重循环、下标寻址与错误分支

在 `_check_table` 中 `[EBP+8]` 为表首地址，`[EBP-8]` 为行号，`[EBP-4]` 为列号。外、内层边界分别在 `00000045`、`0000005D` 处与 9 比较，超界用 `JG` 跳出相应循环。

```asm
00000063: mov edx,dword ptr [ebp-8]       ; 读 row
00000066: sub edx,1                       ; 转成零基行下标
00000069: imul eax,edx,9                  ; 每行占 9 字节
0000006C: add eax,dword ptr [ebp+8]       ; 当前行首地址
0000006F: mov ecx,dword ptr [ebp-4]       ; 读 col
00000072: movzx edx,byte ptr [eax+ecx-1]  ; 读取无符号字节并零扩展
00000077: mov eax,dword ptr [ebp-8]
0000007A: imul eax,dword ptr [ebp-4]      ; 求正确值 row*col
0000007E: cmp edx,eax
00000080: je 00000092                     ; 相等时跳过报错
00000082: mov ecx,dword ptr [ebp-4]
00000085: push ecx                        ; 先压入 col
00000086: mov edx,dword ptr [ebp-8]
00000089: push edx                        ; 再压入 row
0000008A: call _report_error
0000008F: add esp,8                       ; 调用者回收两个参数
00000092: jmp 00000054                    ; 回到列递增处
```

`_report_error` 在 `00000010` 调用 `printf`，回收其三个参数后于 `00000019` 执行 `RET`。C 的循环变量保存在栈帧里；手写 8086 版把循环计数放在 CX，故 `REPORT_ERROR` 复用 CX 输出空格前要显式保护它。
