<p align="center">
    <img src="./Assets/logo@2x.png" width="100px" />
</p>

# Shellac [![Quality Assurance](https://github.com/mishamyrt/swift-shellac/actions/workflows/qa.yaml/badge.svg)](https://github.com/mishamyrt/swift-shellac/actions/workflows/qa.yaml)

A library for easily running shell commands from Swift. The library uses a custom method for determining process status and is protected against deadlocks that `waitUntilExit` can cause.

## Usage

run `shell()`, and specify what command you want to run:

```swift
let output = try shell(with: "echo", arguments: ["Hello world"])
print(output) // Hello world
```

### Series

To run a series of commands at once, optionally at a given path:

```swift
try shell(with: [
    "mkdir NewFolder",
    "echo \"Hello again\" > NewFolder/File"
], at: "~/CurrentFolder")
let output = try shell(with: "cat File", at: "~/CurrentFolder/NewFolder")
print(output) // Hello again
```

### Custom shell

By default, commands are executed in the bash environment. If you want to use a different shell, pass the path to the executable file to the `shellPath` parameter.

```swift
let shell = try shell(with: "echo $0", shellPath: "/bin/zsh")
print(shell) // /bin/zsh
```

### Timeout

To limit the command execution time, you must pass the time (in seconds) to the timeout parameter.
If this timeout is exceeded, the process will be killed with SIGKILL and the function will throw `ShellTimeoutError`.

```swift
do {
    try shell(with: "sleep 10", timeout: 1)
} catch _ as ShellTimeoutError {
    // Process will be terminated in 1 second
    // You can handle it in catch block
}
```

## Installation

1. Add `.package(url: "https://github.com/mishamyrt/swift-shellac.git", from: "1.0.0")` to your Package.swift dependencies.
2. Add `.product(name: "Shellac", package: "swift-shellac"),` to your target dependencies.
3. Update your packages using.
    ```sh
    swift package update
    ```

## Credits

The library is heavily inspired by [ShellOut](https://github.com/JohnSundell/ShellOut).
Thanks a lot to the author and the project participants.