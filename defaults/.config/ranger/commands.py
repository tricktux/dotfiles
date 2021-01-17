# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You can import any python module as needed.
import os
import re
import subprocess

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import *


#  https://github.com/ask1234560/ranger-zjumper
class z(Command):
    """:z
    Uses .z file to set the current directory.
    """

    def execute(self):

        if self.arg(1):
            search_string = self.rest(1)
        else:
            self.fm.notify("Usage: z <search string>", bad=True)
            return

        # location of .z file
        z_loc = os.getenv("_Z_DATA") or os.getenv("HOME") + "/.local/share/z"
        with open(z_loc, "r") as fobj:
            flists = fobj.readlines()

        # user given directory
        req = re.compile(".*".join(self.args[1:]), re.IGNORECASE)
        directories = []
        for i in flists:
            if req.search(i):
                directories.append(i.split("|")[0])

        z_folder = os.path.abspath(min(directories, key=lambda x: len(x)))
        if os.path.isdir(z_folder):
            self.fm.cd(z_folder)
        else:
            self.fm.notify(f"Z: Directory ({z_folder}) not found", bad=True)


class fzf(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        if self.quantifier:
            # match only directories
            command = "fd --type directory --hidden --no-ignore-vcs \
                        --ignore-file /home/reinaldo/.config/ignore-file \
                        2>/dev/null | fzf +m"

        else:
            # match files and directories
            command = "fd --type file --hidden --follow \
                        --ignore-file /home/reinaldo/.config/ignore-file \
                        2>/dev/null | fzf +m"

        fzf = self.fm.execute_command(command,
                                      universal_newlines=True,
                                      stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


class rga(Command):
    """
    :rga
    Search in PDFs, E-Books and Office documents in current directory.
    Allowed extensions: .epub, .odt, .docx, .fb2, .ipynb, .pdf.

    Usage: rga <search string>
    """

    def execute(self):
        if self.arg(1):
            search_string = self.rest(1)
        else:
            self.fm.notify("Usage: rga <search string>", bad=True)
            return

        command = "rga '%s' . --rga-adapters=pandoc,poppler 2>/dev/null \
                        | fzf +m \
                        | awk -F':' '{print $1}'" % search_string
        fzf = self.fm.execute_command(command,
                                      universal_newlines=True,
                                      stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            #  self.fm.execute_file(File(fzf_file))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)
