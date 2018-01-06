# Change Log

## Master

## 0.3.1

#### Added
- Added shebang documentation `#!/usr/bin/env beak --path`

#### Fixed
- Fixed dependency declarations not being parsed if they didn't start on the first line, for example if you have a shebang

[Commits](https://github.com/yonaskolb/Beak/compare/0.3.0...0.3.1)

## 0.3.0

#### Added
- Added homebrew formula
- Added automatic copying back of edited script from Xcode in `beak edit`
- Added ability to simply run file as a script without specifying a function

#### Changed
- Moved `--path` parameter before subcommands

[Commits](https://github.com/yonaskolb/Beak/compare/0.2.0...0.3.0)

## 0.2.0

#### Added
- Unnamed params are now parsed to positional arguments
- Added `beak edit` command
- Added `beak --version`
- Added `release` to `beak.swift`

### Changed
- Improved error logging
- Show param defaults in `run --help`
- Removed unused dependencies
- Use dynamic argument lookup from Swift PM PR
- Don't write build files if unchanged

#### Fixed
- Fixed build path of beak files
- Fixed build errors when multiple dependency libraries are imported
- Fixed `install` beak function

[Commits](https://github.com/yonaskolb/Beak/compare/0.1.0...0.2.0)

## 0.1.0
First official release
