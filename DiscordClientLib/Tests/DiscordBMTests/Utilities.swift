import Foundation

func resource(name: String) -> Data {
    let fileManager = FileManager.default
    let path = "\(fileManager.currentDirectoryPath)/Tests/Resources/\(name)"
    if let data = fileManager.contents(atPath: path) {
        return data
    } else {
        fatalError(
            "Make sure you've set the custom working directory for the current scheme: https://docs.vapor.codes/getting-started/xcode/#custom-working-directory. If Xcode doesn't let you set a custom working directory with the instructions in the link, on the 'info' tab, set 'Executable' to 'Ask on Launch', then it should let you set your custom working directory. You can set 'Executable' back to 'None' afterwards."
        )
    }
}
