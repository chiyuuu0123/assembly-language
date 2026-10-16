# 作业3：C 语言实际反汇编注释

使用本次 MSVC x86 编译生成的 `SUM_C.OBJ`，执行 DUMPBIN `/DISASM:BYTES` 得到 [C_RAW.TXT](C_RAW.TXT)。以下求和函数逐条注释；输入转换与主函数选取关键片段注释，省略部分均已标明，完整原始机器码保留在链接文件中。

编译选项为 `/Od /Oy- /GS- /MT`，关闭优化并保留栈帧。这里的地址为代码节内偏移，并非 EXE 运行时地址。C 版本使用 32 位 EAX、EBP、ESP，与 DOS 汇编版本的 16 位寄存器相对应。

## 1. sum_to_n：求和循环逐条注释

| 位置 | 含义 |
| --- | --- |
| `[EBP+8]` | 参数 n |
| `[EBP-8]` | 局部变量 total，32 位无符号数 |
| `[EBP-4]` | 局部变量 i，32 位无符号数 |
| EAX | 函数返回值 |

```asm
_sum_to_n:
  00000000: 55                 push        ebp  ; 保存调用者 EBP
  00000001: 8B EC              mov         ebp,esp  ; 建立当前栈帧
  00000003: 83 EC 08           sub         esp,8  ; 为 total、i 分配 8 字节
  00000006: C7 45 F8 00 00 00  mov         dword ptr [ebp-8],0  ; total = 0
            00  ; 上一条机器指令的续行字节
  0000000D: C7 45 FC 01 00 00  mov         dword ptr [ebp-4],1  ; i = 1
            00  ; 上一条机器指令的续行字节
  00000014: EB 09              jmp         0000001F  ; 首次直接检查 i <= n，不先执行 ++i
  00000016: 8B 45 FC           mov         eax,dword ptr [ebp-4]  ; 读取 i
  00000019: 83 C0 01           add         eax,1  ; i + 1
  0000001C: 89 45 FC           mov         dword ptr [ebp-4],eax  ; 写回 i
  0000001F: 8B 4D FC           mov         ecx,dword ptr [ebp-4]  ; 将 i 放入 ECX
  00000022: 3B 4D 08           cmp         ecx,dword ptr [ebp+8]  ; 比较 i 与参数 n（[EBP+8]）
  00000025: 77 0B              ja          00000032  ; 无符号 i > n 时结束循环
  00000027: 8B 55 F8           mov         edx,dword ptr [ebp-8]  ; 读取 total
  0000002A: 03 55 FC           add         edx,dword ptr [ebp-4]  ; total + i
  0000002D: 89 55 F8           mov         dword ptr [ebp-8],edx  ; 写回 total
  00000030: EB E4              jmp         00000016  ; 跳到 ++i，继续循环
  00000032: 8B 45 F8           mov         eax,dword ptr [ebp-8]  ; 返回值 total 放入 EAX
  00000035: 8B E5              mov         esp,ebp  ; 释放局部变量空间
  00000037: 5D                 pop         ebp  ; 恢复调用者 EBP
  00000038: C3                 ret  ; 返回；参数由调用者回收
```

`CMP i,n` 配合 `JA` 判断无符号的“大于”。i=n 时仍进入循环，保证把 n 加进去；i=n+1 时退出。`ADD` 和回跳体现源码中的逐项累加，5050 不是直接嵌入程序的输出常量。函数后的 CC 字节用于对齐，未列入正常执行过程。

## 2. parse_n：十进制输入转换与范围检查

参数 text、value 分别位于 `[EBP+8]`、`[EBP+0Ch]`，局部变量 n、count 分别位于 `[EBP-8]`、`[EBP-4]`。

