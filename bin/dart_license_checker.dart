import 'dart:convert';
import 'dart:io';

import 'package:pana/pana.dart';
import 'package:path/path.dart';
import 'package:barbecue/barbecue.dart';
import 'package:tint/tint.dart';

const possibleLicenseFileNames = [
  // LICENSE
  'LICENSE',
  'LICENSE.md',
  'license',
  'license.md',
  'License',
  'License.md',
  // LICENCE
  'LICENCE',
  'LICENCE.md',
  'licence',
  'licence.md',
  'Licence',
  'Licence.md',
  // COPYING
  'COPYING',
  'COPYING.md',
  'copying',
  'copying.md',
  'Copying',
  'Copying.md',
  // UNLICENSE
  'UNLICENSE',
  'UNLICENSE.md',
  'unlicense',
  'unlicense.md',
  'Unlicense',
  'Unlicense.md',
];

void main(List<String> arguments) async {
  final showTransitiveDependencies =
      arguments.contains('--show-transitive-dependencies');
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml file not found in current directory'.red());
    exit(1);
  }

  final pubspec = Pubspec.parseYaml(pubspecFile.readAsStringSync());

  final packageConfigFile = File('.dart_tool/package_config.json');

  if (!pubspecFile.existsSync()) {
    stderr.writeln(
        '.dart_tool/package_config.json file not found in current directory. You may need to run "flutter pub get" or "pub get"'
            .red());
    exit(1);
  }

  print('Checking dependencies...'.blue());

  final packageConfig = json.decode(packageConfigFile.readAsStringSync());

  final rows = <Row>[];

  for (final package in packageConfig['packages']) {
    final name = package['name'];

    if (!showTransitiveDependencies) {
      if (!pubspec.dependencies.containsKey(name)) {
        continue;
      }
    }

    String rootUri = package['rootUri'];
    if (rootUri.startsWith('file://')) {
      if (Platform.isWindows) {
        rootUri = rootUri.substring(8);
      } else {
        rootUri = rootUri.substring(7);
      }
    }

    LicenseFile license;

    for (final fileName in possibleLicenseFileNames) {
      final file = File(join(rootUri, fileName));
      if (file.existsSync()) {
        license = await detectLicenseInFile(file);
        break;
      }
    }

    if (license != null) {
      rows.add(Row(cells: [
        Cell(name, style: CellStyle(alignment: TextAlignment.TopRight)),
        Cell(formatLicenseName(license)),
      ]));
    } else {
      rows.add(Row(cells: [
        Cell(name, style: CellStyle(alignment: TextAlignment.TopRight)),
        Cell('No license file'.grey()),
      ]));
    }
  }
  print(
    Table(
      tableStyle: TableStyle(border: true),
      header: TableSection(
        rows: [
          Row(
            cells: [
              Cell(
                'Package Name  '.bold(),
                style: CellStyle(alignment: TextAlignment.TopRight),
              ),
              Cell('License'.bold()),
            ],
            cellStyle: CellStyle(borderBottom: true),
          ),
        ],
      ),
      body: TableSection(
        cellStyle: CellStyle(paddingRight: 2),
        rows: rows,
      ),
    ).render(),
  );

  exit(0);
}

String formatLicenseName(LicenseFile license) {
  if (license.name == 'unknown') {
    return license.name.red();
  } else if (copyleftOrProprietaryLicenses.contains(license.name)) {
    return license.shortFormatted.red();
  } else if (permissiveLicenses.contains(license.name)) {
    return license.shortFormatted.green();
  } else {
    return license.shortFormatted.yellow();
  }
}

// TODO LGPL, AGPL, MPL

const permissiveLicenses = [
  'MIT',
  'BSD',
  'Apache',
  'Unlicense',
];

const copyleftOrProprietaryLicenses = [
  'GPL',
];
