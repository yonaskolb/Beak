# Beak 🐦

[![SPM](https://img.shields.io/badge/Swift_PM-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Git Version](https://img.shields.io/github/release/yonaskolb/Beak.svg)](https://github.com/yonaskolb/Beak/releases)
[![Build Status](https://img.shields.io/travis/yonaskolb/Beak/master.svg?style=flat)](https://travis-ci.org/yonaskolb/Beak)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/yonaskolb/Mint/blob/master/LICENSE)

> Peck into your Swift files from the command line

Beak can take a standard Swift file and run any public global functions in it.
This is useful for scripting and for make-like files written in Swift.

An example script:

```swift
/// Releases the product
/// - Parameters:
///   - version: the version to release
public func release(version: String) {
	// implementation here
	print("version \(version) released!")
}

/// Installs the product
public func install() {
	// implementation here
	print("installed")
}
```

## How does it work?
Beak analyzes your Swift file via SourceKit and finds all public and global functions. It uses information about the parameter names, types and default values to build up a command line interface. It also uses the comment docs to build up descriptive help.

It also parses special comments so the script can pull in dependencies via the Swift Package Manager.

By default Beak looks for a file called `beak.swift` in your current directory, otherwise you can pass a path to a different swift file with `--path`

## Usage

List functions:

```sh
$ beak list
Functions:

  release: Releases the product
  install: Installs the product

```

Run a function:

```sh
$ beak run release --version 1.2.0
version 1.2.0 released
```

You can always use `--help` to get more information about a command or a function.

### Parameters
Any parameters without default values will be required. 

Param types of Int, Bool, and String are nativelly supported. All other types will be passed exactly as they are, so if the final string compiles you can pass in anything. For example an enum value`--buildType .debug`

### Dependencies
Sometimes it's useful to be able to pull in other Swift packages as dependencies to use in your script. This can be done by adding some special comments at the top of your file. It must take the form: 

```
// beak: {repo} {library} {library} ... @ {version}`
```
where items in `{}` are:

- **repo**: is the git repo where a Swift package resides. This can take a short form of `user/repo` or an extended form `https://github.com/user/repo.git`
- **library**: a space delimited list of libraries to include from this package. This defaults to the repo name, which is usually what you want.
- **version**: the version of this package to include. This can either be a simple version string, or any of the types allowed by the Swift Package Manager `Requirement` static members eg 
	- `branch:develop` or `.branch("develop")`
	- `revision:ab794ebb` or `.revision("ab794ebb")`
	- `exact:1.2.0` or `.exact("1.2.0")`
	- `.upToNextMajor(from: "1.2.0")`
	- `.upToNextMinor(from: "1.2.3")`

Some examples:

```
// beak: JohnSundell/ShellOut @ 2.0.0
// beak: kylef/PathKit @ branch:master
```

## License

Beak is licensed under the MIT license. See [LICENSE](LICENSE) for more info.
