# File:                 nvim-terminal-edit.py
# Description:          Script that allows you to open files in current nvim instance from `:terminal`
# Author:               Reinaldo Molina <rmolin88@gmail.com>
# Version:              0.0.0
# Last Modified: Jun 25 2017 13:17
# Created: Jun 25 2017 13:17
# Taken from: https://gist.githubusercontent.com/bfredl/e5b05193304a3340e29e998662ffff76/raw/0d864dc74359e8222d7f71cdd5dc3031d9c35f72/nvim-terminal-edit.py

#!/usr/bin/env python
"""Edit a file in the host nvim instance."""
from __future__ import print_function
import os
import sys

from neovim import attach

args = sys.argv[1:]
if not args:
    print("Usage: {} <filename> ...".format(sys.argv[0]))
    sys.exit(1)

addr = os.environ.get("NVIM_LISTEN_ADDRESS", None)
if not addr:
    os.execvp('nvim', args)

nvim = attach("socket", path=addr)


def _setup():
    nvim.input('<c-\\><c-n>')  # exit terminal mode
    chid = nvim.channel_id
    nvim.command('augroup EDIT')
    nvim.command('au BufEnter <buffer> call rpcnotify({0}, "n")'.format(chid))
    nvim.command('au BufEnter <buffer> startinsert'.format(chid))
    nvim.command('augroup END')
    nvim.vars['files_to_edit'] = args
    for x in args:
        nvim.command('exe "drop ".remove(g:files_to_edit, 0)')


def _exit(*args):
    nvim.vars['files_to_edit'] = None
    nvim.command('augroup EDIT')
    nvim.command('au!')
    nvim.command('augroup END')
    nvim.stop_loop()


nvim.run_loop(_exit, _exit, _setup)
