# Paicord

A Discord client written in SwiftUI that can resist breakages.

## Again?

Yes, whilst many clients have been written and then breaking after being left unmaintained, Paicord uses a fork of [DiscordBM](https://github.com/DiscordBM/DiscordBM) under the hood to function. It is resilient to API changes, hard typed and makes use of Swift async. This makes it maintainable and reusable for other platforms.

## What changed

Paicord handles many things correctly. It can handle Captchas and MFA requests just fine on all endpoints. It also pulls values from your device to properly populate the `X-Super-Properties` header on all requests and client information at `IDENTIFY`. Thanks to PaicordLib's strong foundation established by DiscordBM, all use of the Discord API and gateway is done properly in static functions rather than [dynamically formed in code and typecasting](https://github.com/tealbathingsuit/accord/blob/c3b113db9c6ad2ae28b699614126d75b9ee9a772/Accord/UI/Chat/ChannelView/ChannelView.swift#L516-L546). It uses Stores that receive and categorise data, which get used as view models for Views. 
## Future plans

I really wanna see someone take PaicordLib and make a Linux client using one of those cool libraries for bringing some semblance of SwiftUI on Linux and Windows. If that person is you, reach out to me!

PaicordLib needs some additions, mainly user API routes and some client-sent gateway payloads. The gateway payloads will probably be implemented by myself soon. User API routes will take time to go through.

## References

Only two projects have been used in Paicord directly. [DiscordBM](https://github.com/DiscordBM/DiscordBM) and [SwiftMarkdownParser](https://github.com/sciasxp/SwiftMarkdownParser). Other references are mentioned since I read their code to learn from others.

- [Accord](https://github.com/tealbathingsuit/accord)
- [Swiftcord](https://github.com/SwiftcordApp/Swiftcord)
- [Cyclone](https://github.com/slice/cyclone)

And of course, [Discord Userdoccers and its maintainers](https://docs.discord.food) helped massively with their unofficial documentation and direct help.

## Linux (and android)
To satisfy our desire for oxidization, for linux, rust is mainly used. The UI is in QtQuick QML because it was the only ui library with decent rust bindings that runs literally everywhere while playing nice with rust. 

### paicord-rs
this is the crate which facilitates interaction with PaicordLib via [swift-bridge](https://github.com/chinedufn/swift-bridge). It contains its own swift library which is essentially middleware since swift-bridge isn't able to do absolutely everything PaicordLib needs.

### PaicordQt
this is going to be the frontend of Paicord on non-mac platforms. It's a cmake project so QtCreator can work with it, which is useful for getting the build environment for Qt on android. 