:: Path to Flex SDK
call ..\setup.bat
@set PASS=none

:validation
@if not exist "%AIR_SDK%\bin" goto flexsdk
@goto succeed


:flexsdk
@echo.
@echo ERROR: incorrect path to Flex SDK
@echo.
@echo Looking for: %AIR_SDK%\bin
@echo.
@if %PAUSE_ERRORS%==1 pause
@exit

:succeed

call clean.bat

copy "..\01-ANERed-swc\org.redlang.Red.swc" src\assets

mkdir src\assets\swc-contents
pushd src\assets\swc-contents
JAR xf ..\org.redlang.Red.swc catalog.xml library.swf
popd

copy "..\02-ANERed-native\build\Release\ANERed.dll" src\assets\platform\Windows-x86
copy src\assets\swc-contents\library.swf src\assets\platform\Windows-x86

RD  /S /Q .\src\assets\swc-contents

@java -jar "%AIR_SDK%\lib\adt.jar" -package    ^
    -target ane ANERed.ane src\extension.xml	^
    -swc ..\01-ANERed-swc\org.redlang.Red.swc	^
    -platform Windows-x86                       ^
    -C src\assets\platform\Windows-x86 .


