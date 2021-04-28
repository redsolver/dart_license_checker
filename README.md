# Dart License Checker

Shows you which licenses your dependencies have.

```
┌───────────────────────────┐
│ Package Name  License     │
├───────────────────────────┤
│     barbecue  Apache 2.0  │
│         pana  BSD         │
│         path  BSD         │
│pubspec_parse  BSD         │
│         tint  MIT         │
└───────────────────────────┘
```

## Install

`flutter pub global activate dart_license_checker`

## Use

- Make sure you are in the main directory of your Flutter app or Dart program
- Execute `dart_license_checker`

If this doesn't work, you may need to set up your PATH (see https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

## Showing transitive dependencies

By default, `dart_license_checker` only shows immediate dependencies (the packages you list in your `pubspec.yaml`).

If you want to analyze transitive dependencies too, you can use the `--show-transitive-dependencies` flag:

`dart_license_checker --show-transitive-dependencies`
