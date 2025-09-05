import Foundation

/// Optimally this should be an API call to fetch fresh data, but Discord doesn't yet
/// fully support OpenAPI, so we just use a manually-downloaded spec file for now.
///
/// The file is the Discord API's (alpha) postman collection
/// (https://www.postman.com/discord-api) which is exported and then
/// converted to the OpenAPI format.
/// I've removed some invalid endpoints from the spec, and added some new ones.

@main
struct EntryPoint {
    static func main() async throws {
        let fm = FileManager.default
        let current = fm.currentDirectoryPath
        let path = current + "/Sources/DiscordHTTP/Endpoints/APIEndpoint.swift"
        let data = Data(result.utf8)
        let write = fm.createFile(atPath: path, contents: data)
        if !write {
            fatalError("Failed to create/write at \(path.debugDescription)")
        }
    }
}
