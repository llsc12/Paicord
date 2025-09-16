import Foundation
import PackagePlugin

@main
struct GenerateAPIEndpoints: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "GenerateAPIEndpointsExec")
        #if compiler(>=6.0)
        let toolUrl = tool.url
        #else
        let toolUrl = URL(fileURLWithPath: tool.path.string)
        #endif
        let process = Process()
        process.executableURL = toolUrl
        try process.run()
        process.waitUntilExit()
    }
}
