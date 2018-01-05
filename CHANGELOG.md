# Change Log

## Master

## 0.3.0

#### Added
- added homebrew formula
- added automatic copying back of edited script from Xcode in `beak edit`
- added ability to simply run file as a script without specifying a function

#### Changed
- moved `--path` parameter before subcommands


[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.2.0...0.3.0)

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

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.1.0...0.2.0)

## 0.1.0
First official release