```asm
_parse_n:
  0000007D: 83 7D FC 03        cmp         dword ptr [ebp-4],3  ; 检查已经读取的数字个数
  00000081: 74 1C              je          0000009F  ; 若已经三位且还有下一位，则转到非法分支
  00000083: 8B 45 08           mov         eax,dword ptr [ebp+8]  ; 读取 text 指针
  00000086: 03 45 FC           add         eax,dword ptr [ebp-4]  ; 计算 text + count
  00000089: 0F BE 08           movsx       ecx,byte ptr [eax]  ; 将当前 char 扩展为 int
  0000008C: 83 F9 30           cmp         ecx,30h  ; 与 ASCII '0'（30h）比较
  0000008F: 7C 0E              jl          0000009F  ; 小于 '0' 则非法
  00000091: 8B 55 08           mov         edx,dword ptr [ebp+8]  ; 再次读取 text 指针
  00000094: 03 55 FC           add         edx,dword ptr [ebp-4]  ; 定位当前字符
  00000097: 0F BE 02           movsx       eax,byte ptr [edx]  ; 读取当前字符并扩展为 int
  0000009A: 83 F8 39           cmp         eax,39h  ; 与 ASCII '9'（39h）比较
  0000009D: 7E 07              jle         000000A6  ; 小于等于 '9' 且已通过下界检查，转去转换
  0000009F: 33 C0              xor         eax,eax  ; 非法输入：返回值 EAX=0
  000000A1: E9 81 00 00 00     jmp         00000127  ; 跳到 parse_n 的函数收尾
  000000A6: 6B 4D F8 0A        imul        ecx,dword ptr [ebp-8],0Ah  ; ECX = n * 10
  000000AA: 8B 55 08           mov         edx,dword ptr [ebp+8]  ; 读取 text 指针
  000000AD: 03 55 FC           add         edx,dword ptr [ebp-4]  ; 定位当前字符
  000000B0: 0F BE 02           movsx       eax,byte ptr [edx]  ; 取得当前字符 ASCII 码
  000000B3: 8D 4C 01 D0        lea         ecx,[ecx+eax-30h]  ; ECX = n*10 + ASCII码 - '0'；LEA 在此用于算术，不读取内存
  000000B7: 89 4D F8           mov         dword ptr [ebp-8],ecx  ; 保存新的二进制 n
  000000BA: 8B 55 FC           mov         edx,dword ptr [ebp-4]  ; 读取 count
  000000BD: 83 C2 01           add         edx,1  ; count + 1
  000000C0: 89 55 FC           mov         dword ptr [ebp-4],edx  ; 写回 count
  000000C3: EB 8F              jmp         00000054  ; 返回字符读取与行尾判断处
  000000C5: 83 7D FC 00        cmp         dword ptr [ebp-4],0  ; 检查是否为空输入
  000000C9: 74 0C              je          000000D7  ; count=0 时转到非法分支
  000000CB: 83 7D F8 01        cmp         dword ptr [ebp-8],1  ; 比较 n 与 1
  000000CF: 72 06              jb          000000D7  ; 无符号 n<1 则非法
  000000D1: 83 7D F8 64        cmp         dword ptr [ebp-8],64h  ; 比较 n 与 100（64h）
  000000D5: 76 04              jbe         000000DB  ; n<=100 则进入后续行尾检查
  000000D7: 33 C0              xor         eax,eax  ; 范围不合法：EAX=0
  000000D9: EB 4C              jmp         00000127  ; 跳到函数收尾
  ; ... 后续检查可选 CR/LF 和字符串结束，详见 C_RAW.TXT ...
  0000011A: 8B 55 0C           mov         edx,dword ptr [ebp+0Ch]  ; 读取输出指针 value
  0000011D: 8B 45 F8           mov         eax,dword ptr [ebp-8]  ; 读取转换后的 n
  00000120: 89 02              mov         dword ptr [edx],eax  ; *value = n
  00000122: B8 01 00 00 00     mov         eax,1  ; 合法输入：EAX=1
  00000127: 8B E5              mov         esp,ebp  ; 回收栈帧
  00000129: 5D                 pop         ebp  ; 恢复 EBP
  0000012A: C3                 ret  ; 返回 parse_n 的成功/失败状态
```

关键算式是 `n = n*10 + (字符-'0')`。本次编译器使用 `IMUL` 乘 10，再用 `LEA` 合并加法与减 30h。转换完成后检查非空、n>=1、n<=100，合法值通过指针写回 main 的 n。

## 3. main：固定求和、输入校验与输出

本次 main 栈帧中，line 数组位于 `[EBP-88h]` 起，n 位于 `[EBP-8]`，ch 位于 `[EBP-4]`。下面保留两段实际指令：

