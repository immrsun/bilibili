@echo off
setlocal enabledelayedexpansion

if "%1" equ "" (
	set base_path=.\
	set file_name=info.txt
) else (
	set base_path=%~dp1
	set file_name=%~nx1
)

echo message1:��Ƶ���·����%base_path:~0,-1%

rem ������ع����Ƿ�װ
you-get 1>nul 2>nul
if %errorlevel% neq 0 (
	echo û�а�װ you-get ��
	goto bat_end
)

rem �����Ƶ��Ϣ�ļ��Ƿ����
if not exist "%base_path%%file_name%" (
	echo warning1:����Ҫ���ص���Ƶ��Ϣ�ŵ��ļ� "%base_path%%file_name%" �
	goto bat_end
)
for /f "usebackq delims=" %%a in ("%base_path%%file_name%") do (
	set download_url=%%a
	goto break_for_url
)
:break_for_url

echo message2:��Ƶ��ַ��%download_url%

rem ͳ���ܹ�����Ƶ����
set /a video_num=0
for /f "usebackq skip=2 delims=" %%a in ("%base_path%%file_name%") do (
	set /a video_num+=1
)

echo message3:��Ƶ������%video_num%

rem ������Ƶ
echo message4:��ʼ������Ƶ
for /L %%i in (1 1 %video_num%) do (
	you-get -O "%base_path%%%i" "%download_url%?p=%%i"
)

rem ���������Ƶ�Ƿ���ȫ����
set /a check_count=0
:continue_check
if %check_count% geq 3 (
	echo warning2:���ع��̳��ִ���û��ȫ�����ء�
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

rem �������ļ�
set /a line_count=0
for /f "usebackq skip=2 delims=" %%a in ("%base_path%%file_name%") do (
	set /a line_count+=1
	for %%i in ("%base_path%!line_count!.*") do (
		rename "%%i" "%%a%%~xi"
	)
)

echo message5:count S%line_count% ����Ƶ�Ѿ����ص� "%base_path:~0,-1%"

:bat_end
pause