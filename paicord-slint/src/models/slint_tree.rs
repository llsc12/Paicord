use std::sync::RwLock;

use lineartree::{NodeRef, Tree};
use paicord_rs::discord_models::types::snowflake::Snowflake;

use crate::images::ImageMangler;

pub trait SlintTreeItem {
    fn get_id(&self) -> Snowflake;
    fn is_expanded(&self) -> bool;
    fn has_children(&self) -> bool;
}

pub struct SlintTree<T> where T: SlintTreeItem + Clone {
    values: RwLock<Tree<T>>,
    pub image_mangler: ImageMangler,
    pub notify: slint::ModelNotify,
}

impl<T: SlintTreeItem + Clone> SlintTree<T> {
    pub fn new_with_items(tree: Tree<T>, image_mangler: ImageMangler) -> Self {
        Self {
            values: RwLock::new(tree),
            image_mangler,
            notify: slint::ModelNotify::default(),
        }
    }

    pub fn set_item_at_row(&self, row: usize, data: T) {
        let Some(node_ref) = self.get_node_at_row(row) else {
            return;
        };

        let mut expanded = false;
        let mut is_parent = false;

        {
            let mut tree = self.values.write().unwrap();
            tree.get_mut(node_ref).map(|node| {
                expanded = node.is_expanded();
                is_parent = node.has_children();
                *node = data;
            });
        }

        let child_count = {
            let tree = self.values.read().unwrap();
            tree.get_children(node_ref).map(|children| children.count()).unwrap_or(0)
        };

        self.notify.row_changed(row);

        if is_parent {
            if expanded {
                self.notify.row_added(row, child_count);
            } else {
                self.notify.row_removed(row, child_count);
            }
        }
    }

    pub fn find_node_index_by_id(&self, id: Snowflake) -> Option<usize> {
        let tree = self.values.read().unwrap();
        let mut iter = tree.depth_first(false).unwrap();
        let mut index = 0;

        while let Some(item_ref) = iter.next() {
            let item = tree.get(item_ref).unwrap();

            if item.get_id() == id {
                return Some(index);
            }

            if let Ok(children) = tree.get_children(item_ref) {
                if !item.is_expanded() {
                    let children_count = children.len();
                    if children_count == 0 {
                        index += 1;
                        continue;
                    }
                    for _ in 0..children_count {
                        iter.next();
                    }
                }
            }

            index += 1;
        }

        None
    }

    pub fn get_node_at_row(&self, row: usize) -> Option<NodeRef> {
        let tree = self.values.read().unwrap();

        let mut iter = tree.depth_first(false).unwrap();
        let mut current_row = 0;

        while let Some(item_ref) = iter.next() {
            if current_row == row {
                return Some(item_ref);
            }

            let item = tree.get(item_ref).unwrap();

            if let Ok(children) = tree.get_children(item_ref) {
                if !item.is_expanded() {
                    let children_count = children.len();
                    if children_count == 0 {
                        current_row += 1;
                        continue;
                    }
                    
                    for _ in 0..children_count {
                        let _ = iter.next();
                    }
                }
            }

            current_row += 1;
        }

        None
    }
    
    pub fn get_node_data(&self, node_ref: NodeRef) -> Option<T> {
        let tree = self.values.read().unwrap();
        tree.get(node_ref).cloned()
    }

    pub fn get_tree_count_without_collapsed_children(&self) -> usize {
        let tree = self.values.read().unwrap();
        let mut count = 0;
        let mut iter = tree.depth_first(false).unwrap();

        while let Some(item_ref) = iter.next() {
            let item = tree.get(item_ref).unwrap();

            if let Ok(children) = tree.get_children(item_ref) {
                if !item.is_expanded() {
                    let children_count = children.len();
                    if children_count == 0 {
                        count += 1;
                        continue;
                    }
                    for _ in 0..children_count {
                        iter.next();
                    }
                } else {
                }
            }
            count += 1;
        }

        count
    }
}