@echo off
echo Terminating the "npm start" process using its PID from ".pidfile"...
for /f %%p in (.pidfile) do taskkill /PID %%p /F
