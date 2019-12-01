# Change Log

## Next Version
- Fixed edit command removing file attributes #46 @maxchuquimia

## 0.5.1

### Fixed:
- Fixed homebrew installations @yonaskolb

[Commits](https://github.com/yonaskolb/Beak/compare/0.5.0...0.5.1)

## 0.5.0

### Fixed:
- Fixed installation when building in Swift 5 #44 yonaskolb

### Changed:
- Updated to Swift 5 and dropped Swift 4.2 #44 @yonaskolb

[Commits](https://github.com/yonaskolb/Beak/compare/0.4.0...0.5.0)

## 0.4.0

### Added
- Added support for reading from input in beak files (stdin) #29 @jakeheis
- Added support for cancellation (SIGINT forwarding) #29 @jakeheis
- Added support for passing `nil` to optional parameters #29 @jakeheis
- Added Linux support #33 @yonaskolb

#### Fixed

- Fixed running on case sensitive file systems #27 @tflhyl
- Fixed homebrew installations #32 @yonaskolb

#### Changed
- Changed beak cache path from `~/Documents/beak/builds` to `~/.beak/builds` #30 @tflhyl

#### Internal
- Replaced `SwiftPM` and `SwiftShell` with `SwiftCLI` #29 @jakeheis
- Created seperate `BeakCLI` target #31 @yonaskolb

[Commits](https://github.com/yonaskolb/Beak/compare/0.3.5...0.4.0)

## 0.3.5

#### Fixed
- Fix parsed docs not matching to the correct functions in some cases #21

[Commits](https://github.com/yonaskolb/Beak/compare/0.3.4...0.3.5)

## 0.3.4

#### Fixed
- Fixed swift package manager dependency targeting so that `BeakCore` can be used as a dependency #19

#### Internal
- Updated PathKit, SWXMLHash, swift-package-manager, and SwiftShell

[Commits](https://github.com/yonaskolb/Beak/compare/0.3.3...0.3.4)

## 0.3.3

#### Fixed
- Fixed a installation issue due to a dependency on a Swift PM commit that no longer existed #17

[Commits](https://github.com/yonaskolb/Beak/compare/0.3.2...0.3.3)

## 0.3.2

#### Fixed
- Fixed the parsing of files with anonymous functions within the public functions #15

[Commits](https://github.com/yonaskolb/Beak/compare/0.3.1...0.3.2)

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
