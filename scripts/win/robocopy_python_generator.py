import os
import subprocess

USER_PROFILE = os.getenv("USERPROFILE")

BACKUP_DIRS = [
    rf"{USER_PROFILE}\Documents\apps",
    rf"{USER_PROFILE}\AppData\Roaming\gnupg",
    rf"{USER_PROFILE}\AppData\Roaming\doublecmd",
    rf"{USER_PROFILE}\.password-store",
    r"C:\Program Files (x86)\Borland",
    r"D:\1.WINGS",
    r"D:\2.Office",
    r"D:\3.Other",
    r"D:\cdats",
    r"D:\wiki",
    # r"D:\wings-dev",
    # r"D:\Mission.ATPs",
]

DRIVE = 'G'
DEST_DIR = fr'{DRIVE}:\StationBackups\reinaldo_laptop'
THREADS = 16
LOG = r"%TEMP%\robo.log"
ROBOCOPY_OPTS = f"/MIR /W:0 /R:1 /MT:{THREADS} /FFT /XJD /NP /NDL /ETA /E"
ROBOCOPY_EXE = r"C:\Windows\System32\Robocopy.exe"


def main():
    """main"""

    for d in BACKUP_DIRS:
        if not os.path.isdir(d):
            print(f"NOTE: Directory '{d}' does not exist. Skipping...")
            continue
        base = os.path.basename(d)
        dst = os.path.join(DEST_DIR, base)
        cmd = f'{ROBOCOPY_EXE} "{d}" "{dst}" {ROBOCOPY_OPTS}'
        print(f"Executing:\n\t{cmd}...")
        with subprocess.Popen(cmd) as proc:
            proc.wait()


if __name__ == "__main__":
    main()
