name: vayu_app
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.10.1

dependencies:
  flutter:
    sdk: flutter

  # core / useful packages
  geolocator: ^14.0.2
  cupertino_icons: ^1.0.8
  dio: ^5.3.0
  fl_chart: ^0.68.0
  google_fonts: ^4.0.3
  shared_preferences: ^2.1.5
  animations: ^2.0.6
  flutter_svg: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true

  assets:
    - lib/assets/logo.jpeg
