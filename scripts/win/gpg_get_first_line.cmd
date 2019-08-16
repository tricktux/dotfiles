@ECHO OFF

SET COMMAND=gpg --decrypt %~1

FOR /F "delims=" %%A IN ('%COMMAND%') DO (
    SET TEMPVAR=%%A
    GOTO :Print
)

:Print
ECHO %TEMPVAR% | clip