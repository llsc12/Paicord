# Paicord

A  native Discord client written in Swift using SwiftUI, with a goal of feature parity with customisation and Quality-of-Life additions!

 [![GitHub Release](https://img.shields.io/github/v/release/llsc12/Paicord?include_prereleases)](https://github.com/llsc12/Paicord/releases) ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/llsc12/paicord/build.yml) [![GitHub License](https://img.shields.io/github/license/llsc12/Paicord)](https://github.com/llsc12/Paicord/blob/main/LICENSE) [![Discord](https://img.shields.io/discord/1417976730303463436?style=flat&label=discord)](https://discord.gg/fqhPGHPyaK) ![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/llsc12/paicord/total)

> [!NOTE]
>
> Paicord is still in development! Expect a number of issues or unimplemented features. If you encounter a bug, please create an issue!

<img width="371" height="298" alt="screenshot of Paicord" src="https://github.com/user-attachments/assets/d6b73ecb-c008-412e-9715-5817954f93f2" />

---

## Progress

Paicord has support for core chat features, like partial markdown, attachments and embeds with support for file uploads, editing, replying and deleting messages, and more! 

Paicord aims for feature parity! By default, the more difficult features are targeted first. Whilst this leaves many smaller features unimplemented at first, it helps keep momentum going! [Click here for a rough feature list!](Feature Checklist.md)

> [!WARNING]
>
> As all third-party clients and client mods do, using Paicord is a violation of Discord ToS! Whilst Paicord ensures to pretend to be Discord as close as possible, the risk of account bans is ever-present. Beware! 

## Installing

These downloads are nightly releases of Paicord, built from source.

| iOS (17.0+)                                                  | macOS (14.0+)                                                | Linux |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Download iOS Artifact](https://nightly.link/llsc12/Paicord/workflows/build/main/Paicord-iOS) | [Download macOS Artifact](https://nightly.link/llsc12/Paicord/workflows/build/main/Paicord-macOS) | TBA |


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

## FAQ

<details>
<summary><b>Is this client allowed by Discord?</b></summary>
Third-party clients are not officially supported by Discord.  
Use at your own risk.
</details>

<details>
<summary><b>Does this support plugins?</b></summary>
No, but plugin-like functionality will eventually make it into Paicord cleanly. Extra features must be implemented in a minimalistic way as to not cause clutter. As of writing, Paicord is still early in the works and focus is only on feature parity, not extras.
</details>

<details>
<summary><b>Will this be maintained?</b></summary>
I mean I use Discord a lot, plus this is quite a lot of fun thus far.
It really depends on motivation and community support. Paicord is still a hobby project and I balance it with my education. 
At a minimum, Paicord shouldn't break easily even with inconsistent maintainence.
</details>

<details>
<summary><b>Where's token login support?</b></summary>
Will never be implemented, using the same token on two clients like the one you took the token from is more dangerous. I think it's using them both at the same time that creates the risk of bans. Discord could also compare super-properties against prior sessions I guess. Use the normal login methods, they're much safer.
</details>

<details>
<summary><b>What about theming support?</b></summary>
This information only applies to the SwiftUI application.<br>
That's in the works! Paicord will let you set custom colors or materials on various interface elements. There will also be pre-made alternative interface layouts. It won't be as flexible as CSS, but it should hopefully allow for some tasteful customisation!
</details>

Any other questions? Join the [Discord server]()!

## References

Paicord uses modified versions of [DiscordBM](https://github.com/DiscordBM/DiscordBM) and [SwiftMarkdownParser](https://github.com/sciasxp/SwiftMarkdownParser). These other references are mentioned since I read their code to learn from others.

- [Accord](https://github.com/tealbathingsuit/accord)
- [Swiftcord](https://github.com/SwiftcordApp/Swiftcord)
- [Cyclone](https://github.com/slice/cyclone)

And of course, [Discord Userdoccers and its maintainers](https://docs.discord.food) helped massively with their unofficial documentation and direct help.

For voice, work from [SwiftDiscordAudio/DiscordAudioKit](https://github.com/SwiftDiscordAudio/DiscordAudioKit) was used for reference a lot, and also uses [these RTP packet models etc.](https://github.com/SwiftDiscordAudio/DiscordAudioKit/tree/main/Sources/DiscordRTP) too. Paicord relies on a fork of [DaveKit](https://github.com/SwiftDiscordAudio/DaveKit) for voice too! 

