produced with info from https://docs.discord.food/resources/user-settings-proto#preloaded-user-settings-object
uses proto files from https://github.com/discord-userdoccers/discord-protos

```bash
protoc \
  --proto_path=. \
  --swift_out=. \
  --swift_opt=Visibility=Public \
  file.proto
```
