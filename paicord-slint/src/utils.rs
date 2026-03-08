use i_slint_common::styled_text::{FormattedSpan, Style, StyledTextParagraph};
use i_slint_core::styled_text::StyledText;
use paicord_rs::{
    discord_http::endpoints::cdn_endpoints,
    discord_models::types::{
        gateway::PartialMessage, guild::PartialMember, permission::Role, shared::DiscordColor,
        snowflake::Snowflake, user::PartialUser,
    },
    markdown::{AstDocumentNode, AstNode, AstNodeType, DiscordMarkdownParser},
};
use slint::SharedVector;

pub fn fetch_user_avatar_url(
    member: Option<PartialMember>,
    guild_id: Option<Snowflake>,
    user: Option<PartialUser>,
) -> Option<String> {
    let id = fetch_user_id(member.clone(), user.clone())?;

    if member.as_ref().is_some_and(|m| m.avatar.is_some())
        || user.as_ref().is_some_and(|u| u.avatar.is_some())
    {
        if let Some(guild_id) = guild_id
            && let Some(avatar) = member.as_ref().and_then(|m| m.avatar.clone())
        {
            return Some(cdn_endpoints::get_cdn_url(
                cdn_endpoints::CDNEndpoint::GuildMemberAvatar {
                    guild_id,
                    user_id: id,
                    avatar,
                },
            ));
        } else if let Some(avatar) = user.as_ref().and_then(|u| u.avatar.clone()) {
            return Some(cdn_endpoints::get_cdn_url(
                cdn_endpoints::CDNEndpoint::UserAvatar {
                    user_id: id,
                    avatar,
                },
            ));
        }
    } else {
        return Some(cdn_endpoints::get_cdn_url(
            cdn_endpoints::CDNEndpoint::DefaultUserAvatar { user_id: id },
        ));
    }

    None
}

pub fn fetch_user_id(
    member: Option<PartialMember>,
    user: Option<PartialUser>,
) -> Option<Snowflake> {
    if let Some(member) = member {
        if let Some(member_user) = member.user.as_ref() {
            return Some(member_user.id);
        }
    }

    if let Some(user) = user {
        return Some(user.id);
    }

    None
}

pub fn discord_color_to_slint(color: DiscordColor) -> slint::Brush {
    let (r, g, b) = color.as_rgb();
    let color = slint::Color::from_rgb_u8(r, g, b);
    slint::Brush::SolidColor(color)
}

pub fn get_message_color(
    partial_message: &PartialMessage,
    guild_member: &Option<PartialMember>,
    guild_roles: &Vec<Role>,
) -> Option<DiscordColor> {
    let Some(author) = partial_message.author.as_ref() else {
        return None;
    };

    let mut c = None;

    // if let Some(guild_member) = guild_member {
    //     c = get_member_color(guild_member, guild_roles);
    // }

    // if c.is_none() && let Some(member) = partial_message.member.as_ref() {
    //     c = get_member_color(member, guild_roles);
    // }

    if let Some(member) = if let Some(guild_member) = guild_member {
        Some(guild_member)
    } else if let Some(member) = partial_message.member.as_ref() {
        Some(member)
    } else {
        None
    } {
        c = get_member_color(member, guild_roles);
    }

    c
}

pub fn get_member_color(member: &PartialMember, guild_roles: &Vec<Role>) -> Option<DiscordColor> {
    let mut roles = Vec::new();
    for role_id in &member.roles {
        if let Some(role) = guild_roles.iter().find(|r| r.id == *role_id) {
            if role.color.inner != 0 {
                roles.push(role);
            }
        }
    }

    roles.sort_by(|a, b| b.position.cmp(&a.position));
    roles.first().map(|r| r.color)
}

pub async fn parse_markdown_to_slint<S: AsRef<str>>(
    content: S,
    markdown_parser: &DiscordMarkdownParser,
) -> anyhow::Result<StyledText> {
    if content.as_ref().is_empty() {
        return Ok(StyledText::default());
    }
    
    match markdown_parser
        .parse_ast(content.as_ref().to_string())
        .await
    {
        Ok(ast) => Ok(ast_to_styled_text(ast)),
        Err(err) => Err(anyhow::anyhow!("Failed to parse markdown: {}", err)),
    }
}

struct CustomStyledText {
    paragraphs: SharedVector<StyledTextParagraph>,
}

