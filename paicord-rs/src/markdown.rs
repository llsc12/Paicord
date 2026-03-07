use std::sync::Arc;

use crate::ffi::{self, BridgedRustError};

pub type SourceLocation = ffi::SourceLocationRust;

#[derive(Clone)]
pub struct DiscordMarkdownParser {
    inner: Arc<ffi::DiscordMarkdownParser>
}

impl DiscordMarkdownParser {
    pub fn new() -> Self {
        let inner = ffi::discord_markdown_parser_new();
        Self {
            inner: Arc::new(inner)
        }
    }

    pub async fn parse_ast(&self, markdown: String) -> Result<AstDocumentNode, String> {
        match self.inner.parse_ast_rust(markdown).await {
            Ok(bridged_node) => Ok(AstDocumentNode::new(bridged_node)),
            Err(err) => {
                match err {
                    BridgedRustError::UnhandledError(msg) => Err(msg),
                }
            }
        }
    }
}

#[derive(Clone)]
pub struct AstDocumentNode {
    pub children: Vec<AstNode>,
}

impl AstDocumentNode {
    pub fn new(inner: ffi::BridgedAstDocumentNode) -> Self {
        Self {
            children: (0..inner.get_children_count())
                .map(|i| AstNode::new(inner.get_child(i)))
                .collect(),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AstNodeType {
    // Document structure
    Document,

    // Block elements
    Paragraph,
    Heading,
    BlockQuote,
    List,
    ListItem,
    CodeBlock,
    ThematicBreak,

    // Inline elements
    Text,
    Italic,
    Bold,
    Link,
    CodeSpan,
    LineBreak,
    Strikethrough,

    // Inline elements Discord specific
    Underline,
    Spoiler,
    Footnote,
    CustomEmoji,
    UserMention,
    RoleMention,
    ChannelMention,
    EveryoneMention,
    HereMention,
    Timestamp,

    Autolink,
}

#[derive(Clone)]
pub struct AstNode {
    //inner: Arc<ffi::BridgedAstNode>
    pub content: Option<String>,
    pub children: Vec<AstNode>,
    pub node_type: AstNodeType,
    pub source_location: Option<SourceLocation>,
}

impl AstNode {
    pub fn new(inner: ffi::BridgedAstNode) -> Self {
        Self {
            content: inner.get_content(),
            children: (0..inner.get_children_count())
                .map(|i| AstNode::new(inner.get_child(i)))
                .collect(),
            node_type: match inner.get_node_type().as_str() {
                "document" => AstNodeType::Document,
                "paragraph" => AstNodeType::Paragraph,
                "heading" => AstNodeType::Heading,
                "blockQuote" => AstNodeType::BlockQuote,
                "list" => AstNodeType::List,
                "listItem" => AstNodeType::ListItem,
                "codeBlock" => AstNodeType::CodeBlock,
                "thematicBreak" => AstNodeType::ThematicBreak,
                "text" => AstNodeType::Text,
                "italic" => AstNodeType::Italic,
                "bold" => AstNodeType::Bold,
                "link" => AstNodeType::Link,
                "codeSpan" => AstNodeType::CodeSpan,
                "lineBreak" => AstNodeType::LineBreak,
                "strikethrough" => AstNodeType::Strikethrough,
                "underline" => AstNodeType::Underline,
                "spoiler" => AstNodeType::Spoiler,
                "footnote" => AstNodeType::Footnote,
                "customEmoji" => AstNodeType::CustomEmoji,
                "userMention" => AstNodeType::UserMention,
                "roleMention" => AstNodeType::RoleMention,
                "channelMention" => AstNodeType::ChannelMention,
                "everyoneMention" => AstNodeType::EveryoneMention,
                "hereMention" => AstNodeType::HereMention,
                "timestamp" => AstNodeType::Timestamp,
                "autolink" => AstNodeType::Autolink,

                _ => AstNodeType::Text,
            },
            source_location: {
                let loc = inner.get_source_location();
                
                if loc.line == -1 && loc.column == -1 && loc.offset == -1 {
                    None
                } else {
                    Some(loc)
                }
            },
        }
    }
}

unsafe impl Send for AstNode {}
unsafe impl Sync for AstNode {}

unsafe impl Send for AstNodeType {}
unsafe impl Sync for AstNodeType {}

unsafe impl Send for AstDocumentNode {}
unsafe impl Sync for AstDocumentNode {}

unsafe impl Send for SourceLocation {}
unsafe impl Sync for SourceLocation {}

unsafe impl Send for DiscordMarkdownParser {}
unsafe impl Sync for DiscordMarkdownParser {}

impl Clone for SourceLocation {
    fn clone(&self) -> Self {
        Self {
            line: self.line,
            column: self.column,
            offset: self.offset,
        }
    }
}