@echo off
chcp 65001 > nul
echo ===================================================
echo     كاشف AI - تشغيل وبناء تطبيق الأندرويد للهاتف
echo ===================================================
echo.

echo [1/3] تثبيت حزم Capacitor للأندرويد...
call npm install @capacitor/core @capacitor/cli @capacitor/android

echo.
echo [2/3] بناء المشروع ومزامنة ملفات الأندرويد...
call npm run build
call npx cap add android 2>nul
call npx cap sync

echo.
echo [3/3] فتح المشروع في أندرويد ستوديو (Android Studio)...
call npx cap open android

echo.
echo تم بنجاح! من داخل Android Studio اضغط على:
echo Build -^> Build Bundle(s) / APK(s) -^> Build APK(s)
pause
