# C 版 Fibonacci 实际反汇编

[C_RAW.TXT](C_RAW.TXT) 是对本次 MSVC x86 编译产生的 `FIB_C.OBJ` 执行 DUMPBIN 得到的原始反汇编；[C_RELOC.TXT](C_RELOC.TXT) 是重定位表。`BUILD_C.cmd` 以 `/Od /Oy-` 保留递归调用与栈帧。以下偏移属于目标文件，`CALL` 的零位移和数据符号的零地址由链接器填入，不能当作运行时地址。

## 递归、缓存与返回

```asm
00000000: push ebp                     ; 保存上一层的栈帧基址
00000001: mov ebp,esp
00000003: sub esp,0Ch                 ; 12 字节局部空间
00000006: mov dword ptr [ebp-0Ch],0    ; carry = 0
0000000D: mov eax,dword ptr [ebp+8]    ; n 是第一个栈参数
00000010: movzx ecx,byte ptr _known[eax]
00000017: test ecx,ecx
00000019: je 00000020                 ; 未命中，进入递归
0000001B: jmp 000000AE                ; 命中，直接走退出路径
00000020: mov edx,dword ptr [ebp+8]
00000023: sub edx,1
00000026: push edx
00000027: call _fib                   ; fib(n-1)
0000002C: add esp,4                   ; 调用者清理 n-1 参数
0000002F: mov eax,dword ptr [ebp+8]    ; 从本层栈帧取回原 n
00000032: sub eax,2
00000035: push eax
00000036: call _fib                   ; fib(n-2)
0000003B: add esp,4
; ...五字加法...
000000A4: mov eax,dword ptr [ebp+8]
000000A7: mov byte ptr _known[eax],1   ; 完整结果就绪后才置标志
000000AE: mov esp,ebp
000000B0: pop ebp
000000B1: ret
```

两个 `CALL` 的重定位字段（`00000028`、`00000037`）都指向 `_fib`，因此是实际递归。参数 `[EBP+8]` 属于本层，即使子调用覆盖 EAX 等临时寄存器也能重新读取。与手写 DOS 版不同，这里每层通过栈传参；`fib` 返回类型是 `void`，数值保存在 `_memo` 中。

当前 x86 目标的 `_fib` 每层占用 4 字节参数、4 字节返回地址、4 字节旧 EBP、12 字节局部空间，共 24 字节。按首次冷缓存路径 100 层计算，递归部分占约 2400 字节，不包含 main、C 运行库等；这不是 DOS 版的实测栈用量。

## 五字求和与进位

`[EBP-4]` 是循环下标，`[EBP-8]` 是当前字的 32 位临时和，`[EBP-0Ch]` 是进位。`00000050` 比较下标与 5；以下为读写各字的关键位置：

| 偏移 | 实际指令 | 含义 |
| --- | --- | --- |
| `0000005C` | `imul eax,edx,0Ah` | 将 n−1 换算成每项 10 字节的行偏移 |
| `00000062` | `movzx edx,word ptr _memo[eax+ecx*2]` | 读 F(n−1) 的第 i 个无符号字 |
| `00000076` | `movzx ecx,word ptr _memo[ecx+eax*2]` | 读 F(n−2) 的第 i 个无符号字 |
| `0000007E`、`00000081` | `add edx,dword ptr [ebp-0Ch]`；`add ecx,edx` | 相加并纳入上一字的进位 |
| `00000091` | `mov word ptr _memo[edx+eax*2],cx` | 只写回和的低 16 位 |
| `0000009C` | `shr edx,10h` | 右移 16 位，留下给下一字的进位 |
| `000000A2` | `jmp 00000047` | 回到循环下标递增处 |

`_print_decimal` 在 `000000D7` 调用 `memcpy` 复制 10 字节，`00000108` 将余数左移 16 位，`00000113` 将其与当前字合并；`00000122` 除以 10。逐字除法在工作副本上进行，缓存结果保留。
