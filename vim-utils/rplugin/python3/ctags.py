# File:ctags.py
# Description: Initializer for all my remote plugins
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Mar 15 2017 10:13
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
            #  print("UpdateTagsRemote() is busy")
            self.nvim.command(':echomsg "UpdateTagsRemote() is busy"')
            return

        self.busy = 1

        delete_files = [ 'cscope.files', 'cscope.out', 'cscope.po.out', 'cscope.in.out', '.tags' ]
        file_ext_tuple = ('.c', '.cpp', '.java', '.cc', '.h', '.hpp')
        ctags_cmd = 'ctags -R -L cscope.files -f .tags --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q --language-force=C++'

        #  Delete current connection if there is one
        self.nvim.command('silent! cs kill -1')

        # Silently delete files
        for files in delete_files:
            try:
                os.remove(files)
            except:
                pass

        # Populate list of source files
        #  list_files = open('cscope.files', 'w+')
        os.system('rg --files -t cpp . > cscope.files')
        #  for root, dirs, files in os.walk(os.getcwd()):
            #  for file in files:
                #  if file.endswith(file_ext_tuple):
                    #  list_files.write(os.path.join(root, file) + "\n")

        # Silently try to create cscope files
        try:
            os.system('cscope -b -q -i cscope.files')
        except:
            pass

        # Check that cscope was created if so. Silently create tags
        if os.path.isfile('cscope.out'):
            try:
                os.system(ctags_cmd)
            except:
                pass

        # Add new database
        self.nvim.command('cs add cscope.out')
        self.busy = 0

#  def _increment_calls(self):
    #  if self.calls == 5:
        #  raise Exception('Too many calls!')
            #  self.calls += 1

#  @neovim.command('Cmd', range='', nargs='*', sync=True)
#  def command_handler(self, args, range):
    #  self._increment_calls()
    #  self.nvim.current.line = (
        #  'Command: Called %d times, args: %s, range: %s' % (self.calls,
                                                           #  args,
                                                           #  range))

#  @neovim.autocmd('BufEnter', pattern='*.py', eval='expand("<afile>")',
                #  sync=True)
#  def autocmd_handler(self, filename):
    #  self._increment_calls()
    #  self.nvim.current.line = (
        #  'Autocmd: Called %s times, file: %s' % (self.calls, filename))

