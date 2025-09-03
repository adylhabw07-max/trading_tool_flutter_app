# صورة Flutter الرسمية (مع JDK + Android SDK)
FROM mobiledevops/flutter-sdk-image:latest

# تثبيت الأدوات الإضافية
RUN yes | sdkmanager --licenses && \
    sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# تعيين مجلد العمل
WORKDIR /app

# نسخ مشروع Flutter
COPY . .

# تحميل الحزم
RUN flutter pub get

# تنظيف أي بقايا
RUN flutter clean

# أمر افتراضي (بناء APK Release)
CMD ["flutter", "build", "apk", "--release"]

