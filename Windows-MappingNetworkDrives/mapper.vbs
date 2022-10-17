Set objShell = WScript.CreateObject("WScript.Shell")


objShell.Run "cmd /c net use w: /DELETE", 0, True
objShell.Run "cmd /c net use x: /DELETE", 0, True
objShell.Run "cmd /c net use y: /DELETE", 0, True
objShell.Run "cmd /c net use z: /DELETE", 0, True
objShell.Run "cmd /c net use w: \\s4-fsv-file-031\DRUKARKI_SKANERY", 0, True
objShell.Run "cmd /c net use x: \\s4-fsv-file-031\PRIV", 0, True
objShell.Run "cmd /c net use y: \\s4-fsv-file-031\PUB", 0, True
objShell.Run "cmd /c net use z: \\s4-fsv-file-031\EXT", 0, True
