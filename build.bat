@echo off

setlocal enabledelayedexpansion

set IMAGE=glove80-zmk-config-docker

:: Default to the pinned MoErgo v26.09 firmware.
if "%~1"=="" (
	set BRANCH=ce69e85f585c724142aae37ddf8a7e019ff19e93
) else (
	set BRANCH=%~1
)

:: Build Docker image
docker build -t "%IMAGE%" .

:: Run Docker container
docker run --rm -v "%cd%:/config" -e UID=0 -e GID=0 -e BRANCH="%BRANCH%" "%IMAGE%"

endlocal
