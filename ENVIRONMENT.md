# 环境配置

## DOS 汇编环境

采用 DOSBox 0.74、MASM 5.00 和 LINK 3.60。作业1另使用 FreeDOS DEBUG 和 MASM 的 CREF 工具。

切换到作业分支后，将已有课程工具放到以下位置：

```text
仓库根目录/
  tools/
    DOSBox/
      DOSBox.exe
      SDL.dll
      SDL_net.dll
  HW1/                     # homework-01 分支
    MASM.EXE
    LINK.EXE
    CREF.EXE
    DEBUG.COM
  HW2/                     # homework-02 分支
    MASM.EXE
    LINK.EXE
  HW3/                     # homework-03 分支
    MASM.EXE
    LINK.EXE
```

`tools/DOSBox` 可直接使用本地 DOSBox 的完整安装目录。MASM、LINK 和 CREF 使用课程提供的文件。DEBUG 可使用 [FreeDOS 软件仓库中的 DEBUG](https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/repositories/latest/html/en/base/debug/20250316.0/index.html)。上述工具文件均在 Git 忽略范围内。

配置完成后，双击分支中的运行脚本。脚本将作业目录映射为 DOSBox 的 `C:`；也可先将 DOSBox 的当前工作目录设为对应的 `HW1`、`HW2` 或 `HW3` 目录，再输入：

```text
mount c .
c:
BUILD.BAT
```

作业1和作业2在 DOSBox 内输入 `VERIFY.BAT` 会重新编译、运行并生成验证记录，完成后自动关闭 DOSBox。作业3先在 Windows 中执行 `python HW3/CHECK.py prepare` 准备输入数据，再运行其 `VERIFY.BAT`；最后执行 `python HW3/CHECK.py check` 检查输出。

## 作业2和作业3的 C 环境

安装含“使用 C++ 的桌面开发”组件的 Visual Studio 2022 或其生成工具，使用 x86 MSVC 编译器。

`HW2/BUILD_C.cmd`、`HW3/BUILD_C.cmd` 会查找本地 Visual Studio 环境，也支持通过环境变量 `VCVARS32` 指定 `vcvars32.bat` 的完整路径。运行脚本后生成 Windows 可执行程序和反汇编记录。

```text
cd HW2
BUILD_C.cmd
```

作业3使用同样的方式运行 `HW3/BUILD_C.cmd`。编译关闭优化并保留栈帧，以便对照 C 源码阅读。`C_RAW.TXT` 是对实际 `ASCII_C.OBJ` 或 `SUM_C.OBJ` 执行 DUMPBIN 后的输出；`C_反汇编注释.md` 解释本次结果。修改源码或更换编译器后，需要同步核对反汇编注释。
