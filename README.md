# 汇编语言课程作业

使用 MASM 5.00、DOSBox 和 DEBUG 学习 8086 汇编语言。每次作业保存在一个独立分支，`main` 提供作业索引和公共环境说明。

| 作业 | 分支 | 内容 | 说明 |
| --- | --- | --- | --- |
| 作业1 | [homework-01](https://github.com/chiyuuu0123/assembly-language/tree/homework-01) | 搭建环境；常规方式及直接写内存方式运行 Hello world | [作业1说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-01/作业1说明.md) |
| 作业2 | [homework-02](https://github.com/chiyuuu0123/assembly-language/tree/homework-02) | LOOP 与条件跳转打印小写 ASCII 表；C 实现及反汇编注释 | [作业2说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-02/作业2说明.md) |
| 作业3 | [homework-03](https://github.com/chiyuuu0123/assembly-language/tree/homework-03) | 求和与十进制输出；寄存器、数据段、栈存储；输入 1～100；C 实现及反汇编注释 | [作业3说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-03/作业3说明.md) |
| 作业4 | [homework-04](https://github.com/chiyuuu0123/assembly-language/tree/homework-04) | 倒三角九九乘法表与 9×9 数据纠错；过程调用及 C 全局、局部数组反汇编对照 | [作业4说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-04/作业4说明.md) |
| 作业5 | [homework-05](https://github.com/chiyuuu0123/assembly-language/tree/homework-05) | 递归求斐波那契数；80 位存储、递归栈与 DEBUG 单步跟踪；C 反汇编 | [作业5说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-05/作业5说明.md) |

## 获取作业

```text
git clone https://github.com/chiyuuu0123/assembly-language.git
cd assembly-language
git switch homework-01
```

查看其他作业时使用对应的 `git switch homework-NN`，例如 `git switch homework-05`。各作业分支从 `main` 独立创建，保存该次作业的源代码、构建脚本、说明及运行记录。

## 运行环境

请先阅读 [环境配置说明](ENVIRONMENT.md)。仓库提供源码和脚本，第三方工具与构建后的可执行文件由本地环境提供。完成配置后，在对应分支双击对应的 `运行作业N.cmd`。

汇编作业在 DOSBox 中运行。作业2～5的 C 版本使用 MSVC 编译为 32 位 Windows 控制台程序，并提供实际目标文件的反汇编及中文注释。

## 后续作业约定

每次作业使用 `homework-NN` 分支，并在 `main` 更新索引。新增分支包含该次作业的题目说明、源码、运行方式和验证记录。

### 作业说明的写法

每次作业保留一份 `作业N说明.md`，从作业分支的 README 链接到它。说明至少包括：

- **题目与复现**：题目要求、运行方式、代表性输入输出和源码入口。
- **调试过程**：记录实际遇到的问题、如何定位、做了什么调整、如何验证；如没有遇到异常，就记下实际观察过的关键指令、寄存器或中间结果。把尚未执行的排查建议与实际过程分开。
- **验证记录**：写清覆盖了哪些样例、边界和错误输入，附上实际日志、单步记录或反汇编；未验证的内容不写成已通过。
- **学习复盘**：用具体例子说明本次掌握的知识点、最容易混淆的地方，以及下次可复用的调试方法。
