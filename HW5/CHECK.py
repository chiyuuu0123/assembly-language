"""Prepare DOS inputs and compare both implementations to a Python reference."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
TESTS = ROOT / "TESTS"
INVALID = ("", "0", "101", "-1", "abc", "1a", "1000", " 1", "1 ")


def prepare():
    TESTS.mkdir(exist_ok=True)
    (ROOT / "DONE.TXT").unlink(missing_ok=True)
    for path in TESTS.glob("*.OUT"):
        path.unlink()
    commands = ["@echo off"]
    for n in range(1, 101):
        stem = f"N{n:03}"
        (TESTS / f"{stem}.IN").write_bytes(f"{n}\r".encode("ascii"))
        commands.append(f"FIBRUN < TESTS\\{stem}.IN > TESTS\\{stem}.OUT")
    (TESTS / "BAD.IN").write_bytes(("\r".join(INVALID) + "\r100\r").encode("ascii"))
    commands.extend([
        "FIBRUN < TESTS\\BAD.IN > TESTS\\BAD.OUT",
        "DEBUG TRACE.EXE < STEPS.TXT > TRACE.LOG",
        "echo DONE > DONE.TXT",
        "exit",
    ])
    (ROOT / "RUNTEST.BAT").write_bytes(("\r\n".join(commands) + "\r\n").encode("ascii"))


def run_c(text):
    run = subprocess.run([str(ROOT / "FIB_C.EXE")], input=text.encode("ascii"),
                         capture_output=True, check=True, timeout=5)
    assert not run.stderr, run.stderr
    return run.stdout


def result(output, expected):
    assert re.findall(rb"Result: (\d+)", output) == [str(expected).encode("ascii")], output


def check_trace():
    log = (ROOT / "TRACE.LOG").read_text(encoding="ascii")
    states = re.findall(
        r"SP=([0-9A-F]{4})[^\n]*\n[^\n]*\n[0-9A-F]+:[0-9A-F]+\s+\S+\s+([A-Z]+)", log,
    )
    sp = [int(value, 16) for value, _ in states]
    assert sp[0] == sp[-1] == 0x800 and min(sp) == 0x7F2
    changes = {"CALL": -2, "RET": 2, "PUSH": -2, "POP": 2}
    for op, count in (("CALL", 7), ("RET", 7), ("PUSH", 3), ("POP", 3)):
        positions = [i for i, (_, instruction) in enumerate(states) if instruction == op]
        assert len(positions) == count, op
        assert all(sp[i + 1] - sp[i] == changes[op] for i in positions), op
    assert "Program terminated normally (0000)" in log


def check():
    assert (ROOT / "DONE.TXT").read_text().strip() == "DONE", "DOS tests did not finish"
    for name in ("ASM.LOG", "TRCASM.LOG"):
        log = (ROOT / name).read_text(encoding="ascii")
        assert "0 Warning Errors" in log and "0 Severe  Errors" in log, name
    prev, current = 0, 1
    for n in range(1, 101):
        dos = (TESTS / f"N{n:03}.OUT").read_bytes()
        result(dos, current)
        assert re.findall(rb"Recursion stack bytes: (\d+)", dos) == [str(4*n-2).encode("ascii")], dos
        result(run_c(f"{n}\n"), current)
        prev, current = current, prev + current
    dos_bad = (TESTS / "BAD.OUT").read_bytes()
    c_bad = run_c("\n".join(INVALID) + "\n100\n")
    for output in (dos_bad, c_bad):
        assert output.count(b"Invalid input.") == len(INVALID), output
        result(output, prev)
    # DOS echoes the input CR before FIBRUN adds CR/LF; normalize the sample.
    (ROOT / "DOS100.TXT").write_bytes((TESTS / "N100.OUT").read_bytes().replace(b"\r\r\n", b"\r\n"))
    (ROOT / "C100.TXT").write_bytes(run_c("100\n"))
    check_trace()
    print("PASS: all 100 DOS/C inputs, invalid-input recovery, stack peaks and DEBUG single-step transitions.")


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in ("prepare", "check"):
        raise SystemExit("Usage: python CHECK.py prepare|check")
    {"prepare": prepare, "check": check}[sys.argv[1]]()
