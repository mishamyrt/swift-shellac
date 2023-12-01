import Foundation

/// Shell process
public class ShellProcess {
    /// Process stdout handle
    public let outputHandle: FileHandle?
    /// Process stderr handle
    public let errorHandle: FileHandle?

    private let process: Process
    private let timeInterval: TimeInterval?
    private var deadline: Date?
    private var isExpired: Bool {
        guard let deadline else {
            return false
        }
        return deadline.timeIntervalSinceNow < 0
    }

    init(
        with command: String,
        at path: String = ".",
        shellPath: String = "/bin/bash",
        timeout: TimeInterval? = nil,
        outputHandle outputFileHandle: FileHandle? = nil,
        errorHandle errorFileHandle: FileHandle? = nil
    ) {
        self.timeInterval = timeout
        outputHandle = outputFileHandle
        errorHandle = errorFileHandle
        // Set command
        process = Process()
        process.launchPath = shellPath
        process.arguments = ["-c", formatCommand(path, command)]
    }

    private func formatCommand(_ path: String, _ command: String) -> String {
        "cd \(path.replacingOccurrences(of: " ", with: "\\ ")) && \(command)"
    }

    /// Poll until process completes
    public func waitUntilExit() {
        if !process.isRunning {
            return
        }
        while true {
            if !send(signal: .check) {
                return
            }
            if isExpired {
                send(signal: .kill)
                continue
            }
            Thread.sleep(forTimeInterval: 0.01)
        }
    }

    /// Poll until process completes or throw `ShellTimeoutError` if timeout
    public func waitUntilExitOrTimeout() throws {
        waitUntilExit()
        if isExpired {
            throw ShellTimeoutError()
        }
    }

    /// Create and launch process
    public func launch() {
        process.launch()
        guard let timeInterval else {
            return
        }
        deadline = Date().advanced(by: timeInterval)
    }

    /// Start process
    public func run() throws -> String {
        var outputData = Data()
        var errorData = Data()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        let outputQueue = DispatchQueue(label: "shell-output-queue")

        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                outputData.append(data)
                self.outputHandle?.write(data)
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                errorData.append(data)
                self.errorHandle?.write(data)
            }
        }

        launch()
        waitUntilExit()

        if let handle = outputHandle, !handle.isStandard {
            handle.closeFile()
        }
        if let handle = errorHandle, !handle.isStandard {
            handle.closeFile()
        }
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil

        if isExpired {
            throw ShellTimeoutError()
        }
        if process.terminationStatus != 0 {
            throw ShellError(
                code: process.terminationStatus,
                output: outputData.describe(),
                error: errorData.describe()
            )
        }
        return outputData.describe()
    }

    @discardableResult
    private func send(signal: ProcessSignal) -> Bool {
        kill(pid: process.processIdentifier, by: signal)
    }
}

/// Run a shell command using selected shell
/// - Parameters:
///   - command: The commands to run
///   - path: The path to execute the command at (defaults to current folder)
///   - shellPath: The shell executable path (defaults to bash)
///   - arguments: The arguments to pass to the command
///   - timeout: Maximum command execution time after which the process will be terminated
///   - outputHandle: `FileHandle` that output (STDOUT) should be redirected to
///   - errorHandle: `FileHandle` that errors (STDERR) should be redirected to
/// - Throws:
///   - `ShellTimeoutError` if timeout was reached
///   - `ShellError` if process was exited with non-zero code
@discardableResult
public func shell(
    with command: String,
    at path: String = ".",
    arguments: [String] = [],
    shellPath: String = "/bin/bash",
    timeout: TimeInterval? = nil,
    outputHandle: FileHandle? = nil,
    errorHandle: FileHandle? = nil
) throws -> String {
    var finalCommand = command
    if !arguments.isEmpty {
        finalCommand += " " + arguments.joined(separator: " ")
    }
    let process = ShellProcess(
        with: finalCommand,
        at: path,
        shellPath: shellPath,
        timeout: timeout,
        outputHandle: outputHandle,
        errorHandle: errorHandle
    )
    return try process.run()
}

/// Run a series of shell commands using selected shell
/// - Parameters:
///   - commands: The commands to run in a series
///   - path: The path to execute the commands at (defaults to current folder)
///   - shellPath: The shell executable path (defaults to bash)
///   - timeout: Maximum command execution time after which the process will be terminated
///   - outputHandle: `FileHandle` that output (STDOUT) should be redirected to
///   - errorHandle: `FileHandle` that errors (STDERR) should be redirected to
/// - Throws:
///   - `ShellTimeoutError` if timeout was reached
///   - `ShellError` if process was exited with non-zero code
@discardableResult
public func shell(
    with commands: [String],
    at path: String = ".",
    shellPath: String = "/bin/bash",
    timeout: TimeInterval? = nil,
    outputHandle: FileHandle? = nil,
    errorHandle: FileHandle? = nil
) throws -> String {
    try shell(
        with: commands.joined(separator: " && "),
        at: path,
        shellPath: shellPath,
        timeout: timeout,
        outputHandle: outputHandle,
        errorHandle: errorHandle
    )
}
