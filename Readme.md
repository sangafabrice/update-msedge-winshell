## **Update MS Edge browser with Windows Shell**
---
##### Author: Fabrice Sanga
<br/>

The `profile.init.bat` file :
```batfile
@Echo OFF
If %~1==autorun_parent Echo Path\To\Autorun\Profile\Folder
```
<br/>

The usage :
```batfile
Update-MSEdge [CopyToDirectory]
CopyToDirectory     The directory where to backup the installer
```

The command to return the version of msedge installed
```batfile
msedge [--version|-V]
```