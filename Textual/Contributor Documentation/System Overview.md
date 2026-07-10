# System Overview

Textual renders attributed content in SwiftUI while preserving the `Text` pipeline. It supports
inline attachments, text selection, link interaction, syntax highlighting, and customizable
block styling, all while keeping SwiftUI's text rendering benefits.

## Design Principles

The architecture keeps `SwiftUI.Text` as the rendering backbone for performance, composability,
and platform support. Attachments are represented both as attributes in `AttributedString`
(for metadata and sizing) and as views rendered in overlays (for display). Caches keyed by
attachment sizes minimize rebuilds during resize.

Fragment-level modifiers capture resolved `Text.Layout` through preferences, enabling precise
overlay positioning. Each `TextFragment` applies modifiers for selection background (on macOS),
attachment rendering, and link interaction. Scrollable regions (code blocks) handle their own
text selection, with document-level selection excluding these regions via hit testing.

## The Pipeline

Content transforms from markup to rendered UI through five stages: parsing, resolving
attachments, styling, building, and overlaying.

### Parsing

`MarkupParser` implementations convert structured markup into `AttributedString` with
[`PresentationIntent`](https://developer.apple.com/documentation/foundation/presentationintent)
for blocks and other Foundation attributes for inline formatting. Custom attributes handle
pre-processed entities like emoji URLs. While Textual currently focuses on markdown (via
`AttributedStringMarkdownParser`), the parser protocol supports any markup that can be transformed
into `AttributedString` with presentation intents, such as HTML or other structured formats.

Preprocessing happens before parsing. `MarkdownPreprocessor` handles transformations like emoji
substitution, with room for additional patterns in the future.

The parser produces an `AttributedString` that encodes structure through attributes, ready to
flow through the `Text` rendering pipeline.

### Resolving attachments

Some markup is only a reference to something that needs loading. Images (`run.imageURL`) and
custom emoji URLs are kept as attributes during parsing, then resolved asynchronously by
`WithAttachments` using environment-provided attachment loaders. Once an attachment has been
loaded, it's written back into the `AttributedString` as a `Textual.Attachment` attribute, and
the rest of the pipeline treats it like any other run.

### Styling

`WithInlineStyle` generates a new `AttributedString` with inline styles applied. It reads
`TextEnvironmentValues` (font, dynamic type size, legibility weight) from the environment and
applies font traits, colors, and scaling by reflecting `Font` into providers that support
environment-aware resolution.

Block styling happens at the view level. `BlockContent` groups runs by `PresentationIntent` and
creates block-specific views (`Paragraph`, `Heading`, `OrderedList`, etc.). Each block type can
be customized through style protocols that receive content and metadata. `BlockVStack`
reconciles adjacent block spacing through preferences.

### Building

`TextBuilder` constructs SwiftUI `Text` from styled `AttributedString`. For runs with
attachments, it queries each attachment's size for the given proposal and creates an invisible
placeholder at that size. To avoid rebuilding on every frame, the builder caches `Text` values.

This stage must happen before SwiftUI resolves geometry, so attachments receive size proposals
(typically width-constrained, height unconstrained) and return their desired dimensions.

### Overlaying

After SwiftUI resolves `Text.Layout`, modifiers applied at the fragment level use this geometry
to render overlays. `AttachmentOverlay` positions attachment views at their run locations.
`TextLinkInteraction` handles taps on URLs. Links are re-attached while building `Text` so the
resolved layout can be used for hit testing. Text selection is supported on macOS, iOS, and
visionOS; tvOS and watchOS don't provide a selection experience.

Text selection captures `Text.Layout` geometry and handles gestures through platform-native views.
To keep code blocks with scrollable overflow interactive, these blocks emit their frames via
preferences and are excluded from selection hit testing. When a selection becomes active in a
scrollable region, a coordinator clears any document selection (and vice versa) so only one
context is active at a time.

## Coordinate Systems

The pipeline uses three coordinate systems. `TextPosition` uses hierarchical `IndexPath`
([layout, line, run, runSlice]) to navigate the layout structure and track selection state.
Character indices (integer offsets into attributed strings) enable text operations like word
navigation and convert to/from index paths. Visual geometry (`CGRect`/`CGPoint`) from
`Text.Layout` provides bounds and origin for overlay rendering. This separation lets each
component work in its natural space—structural navigation uses indices, text operations use
character offsets, and rendering uses points.

One subtlety is that SwiftUI can produce multiple line fragments with their own attributed
strings (for example, when hard line breaks are present). Textual reconciles these into a single
attributed string for selection and adjusts slice character ranges so index and offset-based
operations stay consistent.
