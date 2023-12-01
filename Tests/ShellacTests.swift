import XCTest
@testable import Shellac

class ShellacTests: XCTestCase {
    func testWithoutArguments() throws {
        let uptime = try shell(with: "uptime")
        XCTAssertTrue(uptime.contains("load average"))
    }

    func testWithArguments() throws {
        let echo = try shell(with: "echo", arguments: ["Hello world"])
        XCTAssertEqual(echo, "Hello world")
    }

    func testWithInlineArguments() throws {
        let echo = try shell(with: "echo \"Hello world\"")
        XCTAssertEqual(echo, "Hello world")
    }

    func testSingleCommandAtPath() throws {
        try shell(with: "echo 'Hello' > \(NSTemporaryDirectory())ShellacTests-SingleCommand.txt")

        let textFileContent = try shell(
            with: "cat ShellacTests-SingleCommand.txt",
            at: NSTemporaryDirectory()
        )

        XCTAssertEqual(textFileContent, "Hello")
    }

    func testSingleCommandAtPathContainingSpace() throws {
        try shell(with: "mkdir -p \"Shellac Test Folder\"", at: NSTemporaryDirectory())
        try shell(with: "echo \"Hello\" > File", at: NSTemporaryDirectory() + "Shellac Test Folder")

        let output = try shell(with: "cat \(NSTemporaryDirectory())Shellac\\ Test\\ Folder/File")
        XCTAssertEqual(output, "Hello")
    }

    func testSingleCommandAtPathContainingTilde() throws {
        let homeContents = try shell(with: "ls", at: "~")
        XCTAssertFalse(homeContents.isEmpty)
    }

    func testThrowingError() {
        do {
            try shell(with: "cd", arguments: ["notADirectory"])
            XCTFail("Expected expression to throw")
        } catch let error as ShellError {
            XCTAssertTrue(error.error.contains("notADirectory"))
            XCTAssertTrue(error.output.isEmpty)
            XCTAssertTrue(error.code != 0)
        } catch {
            XCTFail("Invalid error type: \(error)")
        }
    }

    func testThrowingTimeoutError() {
        do {
            try shell(with: "sleep", arguments: ["5"], timeout: 0.1)
            XCTFail("Expected expression to throw")
        } catch let error as ShellTimeoutError {
            XCTAssertTrue(!error.message.isEmpty)
        } catch {
            XCTFail("Invalid error type: \(error)")
        }
    }

    func testCapturingOutputWithHandle() throws {
        let pipe = Pipe()
        let output = try shell(with: "echo", arguments: ["Hello"], outputHandle: pipe.fileHandleForWriting)
        let capturedData = pipe.fileHandleForReading.readDataToEndOfFile()
        XCTAssertEqual(output, "Hello")
        XCTAssertEqual(output + "\n", String(data: capturedData, encoding: .utf8))
    }

    func testCapturingErrorWithHandle() throws {
        let pipe = Pipe()

        do {
            try shell(with: "cd", arguments: ["notADirectory"], errorHandle: pipe.fileHandleForWriting)
            XCTFail("Expected expression to throw")
        } catch let error as ShellError {
            XCTAssertTrue(error.error.contains("notADirectory"))
            XCTAssertTrue(error.output.isEmpty)
            XCTAssertTrue(error.code != 0)

            let capturedData = pipe.fileHandleForReading.readDataToEndOfFile()
            XCTAssertEqual(error.error + "\n", String(data: capturedData, encoding: .utf8))
        } catch {
            XCTFail("Invalid error type: \(error)")
        }
    }

    func testSeriesOfCommands() throws {
        let echo = try shell(with: ["echo 'Hello'", "echo 'world'"])
        XCTAssertEqual(echo, "Hello\nworld")
    }

    func testSeriesOfCommandsAtPath() throws {
        try shell(with: [
            "cd \(NSTemporaryDirectory())",
            "mkdir -p ShellacTests",
            "echo \"Hello again\" > ShellacTests/MultipleCommands.txt"
        ])

        let textFileContent = try shell(with: [
            "cd ShellacTests",
            "cat MultipleCommands.txt"
        ], at: NSTemporaryDirectory())

        XCTAssertEqual(textFileContent, "Hello again")
    }
}
