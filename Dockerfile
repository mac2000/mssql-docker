FROM microsoft/windowsservercore

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# https://github.com/Microsoft/mssql-docker/blob/master/windows/mssql-server-windows/dockerfile
RUN Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=840944" -OutFile C:\SQL.box
RUN Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=840945" -OutFile C:\SQL.exe
RUN Start-Process -Wait -FilePath C:\SQL.exe -ArgumentList /qs, /x:setup
RUN C:\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine,FullText /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\System' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' 'user manager\containeradministrator' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS /SQLCOLLATION=Cyrillic_General_CI_AS /SECURITYMODE=SQL /SAPWD='P@ssword' /BROWSERSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT='NT AUTHORITY\System'
RUN Restart-Service MSSQLSERVER
RUN Invoke-SqlCmd -Query 'ALTER LOGIN sa with password=''rabota'' UNLOCK, CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF'
RUN Invoke-SqlCmd -Query 'EXEC SP_CONFIGURE ''show advanced options'',1; RECONFIGURE; EXEC SP_CONFIGURE ''Agent XPs'',1;RECONFIGURE'
RUN mkdir "'C:\Microsoft SQL Server\Data'"
RUN mkdir "'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data'"
RUN Stop-Service MSSQLSERVER

HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]
EXPOSE 1433
CMD ["powershell", "-c", "Start-Service MSSQLSERVER; while ($true) { Get-EventLog -LogName Application -Source 'MSSQL*' -After (Get-Date).AddSeconds(-5) | Select-Object TimeGenerated, EntryType, Message | Format-List; Start-Sleep -Seconds 5 }"]
