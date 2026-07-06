import SwiftUI
import Textual

struct DiscordMarkdownDemo: View {
  private let source = """
    # big header
    ## smaller header
    ### small header
    -# subtext or footnote or whatever!

    *italics* _italics_
    __underline__ __*underlining my italics*__
    ***bold italics*** and __***bold underlined italics***__!
    ~~strikethrough~~

    [wagwan](https://llsc12.me)

    * unordered list with asterisk
    - unordered list with hyphen
      - unordered list hyphen indented
        - unordered list hyphen double indent

    1. Step 1
    2. Step 2
        1. Substep 1
        2. Substep 2

    `inline code`
    ```
    code block
    1
    2
    3
    ```
    ```swift
    @main
    struct Tool {
      static func main() async throws {
        print("hi mom")
      }
    }
    ```
    > Block quote
    > It can contain buncha inline things too
    > ```swift
    > // like code
    > ```
    > # and headers
    > ||and spoilers! boo!||
    <https://google.com> is a link with no embed.

    <email@email.com>

    user mentions <@1>
    channel mentions <#2>
    role mentions <@&3>
    custom emojis <:partyparrot:1009808642410823723> or <a:partyparrot:1009808642410823723>

    Relative <t:1757847540:R>
    Short time <t:1757847540:t>
    Long date with day of week short time <t:1757847540:F>

    >>> and this carries on
    to the end of the message
    no matter how many lines follow
    """

  @State private var revealedSpoilers: Set<String> = []
  @State private var tappedURL: URL?
  @State private var tapLocalPoint: CGPoint = .zero
  @State private var documentFrame: CGRect = .zero
  @State private var fontScale: CGFloat = 1

  private var extensions: [AttributedStringMarkdownParser.SyntaxExtension] {
    [
      .discordMentions(
        userName: { $0 == "1" ? "lakhan" : nil },
        channelName: { $0 == "2" ? "general" : nil },
        roleName: { $0 == "3" ? "mods" : nil }
      ),
      // The default `.discordEmoji()` cdnURL already points at Discord's real CDN
      // (cdn.discordapp.com/emojis/{id}.{png,gif}) — the loader genuinely fetches over the
      // network (see AttachmentLoaderDemo for the same mechanism against picsum.photos). This
      // demo overrides it because ids "4"/"5" below are placeholders, not real Discord asset
      // ids, so the real CDN would just 404. Swap this override for the default in a real client.
      .discordEmoji(cdnURL: { id, animated in
        URL(
          string:
            "https://cdn.discordapp.com/emojis/\(id).\(animated ? "gif" : "png")"
        )!
      }),
      .discordTimestamps,
      .discordNoEmbedLinks,
      .discordSpoilers(revealed: revealedSpoilers),
      .discordSubtext,
    ]
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Image(systemName: "textformat.size.smaller")
        Slider(value: $fontScale, in: 0.5...2.5)
        Image(systemName: "textformat.size.larger")
      }
      .padding()

      Divider()

      scrollableContent
    }
  }

  private var scrollableContent: some View {
    ScrollView {
      StructuredText(
        source,
        parser: .discordMarkdown(syntaxExtensions: extensions),
        // `syntaxExtensions` capturing `revealedSpoilers` doesn't by itself trigger a re-parse
        // (StructuredText only watches the markdown *text*) — `revision` re-parses in place
        // without resetting the view's identity, unlike `.id(_:)`, which would momentarily
        // collapse the whole scroll view's content while a fresh copy re-parses.
        revision: revealedSpoilers
      )
      .textual.structuredTextStyle(.discord)
      .textual.emojiProperties(
        DiscordMarkdown.isEmojiOnlyContent(source)
          ? .discordJumbo : .discordStandard
      )
      .textual.fontScale(fontScale)
      .textual.onEntityTap { url, bounds in
        handleTap(url: url, bounds: bounds)
      }
      .textual.textSelection(.enabled)
      .padding()
      .background(
        GeometryReader { geometry in
          // Track the frame itself, not just `geometry.size` — scrolling changes this view's
          // `.global` *origin* while its size stays the same, so watching only `size` meant
          // `documentFrame` went stale the instant scrolling started.
          Color.clear
            .onChange(of: geometry.frame(in: .global), initial: true) { _, newValue in
              documentFrame = newValue
            }
        }
      )
      // `.rect(.rect(_:))` takes an explicit CGRect in *this view's own local coordinate space*
      // — SwiftUI resolves it against this view's current on-screen geometry at presentation
      // time, so it's immune to both the "fraction of the whole document" issue a `UnitPoint`
      // anchor has (reconciling a fraction against a partially-visible, scrolled view) and the
      // marker-view/`.offset`-vs-`.position` layout-frame trap (a plain `.offset` doesn't affect
      // the frame `.popover` itself reads; a `.position`-based marker had its own overlay-sizing
      // issues). No separate marker view or GeometryReader-derived math beyond the tap point
      // itself is needed.
      .popover(
        isPresented: isPopoverPresented,
        attachmentAnchor: .rect(.rect(CGRect(origin: tapLocalPoint, size: .zero)))
      ) {
        popoverContent
          .padding()
          .frame(minWidth: 200)
      }
    }
    // `onEntityTap` still calls `openURL` too (see its doc comment) — without this override the
    // system would try (and fail) to find an app that handles our made-up `textual-discord://`
    // scheme, popping an "open with" dialog. A real client would similarly swallow whatever
    // custom scheme it invents for mentions/spoilers/etc.
    .environment(
      \.openURL,
      OpenURLAction { url in
        url.scheme == "textual-discord" ? .handled : .systemAction
      }
    )
  }

  private var isPopoverPresented: Binding<Bool> {
    Binding(
      get: { tappedURL != nil },
      set: { if !$0 { tappedURL = nil } }
    )
  }

  @ViewBuilder
  private var popoverContent: some View {
    if let tappedURL {
      switch tappedURL.host {
      case "mention":
        Text(tappedURL.path)
          .font(.headline)
      case "spoiler":
        Text("Tap again elsewhere to keep it revealed.")
      case "emoji":
        emojiDetail(for: tappedURL)
      default:
        Text(tappedURL.absoluteString)
      }
    }
  }

  @ViewBuilder
  private func emojiDetail(for url: URL) -> some View {
    // A real client would look up which server this emoji belongs to, who uploaded it, etc. from
    // its id — this just shows what's already encoded in the tapped URL.
    let query =
      URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    let name = query.first { $0.name == "name" }?.value ?? "unknown"
    let animated = query.first { $0.name == "animated" }?.value == "true"
    let id = url.lastPathComponent

    VStack(alignment: .leading, spacing: 4) {
      Text(":\(name):")
        .font(.headline)
      Text("id \(id)").foregroundStyle(.secondary)
      Text(animated ? "Animated" : "Static").foregroundStyle(.secondary)
    }
  }

  private func handleTap(url: URL, bounds: CGRect) {
    if url.host == "spoiler", let name = url.pathComponents.last {
      revealedSpoilers.insert(name)
    }

    tappedURL = url
    // `bounds` is in the `.global` coordinate space (see `onEntityTap`'s doc comment);
    // `documentFrame` is this same view's own global frame, captured via the background
    // GeometryReader above — subtracting one from the other gives the tap's position local to
    // the document, which is what the marker view's `.offset` needs.
    tapLocalPoint = CGPoint(
      x: bounds.midX - documentFrame.minX,
      y: bounds.minY - documentFrame.minY
    )
  }
}

#Preview {
  DiscordMarkdownDemo()
}
