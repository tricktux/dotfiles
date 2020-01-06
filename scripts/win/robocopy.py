import os
import subprocess

BACKUP_DIRS = [
    "C:\\Users\\h129522\\Documents\\apps",
    "C:\\Users\\H129522\\AppData\\Roaming\\gnupg",
    "C:\\Users\\H129522\\.password-store",
    "D:\\1.WINGS",
    "D:\\2.Office",
    "D:\\3.Other",
    "D:\\cdats",
    "D:\\wiki",
    "D:\\wings-dev",
]

DEST_DIR = "G:\\StationBackups\\reinaldo_laptop"
THREADS = 2
LOG = "%TEMP%\robo.log"
ROBOCOPY_OPTS = f"/MIR /W:0 /R:1 /MT:{THREADS} /FFT /XJD /NP /NDL /Z /ETA /LOG:{LOG}"
ROBOCOPY_EXE = "C:\Windows\System32\Robocopy.exe"

def main():
    """main"""

    for dir in BACKUP_DIRS:
        base = os.path.basename(dir)
        dst = os.path.join(DEST_DIR, base)
        cmd = f"{ROBOCOPY_EXE} {ROBOCOPY_OPTS} \"{dir}\" \"{dst}\"\n"
        print(f"Executing:\n\t{cmd}")
        #  subprocess.call(cmd.split())


if __name__ == "__main__":
    main()
