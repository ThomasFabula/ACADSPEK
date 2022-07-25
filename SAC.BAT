echo=off
cls
type spektrum.txt
pause
rem Simulationsprogrammaufruf
as
rem Konvertierungsprogramm
sacad
rem ACAD-Austauschdatei ins ACAD-Directory kopieren
copy spektrum.dxf c:\cad
cd c:\cad
rem Autocad aufrufen
acad spektrum
rem zurÅck ins Spektrum Directory
cd c:\turbo\graphix
echo=on
