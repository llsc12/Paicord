@_exported import DiscordAuth
@_exported import DiscordCore
@_exported import DiscordGateway
@_exported import DiscordHTTP
@_exported import DiscordModels
@_exported import DiscordUtilities

public struct Test {
  public init(name: String) {
    self.name = name
  }

  public var name: String

  public func sayHello() {
    print("Hello, \(name)!")

  }
}