fn ast_to_styled_text(ast: AstDocumentNode) -> StyledText {
    let mut paragraphs: Vec<StyledTextParagraph> = Vec::new();
    let mut current_paragraph = 0;

    for doc_node in ast.children {
        match doc_node.node_type {
            // AstNodeType::LineBreak => {
            //     current_paragraph += 1;
            // }
            AstNodeType::Paragraph => {
                for child in doc_node.children {
                    if child.node_type == AstNodeType::LineBreak {
                        current_paragraph += 1;
                    }
                    let Some(mut child_paragraph) = ast_to_styled_text_paragraph(&child) else {
                        continue;
                    };

                    let Some(current_paragraph_ref) = paragraphs.get_mut(current_paragraph) else {
                        paragraphs.push(child_paragraph);
                        continue;
                    };

                    for style in &mut child_paragraph.formatting {
                        let offset = current_paragraph_ref.text.len();
                        style.range = (style.range.start + offset)..(style.range.end + offset);
                    }

                    current_paragraph_ref.text.push_str(&child_paragraph.text);
                    current_paragraph_ref
                        .formatting
                        .extend(child_paragraph.formatting);
                    current_paragraph_ref.links.extend(child_paragraph.links);
                }
            }

            _ => {}
        }
    }

    let idk_vec = SharedVector::from_slice(&paragraphs);
    let idk = CustomStyledText {
        paragraphs: idk_vec,
    };
    // idk_vec.push(Idk { paragraphs });

    //StyledText::parse_interpolated::<Idk>(&text, &idk_vec).unwrap()
    unsafe { std::mem::transmute(idk) }
}

fn ast_to_styled_text_paragraph(ast: &AstNode) -> Option<StyledTextParagraph> {
    let mut text = String::new();
    let mut styles = Vec::new();

    match ast.node_type {
        AstNodeType::Text => {
            let t = ast.content.clone().unwrap_or_default();
            text.push_str(&t);
        }
        AstNodeType::Italic => {
            for child in &ast.children {
                if let Some(child_paragraph) = ast_to_styled_text_paragraph(child) {
                    text.push_str(&child_paragraph.text);
                    styles.extend(child_paragraph.formatting);
                    styles.push(FormattedSpan {
                        range: text.len() - child_paragraph.text.len()..text.len(),
                        style: Style::Emphasis,
                    });
                }
            }
        }
        AstNodeType::Bold => {
            for child in &ast.children {
                if let Some(child_paragraph) = ast_to_styled_text_paragraph(child) {
                    text.push_str(&child_paragraph.text);
                    styles.extend(child_paragraph.formatting);
                    styles.push(FormattedSpan {
                        range: text.len() - child_paragraph.text.len()..text.len(),
                        style: Style::Strong,
                    });
                }
            }
        }
        AstNodeType::Underline => {
            for child in &ast.children {
                if let Some(child_paragraph) = ast_to_styled_text_paragraph(child) {
                    text.push_str(&child_paragraph.text);
                    styles.extend(child_paragraph.formatting);
                    styles.push(FormattedSpan {
                        range: text.len() - child_paragraph.text.len()..text.len(),
                        style: Style::Underline,
                    });
                }
            }
        }
        AstNodeType::Strikethrough => {
            for child in &ast.children {
                if let Some(child_paragraph) = ast_to_styled_text_paragraph(child) {
                    text.push_str(&child_paragraph.text);
                    styles.extend(child_paragraph.formatting);
                    styles.push(FormattedSpan {
                        range: text.len() - child_paragraph.text.len()..text.len(),
                        style: Style::Strikethrough,
                    });
                }
            }
        }
        AstNodeType::Link => {
            // let url = ast.get_url().unwrap_or_default();
            // for child in ast.get_children() {
            //     if let Some(child_paragraph) = ast_to_styled_text_paragraph(&child) {
            //         text.push_str(&child_paragraph.text);
            //         styles.extend(child_paragraph.formatting);
            //         styles.push(FormattedSpan {
            //             range: text.len() - child_paragraph.text.len()..text.len(),
            //             style: Style::Link(url.clone()),
            //         });
            //     }
            // }
        }
        _ => {
            return None;
        }
    }

    return Some(StyledTextParagraph {
        text,
        formatting: styles,
        links: Vec::new(),
    });
}
