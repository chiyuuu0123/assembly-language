"""Prepare DOS inputs and verify actual DOS/C executions (Python stdlib only)."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
TESTS = ROOT / "TESTS"
INVALID = ("0", "101", "-1", "abc", "", "1000", "1a", " 1", "1 ", "000")


def prepare():
    TESTS.mkdir(exist_ok=True)
    for path in TESTS.glob("*.OUT"):
        path.unlink()
    for name in ("DONE.TXT", "BUILD.OK"):
        (ROOT / name).unlink(missing_ok=True)
    commands = ["@echo off", "SUM_REG > REG.TXT", "SUM_DATA > DATA.TXT", "SUM_STK > STACK.TXT"]
    for n in range(1, 101):
        stem = f"N{n:03}"
        (TESTS / f"{stem}.IN").write_bytes(f"{n}\r".encode("ascii"))
        commands.append(f"SUM_IN < TESTS\\{stem}.IN > TESTS\\{stem}.OUT")
    (TESTS / "BAD.IN").write_bytes(("\r".join(INVALID) + "\r100\r").encode("ascii"))
    (TESTS / "ZERO.IN").write_bytes(b"001\r")
    commands += [
        "SUM_IN < TESTS\\BAD.IN > TESTS\\BAD.OUT",
        "SUM_IN < TESTS\\ZERO.IN > TESTS\\ZERO.OUT",
        "copy TESTS\\N100.OUT INPUT.TXT > NUL",
        "copy TESTS\\BAD.OUT INVALID.TXT > NUL",
        "echo DONE > DONE.TXT",
        "exit",
    ]
    (ROOT / "RUNTEST.BAT").write_bytes(("\r\n".join(commands) + "\r\n").encode("ascii"))
    print("Prepared 100 valid DOS inputs, 10 invalid entries, and a leading-zero case.")


def check_result(output, expected):
    results = re.findall(rb"Result: (\d+)", output)
    assert results == [str(expected).encode("ascii")], (expected, output)


def run_c(text):
    completed = subprocess.run(
        [str(ROOT / "SUM_C.EXE")], input=text.encode("ascii"),
        capture_output=True, timeout=5, check=True,
    )
    assert b"1 + ... + 100 = 5050" in completed.stdout
    return completed.stdout


def check():
    assert (ROOT / "DONE.TXT").read_text().strip() == "DONE", "DOS tests did not finish"
    for name in ("REG.TXT", "DATA.TXT", "STACK.TXT"):
        assert (ROOT / name).read_bytes() == b"5050\r\n", name
    for name in ("REGASM.LOG", "DATAASM.LOG", "STKASM.LOG", "INASM.LOG"):
        log = (ROOT / name).read_text(encoding="ascii")
        assert "0 Warning Errors" in log and "0 Severe  Errors" in log, name
    for n in range(1, 101):
        expected = n * (n + 1) // 2
        check_result((TESTS / f"N{n:03}.OUT").read_bytes(), expected)
        check_result(run_c(f"{n}\n"), expected)
    bad = (TESTS / "BAD.OUT").read_bytes()
    check_result(bad, 5050)
    assert bad.count(b"Invalid input.") == len(INVALID), bad
    c_bad = run_c("\n".join(INVALID) + "\n100\n")
    check_result(c_bad, 5050)
    assert c_bad.count(b"Invalid input.") == len(INVALID), c_bad
    check_result((TESTS / "ZERO.OUT").read_bytes(), 1)
    check_result(run_c("001\n"), 1)
    long_c = run_c("9" * 200 + "\n100\n")
    check_result(long_c, 5050)
    assert long_c.count(b"Invalid input.") == 1
    (ROOT / "CRESULT.TXT").write_bytes(run_c("100\n"))
    (ROOT / "CINVALID.TXT").write_bytes(c_bad)
    report = """# 作业3实际验证记录

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
"""
    (ROOT / "VERIFY_REPORT.md").write_text(report, encoding="utf-8")
    print("PASS: 3 fixed sums, 100 DOS inputs, 100 C inputs, invalid-input recovery and leading zeros.")


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in ("prepare", "check"):
        raise SystemExit("Usage: python CHECK.py prepare|check")
    {"prepare": prepare, "check": check}[sys.argv[1]]()
