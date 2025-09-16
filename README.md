# Paicord

A Discord client written in SwiftUI.

## Again?

Yes, whilst many clients have been written and then breaking after being left unmaintained, Paicord uses a fork of [DiscordBM](https://github.com/DiscordBM/DiscordBM) under the hood to function. It is resilient to API changes, hard typed and makes use of Swift async. 

## What changed

Paicord handles many things correctly this time. It can handle Captchas and MFA requests just fine on any endpoints. It also pulls values from your device to properly populate the `X-Super-Properties` header on all requests and client information at `IDENTIFY`. Thanks to PaicordLib's strong foundation established by DiscordBM, all use of the Discord API and gateway is done properly in static functions rather than [dynamically formed in code and typecasting](https://github.com/tealbathingsuit/accord/blob/c3b113db9c6ad2ae28b699614126d75b9ee9a772/Accord/UI/Chat/ChannelView/ChannelView.swift#L516-L546).

## Future plans

I really wanna see someone take PaicordLib and make a Linux client using one of those cool libraries for bringing some semblance of SwiftUI on Linux and Windows. If that person is you, reach out to me!

PaicordLib needs

## References

Only two projects have been used in Paicord directly. [DiscordBM](https://github.com/DiscordBM/DiscordBM) and [SwiftMarkdownParser](https://github.com/sciasxp/SwiftMarkdownParser). Other references are mentioned since I read their code to learn from others.

- [Accord](https://github.com/tealbathingsuit/accord)
- [Swiftcord](https://github.com/SwiftcordApp/Swiftcord)
- [Cyclone](https://github.com/slice/cyclone)

And of course, [Discord Userdoccers and its maintainers](https://docs.discord.food) helped massively with their unofficial documentation and direct help.
