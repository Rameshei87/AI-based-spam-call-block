@echo off

REM Copyright (c) 2006, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM      http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.

if "%OS%"=="Windows_NT" @setlocal
if "%OS%"=="WINNT" @setlocal

rem %~dp0 is expanded pathname of the current script under NT
set ESB_HOME=%~dps0..

set _SYNAPSE_XML=
set _XDEBUG=
set _SERVER_NAME=

rem Slurp the command line arguments. This loop allows for an unlimited number
rem of arguments (up to the command line limit, anyway).

:setupArgs
if ""%1""=="""" goto doneStart
if ""%1""==""-sample"" goto esbSample
if ""%1""==""-xdebug"" goto xdebug
if ""%1""==""-serverName"" goto serverName
shift
goto setupArgs

rem is there is a -xdebug in the options
:xdebug


set _XDEBUG="wrapper.java.additional.7=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000"
shift
goto setupArgs

:esbSample
shift
set _SYNAPSE_XML=-Dsynapse.xml="%ESB_HOME%\repository\conf\sample\synapse_sample_%1.xml"
shift
goto setupArgs

:serverName
shift
set _SERVER_NAME=-DserverName=%1
shift
goto setupArgs

:doneStart
rem find ESB_HOME if it does not exist due to either an invalid value passed
rem by the user or the %0 problem on Windows 9x
if exist "%ESB_HOME%\README.TXT" goto checkJava

:noESBHome
echo ESB_HOME is set incorrectly or WSO2 ESB could not be located. Please set ESB_HOME.
goto end

:checkJava
set _JAVACMD=%JAVACMD%

if "%JAVA_HOME%" == "" goto noJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
if "%_JAVACMD%" == "" set _JAVACMD="%JAVA_HOME%\bin\java.exe"
goto runServer

:noJavaHome
if "%_JAVACMD%" == "" set _JAVACMD=java.exe
echo JAVA_HOME variable not defined or incorrect. Please set JAVA_HOME.

:runServer
@rem @echo on
cd %ESB_HOME%
echo "Starting WSO2 Enterprise Service Bus ..."
echo Using ESB_HOME:        %ESB_HOME%
echo Using JAVA_HOME:       %JAVA_HOME%
echo Using SYNAPSE_XML:     %_SYNAPSE_XML%

rem Decide on the wrapper binary.
set _WRAPPER_BASE=wrapper
set _WRAPPER_DIR=%ESB_HOME%\bin\native\
set _WRAPPER_EXE=%_WRAPPER_DIR%%_WRAPPER_BASE%-windows-x86-32.exe
if exist "%_WRAPPER_EXE%" goto conf
set _WRAPPER_EXE=%_WRAPPER_DIR%%_WRAPPER_BASE%-windows-x86-64.exe
if exist "%_WRAPPER_EXE%" goto conf
set _WRAPPER_EXE=%_WRAPPER_DIR%%_WRAPPER_BASE%.exe
if exist "%_WRAPPER_EXE%" goto conf
echo Unable to locate a Wrapper executable using any of the following names:
echo %_WRAPPER_DIR%%_WRAPPER_BASE%-windows-x86-32.exe
echo %_WRAPPER_DIR%%_WRAPPER_BASE%-windows-x86-64.exe
echo %_WRAPPER_DIR%%_WRAPPER_BASE%.exe
pause
goto :eof

rem
rem Find the wrapper.conf
rem
:conf
set _WRAPPER_CONF="%ESB_HOME%\webapp\WEB-INF\classes\conf\wrapper.conf"

rem
rem Start the Wrapper
rem
:startup
"%_WRAPPER_EXE%" -c %_WRAPPER_CONF% wrapper.java.additional.5=%_SYNAPSE_XML% wrapper.java.additional.6=%_SERVER_NAME% %_XDEBUG%

if not errorlevel 1 goto :eof
pause


:end
set _JAVACMD=
set ESB_CMD_LINE_ARGS=

if "%OS%"=="Windows_NT" @endlocal
if "%OS%"=="WINNT" @endlocal

:mainEnd
