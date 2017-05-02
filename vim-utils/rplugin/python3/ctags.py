# File:ctags.py
# Description: Initializer for all my remote plugins
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Fri Mar 17 2017 14:22
# Created: Mar 15 2017 10:13
#
# Dependencies:
#   - Relies on executing the script from the root folder of the code. Since it uses the folder name to create tag
#   name
#   - Neovim wont call this function if rg is not executable
#   - rg, ctags, cscope need to be executable
#   - ~/.cache must exist
# Note:
#   - The language for the tags generated is based on neovim's current buffer 'filetype'
#   - tags files are created at location ~/.cache and automatically added to 'tags'
#   - cscope.files and cscope.* are created at the project root

import os
import neovim


@neovim.plugin
class RemotePlugin(object):

    def __init__(self, nvim):
        self.nvim = nvim
        self.busy = 0
        self.deb = 1

    @neovim.function('UpdateTagsRemote')
    def update_tags_remote(self, args):
        if self.busy != 0:
            self.nvim.command(
                ':echomsg "Function currenlty busy. Please try again later."')
            return
        self.busy = 1

        DIR_NEOVIM_CWD = self.nvim.eval('getcwd()')
        DIR_NEOVIM_CWD = (DIR_NEOVIM_CWD.replace(os.path.sep, '/'))
        DIR_CTAGS_CACHE = (os.path.expanduser('~') + "/.cache/ctags/")
        if self.deb:
            deb_file = open(DIR_CTAGS_CACHE + "deb", "w+")
            deb_file.write("neovim_cwd = %s" % DIR_NEOVIM_CWD + "\n")
            deb_file.write("python_cwd = %s" % os.getcwd() + "\n")

        #  Determine for what language are the tags going to be
        lang_nvim = self.nvim.eval('&filetype')
        if not lang_nvim:
            self.nvim.command(':echomsg "Failed to retrieve &filetype"')
            self.busy = 0
            return

        lang_ctags = self.nvim_ft_to_ctags(lang_nvim)
        if not lang_ctags:
            self.nvim.command(
                ':echomsg "%s is not a supported language by ctags"' %
                lang_nvim)
            self.busy = 0
            return

        ctags_file_name = self.get_repo_root_folder_name(DIR_NEOVIM_CWD)
        if not ctags_file_name:
            self.nvim.command(':echomsg "Failed to create tags name"')
            self.busy = 0
            return

        #  Create tags in ~/.cache/tags_<repo_name>
        CSCOPE_FILES_NAME = (DIR_CTAGS_CACHE + "cscope.files")
        CSCOPE_OUT_FILE = (DIR_CTAGS_CACHE + "cscope.out")
        CTAGS_FILE_NAME = (DIR_CTAGS_CACHE + "tags_" + ctags_file_name)
        os.chdir(DIR_NEOVIM_CWD)
        if self.deb:
            deb_file.write("new python_cwd = %s" % os.getcwd() + "\n")

        CMD_CTAGS = (
            "ctags -L cscope.files -f %s --sort=no --c-kinds=+p --c++-kinds=+p --fields=+l"
            " --extras=+q --language-force=%s" % (CTAGS_FILE_NAME, lang_ctags))
        #  " --extras=+q" % CTAGS_FILE_NAME)

        if self.deb:
            deb_file.write("ctags_cmd = %s" % CMD_CTAGS + "\n")

        #  Translate vim filetype to something ripgrep can understand
        lang_rg = self.nvim_ft_to_rg(lang_nvim)
        if not lang_rg:
            self.nvim.command(':echomsg "Failed to retrieve rg language"')
            self.busy = 0
            return

        #  TODO.RM-Fri Mar 17 2017 15:20: Make this CMD_RG a nvim g: variable so that its no so hardcoded to rg
        #  TODO.RM-Fri Mar 17 2017 16:38: Replace all \ in DIR_NEOVIM_CWD with /
        for ch in DIR_NEOVIM_CWD:
            if ch == '\\':
                ch = '/'
        CMD_RG = ("rg -t %s --files %s > %s" % (lang_rg, DIR_NEOVIM_CWD,
                                                CSCOPE_FILES_NAME))

        if self.deb:
            deb_file.write("rg_cmd = %s" % CMD_RG + "\n")

        try:  # Populate list of source files
            os.system(CMD_RG)
        except:
            pass

        try:  # Check that cscope was created
            file_size = os.path.getsize(CSCOPE_FILES_NAME)
        except:
            file_size = 0

        if file_size == 0:
            self.nvim.command(':echomsg "Failed to create cscope.files"')
            self.busy = 0
            return

        try:  # Silently create tags
            os.system(CMD_CTAGS)
        except:
            pass

        #  Add recently created tag to 'tags' if not present already
        tagfiles = self.nvim.eval('&tags').split(",")
        if ctags_file_name not in tagfiles:
            self.nvim.command('set tags+=%s' % CTAGS_FILE_NAME)

        if lang_nvim != 'cpp' and lang_nvim != 'c':  # Only create cscope db for c/cpp files
            self.busy = 0
            return

        # Silently try to create cscope files
        os.chdir(DIR_CTAGS_CACHE)
        if self.deb:
            deb_file.write("new python_cwd = %s" % os.getcwd() + "\n")

        FILES_DELETE = ('cscope.out', 'cscope.po.out', 'cscope.in.out')
        for files in FILES_DELETE:  # Before creating new files delete old ones
            try:
                os.remove(files)
            except:
                pass

        try:
            os.system('cscope -b -q')
        except:
            pass

        #  if os.path.isfile('cscope.out'):
        if not os.path.isfile(DIR_CTAGS_CACHE + "/cscope.out"):
            self.nvim.command(':echomsg "Failed to create cscope.out"')
            self.busy = 0
            return

        #  Delete current connection if there is one
        self.nvim.command('silent! cs kill -1')

        # Add new database
        self.nvim.command('cs add %s' % CSCOPE_OUT_FILE)
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
        elif lang == 'c':
            lang = 'C'
        else:
            return
        return lang

    def nvim_ft_to_rg(self, lang):
        if lang == 'vim':
            lang = 'vimscript'
        elif lang == 'python':
            lang = 'py'

        return lang

    def get_repo_root_folder_name(self, curr_dir):
        #  Strip path to get only root folder name
        back_slash_index = curr_dir.rfind('/')
        if back_slash_index == -1:
            back_slash_index = curr_dir.rfind('\\')

        if back_slash_index == -1:
            return

        #  curr_dir = "tags_" + curr_dir
        return curr_dir[back_slash_index + 1:]
