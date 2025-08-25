/^\s*- name: flutter pub get$/,/^\s*- name: Build APK \(release\)$/c\
      - name: flutter pub get\
        run: flutter pub get\
\
      - name: Flutter tests\
        run: flutter test --no-pub\
\
      - name: Build APK (release)\
        run: flutter build apk --release
