# Beak 🐦

[![SPM](https://img.shields.io/badge/Swift_PM-compatible-brightgreen.svg?style=for-the-badge)](https://swift.org/package-manager)
![Linux](https://img.shields.io/badge/Platforms-macOS_Linux-blue.svg?style=for-the-badge)
[![Git Version](https://img.shields.io/github/release/yonaskolb/Beak.svg?style=for-the-badge)](https://github.com/yonaskolb/Beak/releases)
[![Build Status](https://img.shields.io/circleci/project/github/yonaskolb/Beak.svg?style=for-the-badge)](https://circleci.com/gh/yonaskolb/Beak)
[![license](https://img.shields.io/github/license/yonaskolb/Beak.svg?style=for-the-badge)](https://github.com/yonaskolb/Beak/blob/master/LICENSE)

*Peck into your Swift files from the command line*

Beak can take a standard Swift file and then list and run any public global functions in it via a command line interface.

This is useful for scripting and for make-like files written in Swift. You can replace `make` or `rake` files with code written in Swift!

An example Swift script:

```swift
import Foundation

/// Releases the product
/// - Parameters:
///   - version: the version to release
public func release(version: String) throws {
    // implementation here
    print("version \(version) released!")
}

/// Installs the product
public func install() throws {
    // implementation here
    print("installed")
}
```
```sh
$ beak list
    release: Releases the product
    install: Installs the product
$ beak run release --version 1.2.0
  version 1.2.0 released!
```

## How does it work?
Beak analyzes your Swift file via SourceKit and finds all public and global functions. It uses information about the function and parameter names, types and default values to build up a command line interface. It also uses standard comment docs to build up descriptive help.

Beak can parse special comments at the top of your script so it can pull in dependencies via the Swift Package Manager.

By default Beak looks for a file called `beak.swift` in your current directory, otherwise you can pass a path to a different swift file with `--path`.
This repo itself has a Beak file for running build scripts.

## Installing
Make sure Xcode 9+ is installed first.

### [Mint](https://github.com/yonaskolb/mint) 🌱
```sh
$ mint install yonaskolb/beak
```

### Homebrew

```
$ brew tap yonaskolb/Beak https://github.com/yonaskolb/Beak.git
$ brew install Beak
```

### Swift PM and Beak 🐦
This uses Swift PM to build and run **beak** from this repo, which then runs the `install` function inside the `Beak.swift` file also incuded in this repo. So meta!

```sh
$ git clone https://github.com/yonaskolb/Beak.git
$ cd Beak
$ swift run beak run install
```

## Usage

#### List functions:

This shows all the functions that can be run

```sh
$ beak list

  release: Releases the product
  install: Installs the product

```

#### Run a function:
This runs a specific function with parameters.
Note that any top level expressions in the swift file will also be run before this function.

```sh
$ beak run release --version 1.2.0
version 1.2.0 released
```

#### Run the swift file
It's also possible to just run the whole script instead of a specific function

```sh
$ beak run
```

#### Edit the swift file
This generates and opens an Xcode project with all dependencies linked, which is useful for code completion if you have defined any dependencies.
The command line will prompt you to type `c` to commit any changes you made in Xcode back to the original file

```sh
$ beak edit
generating project
```

You can always use `--help` to get more information about a command or a function. This will use information from the doc comments.

### Functions
For function to be accessible they must be global and declared public. Any non-public functions can be as helper functions, but won't be seen by Beak.

Functions can be throwing, with any errors thrown printed using `CustomStringConvertible`. This makes it easy to fail your tasks. For now you must include an `import Foundation` in your script to have throwing functions

### Parameters
Any parameters without default values will be required.

Param types of `Int`, `Bool`, and `String` are natively supported. All other types will be passed exactly as they are as raw values, so if it compiles you can pass in anything, for example an enum value`--buildType .debug`.

Function parameters without labels will can be used with positional arguments:

```swift
public func release(_ version: String) { }
```
```sh
beak run release 1.2.0
```

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
// beak: kylef/PathKit @ upToNextMajor:0.9.0
// beak: apple/swift-package-manager Utility @ branch:master

import Foundation
import Pathkit
import Shellout
import Utility
```

You can use `beak edit` to get code completion for these imported dependencies.

## Shebang
If you put a beak shebang at the top of your swift file and then run `chmod a+x beak.swift` on it to make it executable, you will be able to execute it directly without calling beak.

**tasks.swift**

```swift
#!/usr/bin/env beak --path

public func foo() {
    print("hello foo")
}

public func bar() {
    print("hello bar")
}
```

```sh
$ chmod a+x tasks.swift
$ ./tasks.swift run foo
  hello foo
```

If you then place this file into `usr/local/bin` you could run this file from anywhere:

```
$ cp tasks.swift /usr/local/bin/tasks
$ tasks run bar
  hello bar
```

To automatically insert the `run` option, you can change your shebang to `#!/usr/bin/env beak run --path`. 

## Alternatives

* [swift sh](https://github.com/mxcl/swift-sh)
* [Marathon](https://github.com/JohnSundell/Marathon)

## License

Beak is licensed under the MIT license. See [LICENSE](LICENSE) for more info.
