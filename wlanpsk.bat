@echo off
netsh interface show interface name="Wireless Network Connection" | find /i "Disconnected" >nul && goto fail
goto start

:fail
echo ERROR: Wireless Local Network Connection [Disconnected]
echo Note: Turn on your wireless network connection!
goto end

:start
setlocal enabledelayedexpansion

:main
    call :get-profiles r

    :main-next-profile
        for /f "tokens=1* delims=," %%a in ("%r%") do (
            call :get-profile-key "%%a" key
            if "!key!" NEQ "" (
				echo.
                echo WAP: %%a
				echo PSK: !key!
            )
            set r=%%b
        )
        if "%r%" NEQ "" goto main-next-profile

		goto end

    goto :eof


:get-profile-key <1=profile-name> <2=out-profile-key>
    setlocal

    set result=

    FOR /F "usebackq tokens=2 delims=:" %%a in (
        `netsh wlan show profile name^="%~1" key^=clear ^| findstr /C:"Key Content"`) DO (
        set result=%%a
        set result=!result:~1!
    )
    (
        endlocal
        set %2=%result%
    )

    goto :eof

:get-profiles <1=result-variable>
    setlocal

    set result=

   
    FOR /F "usebackq tokens=2 delims=:" %%a in (
        `netsh wlan show profiles ^| findstr /C:"All User Profile"`) DO (
        set val=%%a
        set val=!val:~1!

        set result=%!val!,!result!
    )
    (
        endlocal
        set %1=%result:~0,-1%
    )

    goto :eof

exit

:end