"""Check actual DOS/C table output and assembly register-preservation tests."""
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent


def expected_table():
    lines = ["The 9mul9 table:"]
    for row in range(9, 0, -1):
        cells = [f"{row}*{col}={row * col}" for col in range(1, row + 1)]
        lines.append("".join(cell.ljust(9) for cell in cells[:-1]) + cells[-1])
    return ("\r\n".join(lines) + "\r\n").encode("ascii")


def main():
    assert (ROOT / "DONE.TXT").read_text().strip() == "DONE", "DOS verification did not finish"
    for filename in ("ASM.LOG", "TESTASM.LOG"):
        log = (ROOT / filename).read_text(encoding="ascii")
        assert "0 Warning Errors" in log and "0 Severe  Errors" in log, filename
    expected = expected_table()
    actual = (ROOT / "ASMOUT.TXT").read_bytes()
    assert actual == expected, actual
    output = subprocess.run([str(ROOT / "MUL9_C.EXE")], capture_output=True, check=True, timeout=5).stdout
    assert output == expected, output
    (ROOT / "COUT.TXT").write_bytes(output)
    for row, line in zip(range(9, 0, -1), actual.decode("ascii").splitlines()[1:]):
        cells = re.findall(r"(\d)\*(\d)=(\d+)", line)
        assert len(cells) == row
        for col, (left, right, product) in enumerate(cells, 1):
            assert (int(left), int(right), int(product)) == (row, col, row * col)
        assert not line.endswith(" ")
    assert len(re.findall(rb"\d\*\d=\d+", actual)) == 45
    register_output = (ROOT / "REGTEST.TXT").read_bytes()
    assert register_output == expected.split(b"\r\n", 1)[1] + b"Register and stack checks passed (45 cells).\r\n"
    report = """# 作业4实际验证记录

| 检查项 | 实际结果 |
| --- | --- |
| MASM 5.00 编译 | 主程序与寄存器检查程序均为 0 警告、0 错误，全部链接成功 |
| 表格方向 | 行号 9 到 1，每行列号 1 到行号 |
| 乘法结果 | 全部 45 个算式正确，最大乘积 81 |
| 格式 | 标题和 9 行表格；每列宽度 9，最后一列不补空格；CR/LF 换行 |
| DOS 与 C 输出 | 两者逐字节相同，均与独立生成的预期文本一致 |
| 过程的寄存器保护 | 对全部 45 组行列输入，逐次检查 AX、BX、CX、DX、SI、BP、DI 不变 |
| 栈平衡 | 对每一次 PRINT_CELL 调用，检查返回后的 SP 等于调用前 SP |
| 检查结果 | REGTEST 以状态 0 正常退出，输出 passed 提示 |

以上均来自本次实际构建和执行。`ASMOUT.TXT`、`COUT.TXT`、`REGTEST.TXT` 保留原始输出；`REGTEST.ASM` 为检查程序，使用与主程序相同的 `CELL.INC` 和 `PRINT.INC`。

复现：在 DOSBox 中运行 `VERIFY.BAT`，在 Windows 中运行 `BUILD_C.cmd`，最后在仓库根目录运行 `python HW4/CHECK.py`。全部检查通过后才生成此记录。
"""
    (ROOT / "VERIFY_REPORT.md").write_text(report, encoding="utf-8")
    print("PASS: 45 products; descending 9-row table; exact DOS/C output; register and SP preservation for all 45 calls.")


if __name__ == "__main__":
    main()
