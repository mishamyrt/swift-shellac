import Darwin.C

@_silgen_name("kill")
private func system_kill(_ pid: Int32, _ signal: Int32) -> Int32

// swiftlint:disable sorted_enum_cases
enum ProcessSignal: Int32 {
    case check = 0
    /// Hangup
    case hangup = 1
    /// Interrupt
    case interrupt = 2
    /// Quit
    case quit = 3
    /// Illegal instruction
    case illegal = 4
    /// Trace trap
    case trace = 5
    /// Abort (core dumped)
    case abort = 6
    /// Bus error
    case bus = 7
    /// Floating-point exception
    case floatingPoint = 8
    /// Kill
    case kill = 9
    /// User-defined signal 1
    case user1 = 10
    /// Segmentation fault
    case segmentation = 11
    /// User-defined signal 2
    case user2 = 12
    /// Broken pipe
    case brokenPipe = 13
    /// Alarm clock
    case alarm = 14
    /// Termination
    case termination = 15
    /// Stack fault
    case stackFault = 16
    /// Child exited
    case childExited = 17
    /// Continue
    case continueSig = 18
    /// Stop (cannot be caught or ignored)
    case stop = 19
    /// Terminal stop
    case terminalStop = 20
    /// Background process trying to read from terminal
    case backgroundRead = 21
    /// Background process trying to write to terminal
    case backgroundWrite = 22
    /// Urgent condition on socket
    case urgent = 23
    /// CPU limit exceeded
    case cpuLimit = 24
    /// File size limit exceeded
    case fileSizeLimit = 25
    /// Virtual alarm clock
    case virtualAlarm = 26
    /// Profiling alarm clock
    case profiling = 27
    /// Window size change
    case windowChange = 28
    /// I/O now possible
    case ioPossible = 29
    /// Power failure restart
    case powerRestart = 30
    /// Bad system call
    case badSystemCall = 31
}
// swiftlint:enable sorted_enum_cases

/// Sends a kill signal to the process by its identifier.
/// - Parameters:
///   - pid: process identifier
///   - signal: unix process signal
/// - Returns: operation success status
func kill(pid: Int32, by signal: ProcessSignal) -> Bool {
    system_kill(pid, signal.rawValue) == 0
}
