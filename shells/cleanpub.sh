#!/usr/bin/env bash

1. The local dependency cache will be cleared.
2. Re-obtain dependencies from the Internet

cd ..
flutter clean
rm pubspec.lock
rm -rf build/
rm -rf .android/
rm -rf .ios/
rm -rf .idea/
find . -name '*.iml' -type f -delete
rm .flutter-plugins
rm .packages
rm -rf ~/.pub-cache/
flutter pub get
flutter create --org io.github.haphu4247


