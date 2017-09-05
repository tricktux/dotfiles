# File:ctags.py
# Description: Python script that creates tags and cscope.out based on the input path
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last Modified: Mar 14 2017 20:09

# This line is used so that it can be called from command line without python infront
#!/usr/bin/env python

import os
import glob

def DeleteOldFiles():
    print('Deleting old files')
    try:
        os.remove('cscope.files')
        os.remove('cscope.out')
        os.remove('cscope.po.out')
        os.remove('cscope.in.out')
        os.remove('.tags')
    except:
        pass

def DisplayAllFiles():
    print ('Displaying files')
    #  src_files = glob.glob('./**/*\.\(c\|cpp\|java\|cc\|h\|hpp\)', recursive=True)
    src_files = glob.glob('\.\(c\|cpp\|java\|cc\|h\|hpp\)', recursive=True)
    #  src_files = glob.glob('./**/', recursive=True)
    for src in src_files:
        print(src)

if __name__ == '__main__':
    print ('Hello World')
    DeleteOldFiles()
    DisplayAllFiles()
