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
LOG = "robo.log"
ROBOCOPY_OPTS = f"/MIR /W:0 /R:1 /MT:{THREADS} /FFT /XJD /NP /NDL /Z /ETA /LOG:{LOG}"


def main():
    """main"""
    with open('robocopy.bat', 'w') as robo:
        for dir in BACKUP_DIRS:
            base = os.path.basename(dir)
            dst = os.path.join(DEST_DIR, base)
            cmd = f"robocopy {ROBOCOPY_OPTS} \"{dir}\" \"{dst}\"\n"
            robo.write(cmd)
            print(cmd)


if __name__ == "__main__":
    main()
