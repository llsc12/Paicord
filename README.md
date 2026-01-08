# Paicord

A new Discord client written in SwiftUI, with a goal of feature parity with customisation and Quality-of-Life additions!

> [!NOTE]
>
> Paicord is still in development! Expect a number of issues or unimplemented features. If you encounter a bug, please create an issue! Additionally, MFA is supported for login, however only TOTP codes are implemented currently. This will be finished soon.

Paicord currently supports sending messages, replying to messages, uploading files and photos, it has partial Discord-flavoured markdown support, partial reactions support, partial embeds support etc.

This list is not exhaustive but the goal for Paicord is to have parity with the official Discord client, excluding unfavourable things like upselling of services. A real feature/todo list will be made eventually. 

> [!WARNING]
>
> As all third-party clients and client mods do, using Paicord is a violation of Discord ToS! Whilst Paicord ensures to pretend to be Discord as close as possible, the risk of account bans is ever-present. Beware! 

## Installing

There are currently no releases of Paicord, you can download builds built from Actions.

| iOS (17.4+)                                                  | macOS (14.2+)                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Download iOS Artifact](https://nightly.link/llsc12/Paicord/workflows/build/main/Paicord-iOS) | [Download macOS Artifact](https://nightly.link/llsc12/Paicord/workflows/build/main/Paicord-macOS) |


## Sponsor

If you've enjoyed using Paicord, I would apprecate a [sponsor](https://github.com/sponsors/llsc12)! I work on Paicord in my free time outside of Uni work, so it would be awesome if you chipped in. Monthly sponsors over $5 get custom profile badges! Refer to sponsor page for information. Benefits are managed via a bot in the [Discord Server](https://discord.gg/fqhPGHPyaK) so be sure to join! Builds are also available here.

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/llsc12)
## References

Paicord uses modified versions of [DiscordBM](https://github.com/DiscordBM/DiscordBM) and [SwiftMarkdownParser](https://github.com/sciasxp/SwiftMarkdownParser). These other references are mentioned since I read their code to learn from others.

- [Accord](https://github.com/tealbathingsuit/accord)
- [Swiftcord](https://github.com/SwiftcordApp/Swiftcord)
- [Cyclone](https://github.com/slice/cyclone)

And of course, [Discord Userdoccers and its maintainers](https://docs.discord.food) helped massively with their unofficial documentation and direct help.
