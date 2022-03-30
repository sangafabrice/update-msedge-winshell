@Echo OFF

:Main
: 1=:saved_package_path
: 2:=updated_link
: ERRORLEVEL:=is_link_updated

Call is-file-path-absolute.bat "%~1" || GoTo :EOF
MkDir "%~dp1" 2> Nul
If EXIST "%~f1" Set %~2=%~f1