# Paicord

A  native Discord client written in Swift using SwiftUI, with a goal of feature parity with customisation and Quality-of-Life additions!

 [![GitHub Release](https://img.shields.io/github/v/release/llsc12/Paicord?include_prereleases)](https://github.com/llsc12/Paicord/releases) ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/llsc12/paicord/build.yml) [![GitHub License](https://img.shields.io/github/license/llsc12/Paicord)](https://github.com/llsc12/Paicord/blob/main/LICENSE) [![Discord](https://img.shields.io/discord/1417976730303463436?style=flat&label=discord)](https://discord.gg/fqhPGHPyaK) ![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/llsc12/paicord/total)

> [!NOTE]
>
> Paicord is still in development! Expect a number of issues or unimplemented features. If you encounter a bug, please create an issue! There was previously a note about MFA support, however MFA has been updated to support SMS and backup codes in addition to the already existing TOTP support, alongside QR Code logins.

<img width="371" height="298" alt="screenshot of Paicord" src="https://github.com/user-attachments/assets/d6b73ecb-c008-412e-9715-5817954f93f2" />

---

Paicord currently supports sending messages, replying to messages, uploading files and photos, it has partial Discord-flavoured markdown support, partial reactions support, partial embeds support etc.

This list is not exhaustive but the goal for Paicord is to have parity with the official Discord client, excluding unfavourable things like upselling of services. A real feature/todo list will be made eventually. 

> [!WARNING]
>
> As all third-party clients and client mods do, using Paicord is a violation of Discord ToS! Whilst Paicord ensures to pretend to be Discord as close as possible, the risk of account bans is ever-present. Beware! 

## Cross-platform
We have subprojects in the works to port the client to other platforms natively too! Keep an eye out on the repo or join the [Discord Server](https://discord.gg/fqhPGHPyaK)!

## Installing

There nightly releases of Paicord built from source when source successfully compiles.

| iOS (17.0+)                                                  | macOS (14.0+)                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Download iOS Artifact](https://nightly.link/llsc12/Paicord/workflows/build/main/Paicord-iOS) | [Download macOS Artifact](https://nightly.link/llsc12/Paicord/workflows/build/main/Paicord-macOS) |


## Sponsoring

If you've enjoyed using Paicord, I would apprecate a [sponsor](https://github.com/sponsors/llsc12)! I work on Paicord in my free time outside of Uni work, so it would be awesome if you chipped in. Sponsors over $5 get custom profile badges! Refer to sponsor page for information. Benefits are managed via a bot in the [Discord Server](https://discord.gg/fqhPGHPyaK) so be sure to join! Builds are also available here.

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/llsc12)
## Star History

<a href="https://www.star-history.com/#llsc12/Paicord&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=llsc12/Paicord&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=llsc12/Paicord&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=llsc12/Paicord&type=date&legend=top-left" />
 </picture>
</a>

## References

Paicord uses modified versions of [DiscordBM](https://github.com/DiscordBM/DiscordBM) and [SwiftMarkdownParser](https://github.com/sciasxp/SwiftMarkdownParser). These other references are mentioned since I read their code to learn from others.

- [Accord](https://github.com/tealbathingsuit/accord)
- [Swiftcord](https://github.com/SwiftcordApp/Swiftcord)
- [Cyclone](https://github.com/slice/cyclone)

And of course, [Discord Userdoccers and its maintainers](https://docs.discord.food) helped massively with their unofficial documentation and direct help.
