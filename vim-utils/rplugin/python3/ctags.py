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
        #  Determine for what language is the tags going to be
        lang = self.nvim.eval('&ft').lower().split('.')
        if lang is None:
            self.nvim.command(':echomsg "Failed to retrieve &filetype"')
            self.busy = 0
            return []

        lang_ctags = self.nvim_ft_to_ctags(lang)
        if lang_ctags is None:
            self.nvim.command(':echomsg "Failed to retrieve ctags language"')
            self.busy = 0
            return

        CMD = 'ctags -R -L cscope.files -f .tags --sort=yes --c++-kinds=+pl --fields=+iaS \
                --extra=+q --language-force=%s' % lang_ctags

        #  Delete current connection if there is one
        self.nvim.command('silent! cs kill -1')

        # Silently delete files
        for files in DELETED_FILES:
            try:
                os.remove(files)
            except:
                pass

        lang_rg = self.nvim_ft_to_ctags(lang)
        if lang_rg is None:
            self.nvim.command(':echomsg "Failed to retrieve rg language"')
            self.busy = 0
            return

        # Populate list of source files
        # Previous method was slower but not dependent on rg
        os.system('rg --files -t %s . > cscope.files' % lang_rg)
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

    def nvim_ft_to_ctags(self, lang):
        if lang == 'cpp':
            lang = 'C++'
        elif lang == 'vim':
            lang = 'Vim'
        elif lang == 'python':
            lang = 'Python'
        elif lang == 'java':
            lang = 'Java'
        else:
            return []

        #  Use for debugging        
        #  self.nvim.command(':echomsg "lang = %s"' %lang
        return lang

    def nvim_ft_to_rg(self, lang):
        if lang == 'vim':
            lang = 'vimscript'
        elif lang == 'python':
            lang = 'py'
        else:
            return []

        return lang
