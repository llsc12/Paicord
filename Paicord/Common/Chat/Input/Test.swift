//
//  Test.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 03/12/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PhotosUI
import SwiftUIX

struct TestMessageView: View {
  #if os(iOS)
    struct PickerInteractionProperties {
      var storedKeyboardHeight: CGFloat = 0
      var dragOffset: CGFloat = 0
      var showPhotosPicker: Bool = false
      var showFilePicker: Bool = false

      var keyboardHeight: CGFloat {
        storedKeyboardHeight == 0 ? 300 : storedKeyboardHeight
      }

      var pickerShown: Bool {
        showPhotosPicker || showFilePicker
      }

      var safeArea: UIEdgeInsets {
        if let safeArea = UIApplication.shared.connectedScenes.compactMap({
          ($0 as? UIWindowScene)?.keyWindow
        }).first?.safeAreaInsets {
          return safeArea
        }
        return .zero
      }

      var screenSize: CGSize {
        if let screen = UIApplication.shared.connectedScenes.compactMap({
          ($0 as? UIWindowScene)?.screen
        }).first {
          return screen.bounds.size
        }
        return .zero
      }

      var animation: Animation {
        .interpolatingSpring(duration: 0.2, bounce: 0, initialVelocity: 0)
      }
    }

    @State private var properties = PickerInteractionProperties()
    @State var selectedPhotos: [PhotosPickerItem] = []
  #endif

  @State var messageText: String = ""
  @FocusState private var isInputActive: Bool

  var body: some View {
    ScrollView {
      VStack {
        Text("test!")
        Text("test!")
        Text("test!")
        Text("test!")
        Text("test!")
        Text("test!")
      }
    }
    .scrollDismissesKeyboard(.immediately)
    .safeAreaInset(edge: .bottom, spacing: 10) {
      BottomBar()
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationTitle("gm")
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  func BottomBar() -> some View {
    HStack(alignment: .bottom, spacing: 8) {
      #if os(iOS)
        if properties.pickerShown {
          Button {
            properties.showFilePicker = false
            properties.showPhotosPicker = false
          } label: {
            Image(systemName: "plus")
              .font(.title3)
              .fontWeight(.medium)
              .foregroundStyle(Color.primary)
              .frame(width: 40, height: 40)
              .background(.ultraThinMaterial, in: .circle)
              .contentShape(.circle)
              .rotationEffect(.degrees(45))
          }
          #if os(macOS)
            .menuStyle(.button)
            .buttonStyle(.plain)
          #else
            .buttonStyle(.borderless)
          #endif
          .tint(.primary)
        } else {
          Menu {
            Menu {
              Button {
              } label: {
                Text("1")
              }
            } label: {
              Label("Apps", systemImage: "puzzle.fill")
            }

            Button {
              properties.showFilePicker = false
              properties.showPhotosPicker = true
            } label: {
              Label("Upload Photos", systemImage: "photo.on.rectangle")
            }
            Button {
              properties.showPhotosPicker = false
              properties.showFilePicker = true
            } label: {
              Label("Upload Files", systemImage: "doc.on.doc")
            }
          } label: {
            Image(systemName: "plus")
              .font(.title3)
              .fontWeight(.medium)
              .foregroundStyle(Color.primary)
              .frame(width: 40, height: 40)
              .background(.ultraThinMaterial, in: .circle)
              .contentShape(.circle)
          }
          #if os(macOS)
            .menuStyle(.button)
            .buttonStyle(.plain)
          #else
            .buttonStyle(.borderless)
          #endif
          .tint(.primary)
        }
      #else
        Menu {
          Menu {
            Button {
            } label: {
              Text("1")
            }
          } label: {
            Label("Apps", systemImage: "puzzle.fill")
          }

          Button {

          } label: {
            Label("Upload Files", systemImage: "doc.on.doc")
          }
        } label: {
          Image(systemName: "plus")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(Color.primary)
            .frame(width: 40, height: 40)
            .background(.ultraThinMaterial, in: .circle)
            .contentShape(.circle)
        }
      #endif

      TextField("Message #general", text: $messageText)
        .focused($isInputActive)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 30))
    }
    .padding(.horizontal, 15)
    .padding(.bottom, 10)
    .geometryGroup()
    #if os(iOS)
      .padding(.bottom, animatedKeyboardHeight)
      .animation(properties.animation, value: animatedKeyboardHeight)
      // Extracting KB Height
      .onReceive(
        NotificationCenter.default.publisher(
          for: UIResponder.keyboardWillChangeFrameNotification
        )
      ) { userInfo in
        if let keyboardFrame = userInfo.userInfo?[
          UIResponder.keyboardFrameEndUserInfoKey
        ] as? NSValue {
          let height = keyboardFrame.cgRectValue.height
          if properties.storedKeyboardHeight == 0 {
            properties.storedKeyboardHeight = max(
              height - properties.safeArea.bottom,
              0
            )
          }
        }
      }
      // picker sheet
      .sheet(isPresented: $properties.showPhotosPicker) {
        PhotosPicker(
          "",
          selection: $selectedPhotos,
          maxSelectionCount: 10,
          selectionBehavior: .continuous,
          preferredItemEncoding: .compatible
        )
        .photosPickerStyle(.inline)
        .photosPickerDisabledCapabilities([
          .stagingArea, .sensitivityAnalysisIntervention,
        ])
        .presentationDetents([.height(properties.keyboardHeight), .large])
        .presentationBackgroundInteraction(
          .enabled(upThrough: .height(properties.keyboardHeight))
        )  // allow whilst not expanded
      }
      .sheet(isPresented: $properties.showFilePicker) {
        DocumentPickerViewController { urls in
          print(urls)
        }
        .presentationBackground(.clear)
        .presentationDetents([.height(properties.keyboardHeight), .large])
        .presentationBackgroundInteraction(
          .enabled(upThrough: .height(properties.keyboardHeight))
        )
      }
      .onChange(of: isInputActive) {
        // dismiss picker when keyboard is activated
        if isInputActive {
          properties.showPhotosPicker = false
          properties.showFilePicker = false
        }
      }
      .onChange(of: properties.pickerShown) {
        // dismiss keyboard when picker is activated
        if properties.pickerShown {
          isInputActive = false
        }
      }
    #endif
  }

  #if os(iOS)
  var animatedKeyboardHeight: CGFloat {
    (properties.pickerShown || isInputActive)
      ? properties.keyboardHeight : 0
  }
  #endif
}

#if os(iOS)
  struct DocumentPickerViewController: UIViewControllerRepresentable {
    let callback: ([URL]) -> Void

    init(callback: @escaping ([URL]) -> Void) {
      self.callback = callback
    }

    func makeUIViewController(context: Context)
      -> UIDocumentPickerViewController
    {
      // open any files
      let controller = UIDocumentPickerViewController(
        forOpeningContentTypes: [.data]
      )
      controller.allowsMultipleSelection = true
      controller.shouldShowFileExtensions = true
      controller.delegate = context.coordinator
      controller.view?.backgroundColor = nil
      return controller
    }

    func updateUIViewController(
      _ uiViewController: UIDocumentPickerViewController,
      context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
      Coordinator(callback: callback)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
      let callback: ([URL]) -> Void

      init(callback: @escaping ([URL]) -> Void) {
        self.callback = callback
      }

      func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
      ) {
        self.callback(urls)
      }

      func documentPickerWasCancelled(
        _ controller: UIDocumentPickerViewController
      ) {}
    }
  }

  import FLEX

  #Preview {
    TestMessageView()
      .onAppear {
        FLEXManager.shared.showExplorer()
      }
  }
#endif
