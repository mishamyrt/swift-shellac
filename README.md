<p align="center">
    <img src="./Assets/logo@2x.png" width="100px" />
</p>

# Shellac [![Quality Assurance](https://github.com/mishamyrt/swift-shellac/actions/workflows/qa.yaml/badge.svg)](https://github.com/mishamyrt/swift-shellac/actions/workflows/qa.yaml)

A library for easily running shell commands from Swift.

## Usage

run shell(), and specify what command you want to run:

```swift
let output = try shell(with: "echo", arguments: ["Hello world"])
print(output) // Hello world
```

## Installation

1. Add `.package(url: "https://github.com/mishamyrt/swift-shellac.git", from: "1.0.0")` to your Package.swift.
2. Update your packages using.
    ```sh
    swift package update
    ```

