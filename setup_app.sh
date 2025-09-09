flutter clean
flutter pub get

echo "Creating app icon"
dart run flutter_launcher_icons

echo "Creating splash screen"
dart run flutter_native_splash:create --path=flutter_native_splash.yaml

echo "Done!"

flutter pub run build_runner build