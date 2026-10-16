# 作业3实际验证记录

所有结果均来自本次实际编译与执行，未用固定字符串代替求和计算。

| 检查项 | 结果 |
| --- | --- |
| 四个 DOS 汇编程序 | MASM 5.00：0 警告、0 错误；全部链接成功 |
| 寄存器、数据段、栈三个固定求和版本 | 输出逐字节等于 `5050` + CR/LF |
| DOS 交互版本，n = 1…100 | 100 个输入全部与 n(n+1)/2 的独立校验值一致 |
| Windows C 版本，n = 1…100 | 100 个输入全部与独立校验值一致 |
| DOS/C 非法输入后重试 | 0、101、-1、abc、空行、1000、1a、前导空格、尾随空格、000 全部拒绝；随后输入 100 输出 5050 |
| DOS/C 前导零 | 001 接受为 1，输出 1 |
| C 超长输入 | 200 位数字整行拒绝并清空，随后输入 100 输出 5050 |

复现顺序：先运行 `python HW3/CHECK.py prepare`，在 DOSBox 中运行 `VERIFY.BAT`，在 Windows 中运行 `HW3/BUILD_C.cmd`，最后执行 `python HW3/CHECK.py check`。

`REG.TXT`、`DATA.TXT`、`STACK.TXT`、`INPUT.TXT`、`INVALID.TXT`、`CRESULT.TXT`、`CINVALID.TXT` 保留代表性输出；100 组中间输入和输出存放在本地 `TESTS` 目录，不随仓库提交。
