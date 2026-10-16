# 汇编语言课程作业

当前分支：**homework-02**。查看 [作业2完整说明](作业2说明.md) 和 [C 反汇编注释](HW2/C_反汇编注释.md)；配置环境后双击 `运行作业2.cmd`。

使用 MASM 5.00、DOSBox 和 DEBUG 学习 8086 汇编语言。每次作业保存在一个独立分支，`main` 提供作业索引和公共环境说明。

| 作业 | 分支 | 内容 | 说明 |
| --- | --- | --- | --- |
| 作业1 | [homework-01](https://github.com/chiyuuu0123/assembly-language/tree/homework-01) | 搭建环境；常规方式及直接写内存方式运行 Hello world | [作业1说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-01/作业1说明.md) |
| 作业2 | [homework-02](https://github.com/chiyuuu0123/assembly-language/tree/homework-02) | LOOP 与条件跳转打印小写 ASCII 表；C 实现及反汇编注释 | [作业2说明](https://github.com/chiyuuu0123/assembly-language/blob/homework-02/作业2说明.md) |

## 获取作业

```text
git clone https://github.com/chiyuuu0123/assembly-language.git
cd assembly-language
git switch homework-01
```

查看作业2时使用 `git switch homework-02`。各作业分支从 `main` 独立创建，保存该次作业的源代码、构建脚本、说明及运行记录。

## 运行环境

请先阅读 [环境配置说明](ENVIRONMENT.md)。仓库提供源码和脚本，第三方工具与构建后的可执行文件由本地环境提供。完成配置后，在对应分支双击 `运行作业1.cmd` 或 `运行作业2.cmd`。

两个汇编作业均在 DOSBox 中运行。作业2的 C 版本使用 MSVC 编译为 32 位 Windows 控制台程序，并提供实际目标文件的反汇编及中文注释。

## 后续作业约定

每次作业使用 `homework-NN` 分支，并在 `main` 更新索引。新增分支包含该次作业的题目说明、源码、运行方式和验证记录。
