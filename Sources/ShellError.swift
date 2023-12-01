/// Error type thrown by the `shell()` function, in case the given command failed
public struct ShellError: Swift.Error {
    public let code: Int32
    public let output: String
    public let error: String
}

public struct ShellTimeoutError: Swift.Error {
    public let message = "process was expired"
}
