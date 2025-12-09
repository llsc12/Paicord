use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new_qml_module(QmlModule::new("paicord.rs").qml_files(["../qml/Main.qml"]))
        .files(["src/lib.rs"])
        .build()
        .export();
}
