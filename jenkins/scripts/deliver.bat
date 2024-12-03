@echo off
echo Building your Node.js/React application...
npm run build

echo Starting your Node.js/React application in development mode...
start npm start
timeout /t 1 > nul
echo %ERRORLEVEL% > .pidfile

echo Visit http://localhost:3000 to see your Node.js/React application in action.
