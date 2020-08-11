@echo off
setlocal enabledelayedexpansion

if "%1" equ "" (
	set base_path=.\
	set file_name=info.txt
) else (
	set base_path=%~dp1
	set file_name=%~nx1
)

echo message1:视频存放路径：%base_path:~0,-1%

rem 检测下载工具是否安装
you-get 1>nul 2>nul
if %errorlevel% neq 0 (
	echo 没有安装 you-get 。
	goto bat_end
)

rem 检测视频信息文件是否存在
if not exist "%base_path%%file_name%" (
	echo warning1:将需要下载的视频信息放到文件 "%base_path%%file_name%" 里。
	goto bat_end
)
for /f "usebackq delims=" %%a in ("%base_path%%file_name%") do (
	set download_url=%%a
	goto break_for_url
)
:break_for_url

echo message2:视频地址：%download_url%

rem 统计总共的视频数量
set /a video_num=0
for /f "usebackq skip=2 delims=" %%a in ("%base_path%%file_name%") do (
	set /a video_num+=1
)

echo message3:视频数量：%video_num%

rem 下载视频
echo message4:开始下载视频
for /L %%i in (1 1 %video_num%) do (
	you-get -O "%base_path%%%i" "%download_url%?p=%%i"
)

rem 检查所有视频是否完全下载
set /a check_count=0
:continue_check
if %check_count% geq 3 (
	echo warning2:下载过程出现错误，没有全部下载。
	goto bat_end
)
"%base_path%check.txt"
for /L %%i in (1 1 %video_num%) do (
	set video_exist=false
	for %%j in ("%base_path%%%i.*") do (
		set video_exist=true
	)
	if "!video_exist!" equ "false" (
		echo %%i>>"%base_path%check.txt"
	)
)
set check_download=false
for /f "usebackq" %%a in ("%base_path%check.txt") do (
	you-get -O "%base_path%%%a" "%download_url%/#page=%%a"
	set check_download=true
)
set /a check_count+=1
if "%check_download%" equ "true" (
	goto continue_check
)
del "%base_path%check.txt"

rem 重命名文件
set /a line_count=0
for /f "usebackq skip=2 delims=" %%a in ("%base_path%%file_name%") do (
	set /a line_count+=1
	for %%i in ("%base_path%!line_count!.*") do (
		rename "%%i" "%%a%%~xi"
	)
)

echo message5:count S%line_count% 个视频已经下载到 "%base_path:~0,-1%"

:bat_end
pause