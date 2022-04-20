@Echo OFF

:Main
: 1=:save_copy_to_directory

PushD "%~dp0"
Call set-system-autorun.bat > nul
SetLocal ENABLEDELAYEDEXPANSION
Set app=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe
Set shim=%PROFILE_DRIVE_PATH%\msedge.bat
Set compare=2
Set version=
Set link=
Call :get-download-info version link
If EXIST "%app%" Call compare-version-cli.bat "%version%" "%shim%" --version compare
If "%compare%"=="2" (
    TaskKill /IM msedge.exe /F > Nul 2>&1
    Call download-install-msi-setup.bat "%version%" "%link%" "" "%~f1" > Nul
)
If EXIST "%app%" (
    Call :write-to-profile "%app%"
    Call "%shim%" --version > auto-complete\msedge
)
EndLocal
PopD
GoTo :EOF

:get-download-info
    Call set-shim-path.bat ..\tools Jq
    For /F "Tokens=1* Delims=:, " %%E In ('^
        Curl https://edgeupdates.microsoft.com/api/products/stable -s ^|^
        Jq ".[0].Releases" ^|^
        Jq "map(select(.Platform==\"Windows\" and .Architecture==\"x64\"))" ^|^
        Jq ".[]" ^|^
        Jq "{"%~1": .ProductVersion, "%~2": .Artifacts[0].Location }"^
    ') Do (
        Set %%~E=%%~F
        Set %%~E=!%%~E:",=!
    )
    GoTo :EOF

:write-to-profile
    Set "wmicappname=%~f1"
    Set "wmicappname=%wmicappname:\=\\%"
    Set "wmicappname=%wmicappname:(=^^^(%"
    Set "wmicappname=%wmicappname:)=^^^)%"
    (
        Echo @Echo OFF
        Echo SetLocal
        Echo If Not "%%~1"=="--version" ^(
        Echo     If Not "%%~1"=="-V" ^(
        Echo         Start "" /D "%~dp1" "%~nx1" %%*
        Echo         GoTo :EOF
        Echo     ^)
        Echo ^)
        Echo For /F "Skip=1 Tokens=* Delims=." %%%%V In ^('"WMIC DATAFILE WHERE Name="%wmicappname%" GET Version"'^) Do ^(
        Echo     Echo %%%%V
        Echo     GoTo EndToLocal
        Echo ^)
        Echo :EndToLocal
        Echo EndLocal
    ) > "%shim%"
    Reg Add "HKCR\MSEdgePDF\shell\open\command" /VE /D "\"%~f1\" --app=\"%%1\"" /F /Reg:64 > Nul
    For %%T In (
        Core
        UA
    ) Do SchTasks /Change /TN MicrosoftEdgeUpdateTaskMachine%%T /Disable > Nul 2>&1
    GoTo :EOF