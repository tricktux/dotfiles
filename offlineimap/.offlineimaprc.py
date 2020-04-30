#! /usr/bin/env python2
from subprocess import check_output


def get_molinamail_pass():
    return check_output("pass linux/mailserver/me@molinamail.com", shell=True).splitlines()[0]

def get_gmail_pass():
    return check_output("pass websites/google.com/rmolin88/neomutt", shell=True).splitlines()[0]
