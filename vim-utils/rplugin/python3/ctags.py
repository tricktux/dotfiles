# File:ctags.py
# Description: Initializer for all my remote plugins
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Thu Mar 16 2017 16:35
# Created: Mar 15 2017 10:13

import os
import neovim


@neovim.plugin
class RemovePlugin(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.busy = 0

    @neovim.function('UpdateTagsRemote')
    def update_tags_remote(self, args):
        if self.busy != 0:
            return
        self.busy = 1

        DELETED_FILES = ( 'cscope.files', 'cscope.out', 'cscope.po.out', 'cscope.in.out', '.tags' )
        #  EXT = ('.c', '.cpp', '.java', '.cc', '.h', '.hpp')

        # TODO.RM-Thu Mar 16 2017 17:17: Put the tag in the cache folder along with the cscope
        lang = self.nvim_ft_to_ctags()
        if lang is None:
            self.nvim.command(':echomsg "Failed to retrieve &filetype"')
            self.busy = 0
            return

        CMD = 'ctags -R -L cscope.files -f .tags --sort=yes --c++-kinds=+pl --fields=+iaS \
                --extra=+q --language-force=%s' % lang

        #  Delete current connection if there is one
        self.nvim.command('silent! cs kill -1')

        # Silently delete files
        for files in DELETED_FILES:
            try:
                os.remove(files)
            except:
                pass

        # Populate list of source files
        #  list_files = open('cscope.files', 'w+')
        os.system('rg --files -t cpp . > cscope.files')
        if os.path.isfile('cscope.files') == False:
            self.nvim.command(':echomsg "Failed to create cscope.files"')
            self.busy = 0
            return

        # Silently try to create cscope files
        try:
            os.system('cscope -b -q -i cscope.files')
        except:
            pass

        # Check that cscope was created if so. Silently create tags
        if os.path.isfile('cscope.out'):
            try:
                os.system(CMD)
            except:
                pass
        else:
            self.nvim.command(':echomsg "Failed to create cscope.out"')
            self.busy = 0
            return

        # Add new database
        self.nvim.command('cs add cscope.out')
        self.busy = 0

    def nvim_ft_to_ctags(self):
        #  Determine for what language is the tags going to be
        lang = self.nvim.eval('&ft').lower().split('.')
        if lang is None:
            return []

        if lang[0] == 'cpp':
            lang[0] = 'C++'
        elif lang[0] == 'vim':
            lang[0] = 'Vim'
        elif lang[0] == 'python':
            lang[0] = 'Python'
        elif lang[0] == 'java':
            lang[0] = 'Java'
        else:
            return []

        #  Use for debugging        
        #  self.nvim.command(':echomsg "lang = %s"' %lang[0])
        return lang[0]
