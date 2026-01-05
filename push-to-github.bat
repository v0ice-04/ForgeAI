@echo off
echo Initializing Git repository...
git init

echo Adding remote repository...
git remote add origin https://github.com/v0ice-04/forgeai-backend.git

echo Staging all files...
git add .

echo Creating initial commit...
git commit -m "Initial commit: ForgeAI backend project"

echo Pushing to GitHub...
git push -u origin main

echo Done!
pause
