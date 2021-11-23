# -*- coding: utf-8 -*-
# This file is part of ranger, the console file manager.
# This configuration file is licensed under the same terms as ranger.
# ===================================================================
#
# NOTE: If you copied this file to /etc/ranger/commands_full.py or
# ~/.config/ranger/commands_full.py, then it will NOT be loaded by ranger,
# and only serve as a reference.
#
# ===================================================================
# This file contains ranger's commands.
# It's all in python; lines beginning with # are comments.
#
# Note that additional commands are automatically generated from the methods
# of the class ranger.core.actions.Actions.
#
# You can customize commands in the files /etc/ranger/commands.py (system-wide)
# and ~/.config/ranger/commands.py (per user).
# They have the same syntax as this file.  In fact, you can just copy this
# file to ~/.config/ranger/commands_full.py with
# `ranger --copy-config=commands_full' and make your modifications, don't
# forget to rename it to commands.py.  You can also use
# `ranger --copy-config=commands' to copy a short sample commands.py that
# has everything you need to get started.
# But make sure you update your configs when you update ranger.
#
# ===================================================================
# Every class defined here which is a subclass of `Command' will be used as a
# command in ranger.  Several methods are defined to interface with ranger:
#   execute():   called when the command is executed.
#   cancel():    called when closing the console.
#   tab(tabnum): called when <TAB> is pressed.
#   quick():     called after each keypress.
#
# tab() argument tabnum is 1 for <TAB> and -1 for <S-TAB> by default
#
# The return values for tab() can be either:
#   None: There is no tab completion
#   A string: Change the console to this string
#   A list/tuple/generator: cycle through every item in it
#
# The return value for quick() can be:
#   False: Nothing happens
#   True: Execute the command afterwards
#
# The return value for execute() and cancel() doesn't matter.
#
# ===================================================================
# Commands have certain attributes and methods that facilitate parsing of
# the arguments:
#
# self.line: The whole line that was written in the console.
# self.args: A list of all (space-separated) arguments to the command.
# self.quantifier: If this command was mapped to the key "X" and
#      the user pressed 6X, self.quantifier will be 6.
# self.arg(n): The n-th argument, or an empty string if it doesn't exist.
# self.rest(n): The n-th argument plus everything that followed.  For example,
#      if the command was "search foo bar a b c", rest(2) will be "bar a b c"
# self.start(n): Anything before the n-th argument.  For example, if the
#      command was "search foo bar a b c", start(2) will be "search foo"
#
# ===================================================================
# And this is a little reference for common ranger functions and objects:
#
# self.fm: A reference to the "fm" object which contains most information
#      about ranger.
# self.fm.notify(string): Print the given string on the screen.
# self.fm.notify(string, bad=True): Print the given string in RED.
# self.fm.reload_cwd(): Reload the current working directory.
# self.fm.thisdir: The current working directory. (A File object.)
# self.fm.thisfile: The current file. (A File object too.)
# self.fm.thistab.get_selection(): A list of all selected files.
# self.fm.execute_console(string): Execute the string as a ranger command.
# self.fm.open_console(string): Open the console with the given string
#      already typed in for you.
# self.fm.move(direction): Moves the cursor in the given direction, which
#      can be something like down=3, up=5, right=1, left=1, to=6, ...
#
# File objects (for example self.fm.thisfile) have these useful attributes and
# methods:
#
# tfile.path: The path to the file.
# tfile.basename: The base name only.
# tfile.load_content(): Force a loading of the directories content (which
#      obviously works with directories only)
# tfile.is_directory: True/False depending on whether it's a directory.
#
# For advanced commands it is unavoidable to dive a bit into the source code
# of ranger.
# ===================================================================

import os
import re
import subprocess

from ranger.api.commands import Command

#  https://github.com/ask1234560/ranger-zjumper
class z(Command):
    """:z
    Uses .z file to set the current directory.
    """

    def execute(self):

        if not self.arg(1):
            self.fm.notify("Usage: z <search string>", bad=True)
            return

        # location of .z file
        z_loc = os.getenv("_Z_DATA") or os.getenv("HOME") + "/.local/share/z"

        if not os.path.isfile(z_loc):
            self.fm.notify("Failed to find z database. Please set _Z_DATA", bad=True)
            return

        with open(z_loc, "r", encoding="utf-8") as fobj:
            flists = fobj.readlines()

        # user given directory
        req = re.compile(".*".join(self.args[1:]), re.IGNORECASE)
        directories = []
        for i in flists:
            if req.search(i):
                directories.append(i.split("|")[0])

        if not directories:
            self.fm.notify(f"Z: Search ({self.arg(1)}) not in database", bad=True)
            return

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
                        --ignore-file $HOME/.config/ignore-file \
                        2>/dev/null | fzf +m"

        else:
            # match files and directories
            command = "fd --type file --hidden --follow \
                        --ignore-file $HOME/.config/ignore-file \
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

