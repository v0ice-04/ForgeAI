@echo off
cd /d c:\Users\Aryan\Downloads\forgeai-backend\backend
echo Starting application... > app.log
call mvnw.cmd spring-boot:run >> app.log 2>&1
