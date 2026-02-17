@echo off
cd frontend
echo "Cleaning project..."
call flutter clean
echo "Getting dependencies..."
call flutter pub get
echo "Analyzing code..."
call dart analyze
echo "Building project..."
call flutter build apk --debug
if %errorlevel% neq 0 (
    echo "Build failed!"
    exit /b %errorlevel%
)
echo "Build success!"