```asm
_main:
  00000139: 6A 64              push        64h  ; 压入十进制 100（64h）作为 n 参数
  0000013B: E8 00 00 00 00     call        _sum_to_n  ; 调用 sum_to_n(100)，返回值在 EAX
  00000140: 83 C4 04           add         esp,4  ; 回收 4 字节参数
  00000143: 50                 push        eax  ; 压入计算出的固定和
  00000144: 68 00 00 00 00     push        offset $SG10577  ; 压入固定结果的 printf 格式字符串地址
  00000149: E8 00 00 00 00     call        _printf  ; printf 显示固定和 5050
  0000014E: 83 C4 08           add         esp,8  ; 回收两个参数共 8 字节
  ; ... 读入整行、检测 EOF 并清空超长输入，详见原始反汇编 ...
  000001EA: 8D 55 F8           lea         edx,[ebp-8]  ; 取得局部变量 n 的地址
  000001ED: 52                 push        edx  ; 压入 &n（第二个参数）
  000001EE: 8D 85 78 FF FF FF  lea         eax,[ebp-88h]  ; 取得 line 数组首地址
  000001F4: 50                 push        eax  ; 压入 line（第一个参数）
  000001F5: E8 00 00 00 00     call        _parse_n  ; 调用 parse_n(line, &n)
  000001FA: 83 C4 08           add         esp,8  ; 回收两个参数
  000001FD: 85 C0              test        eax,eax  ; 检查 parse_n 的返回值
  000001FF: 74 02              je          00000203  ; 返回 0 则跳到错误提示
  00000201: EB 12              jmp         00000215  ; 合法输入，跳到求和部分
  00000203: 68 00 00 00 00     push        offset $SG10583  ; 压入错误提示字符串地址
  00000208: E8 00 00 00 00     call        _puts  ; puts 显示错误提示
  0000020D: 83 C4 04           add         esp,4  ; 回收参数
  00000210: E9 3C FF FF FF     jmp         00000151  ; 回到输入提示处重新读取
  00000215: 8B 4D F8           mov         ecx,dword ptr [ebp-8]  ; 读取已验证的 n
  00000218: 51                 push        ecx  ; 压入 n
  00000219: E8 00 00 00 00     call        _sum_to_n  ; 调用 sum_to_n(n)
  0000021E: 83 C4 04           add         esp,4  ; 回收参数
  00000221: 50                 push        eax  ; 压入返回的求和结果
  00000222: 68 00 00 00 00     push        offset $SG10584  ; 压入 Result: %u 的格式字符串地址
  00000227: E8 00 00 00 00     call        _printf  ; printf 以无符号十进制输出
  0000022C: 83 C4 08           add         esp,8  ; 回收两个参数
  0000022F: 33 C0              xor         eax,eax  ; main 返回值设为 0
  00000231: 8B E5              mov         esp,ebp  ; 回收 main 的局部变量空间
  00000233: 5D                 pop         ebp  ; 恢复 EBP
  00000234: C3                 ret  ; main 返回
```

其余输入相关调用可在原始文件中按地址查找：

| 代码节偏移 | 调用或作用 |
| --- | --- |
| 00000180 | `fgets` 读取一行到 line，最多 127 个字符加终止零 |
| 0000019F | `strchr` 查找换行符 |
| 000001B6 | `feof` 判断输入是否到达文件末尾 |
| 000001C2 | `getchar` 丢弃超长输入的后续字符 |
| 000001F5 | `parse_n` 转换并验证 1～100 |
| 00000219 | `sum_to_n` 计算 1 到 n 的和 |
| 00000227 | `printf` 按 `%u` 显示无符号十进制结果 |

x86 C 调用在这里由调用者压参数，调用后用 `ADD ESP,...` 回收参数空间。EAX 保存返回值。`TEST EAX,EAX` 后的条件跳转用于判断输入校验是否成功。

## 4. 重定位与运行库

目标文件中的调用常显示为 `E8 00 00 00 00`，格式字符串地址也暂为零；对应符号与重定位类型见 [C_RELOC.TXT](C_RELOC.TXT)。链接器生成 EXE 时会填入正确地址或相对位移。不能把这些零占位解释为最终程序跳往空地址。

原始反汇编还包含 printf 等标准库的包装函数。求和、输入转换和重试逻辑位于本文件注释的三个用户函数中，完整运行库包装代码仍保留在 C_RAW.TXT 中供查阅。

修改 C 源码或编译选项后应重新运行 `BUILD_C.cmd`，并按新的真实反汇编更新本文件。已用实际执行验证 n=1～100 的全部结果，详见 [VERIFY_REPORT.md](VERIFY_REPORT.md)。
