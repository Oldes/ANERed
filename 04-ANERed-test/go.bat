@set PAUSE_ERRORS=1
call ..\setup.bat

@echo Building SWF file

java -Dsun.io.useCanonCaches=false -Xms32m -Xmx512m -Dflexlib="%AIR_SDK%\frameworks" -jar "%AIR_SDK%\lib\mxmlc-cli.jar" ^
	-load-config="%AIR_SDK%/frameworks/air-config.xml" -load-config+=TestConfig.xml +configname=air ^
	-optimize=true -debug=true -o AIR-Red.swf

	
@echo off
	
set BUILD_NAME=Build\AIR-Red

IF EXIST Build GOTO BUILD_DIR_EXISTS
	MKDIR Build
	GOTO BUILD_DIR_READY
:BUILD_DIR_EXISTS

IF NOT EXIST %BUILD_NAME% GOTO BUILD_DIR_READY
	echo Deleting old build...
	DEL /F /Q "%BUILD_NAME%"
:BUILD_DIR_READY

echo Packing new build...

set AIR_NOANDROIDFLAIR=true

@echo on
java -jar %AIR_SDK%\lib\adt.jar -package ^
	-storetype pkcs12 -keystore Test.p12 -storepass fd ^
	-target bundle %BUILD_NAME%  application.xml AIR-Red.swf libRed.dll icons/* ^
	-extdir ../03-ANERed-ane/

@echo off

DEL AIR-Red.swf

ECHO 

IF NOT EXIST  %BUILD_NAME% GOTO NOBUILD
	echo Build ready!
	GOTO INSTALL
:NOBUILD
	echo Build failed!
	@PAUSE
	GOTO END
:INSTALL

call Build\AIR-Red\AIR-Red.exe

:END
