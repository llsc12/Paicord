//
//  InputBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 17/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import PhotosUI
import SwiftUIX

extension ChatView {
  struct InputBar: View {
    static var inputVMs: [ChannelSnowflake: InputVM] = [:]
    @Environment(\.appState) var appState
    @Environment(\.gateway) var gw
    @Environment(\.theme) var theme
    var vm: ChannelStore
    @State var inputVM: InputVM
    
    static func vm(for channel: ChannelStore) -> InputVM {
      if let existingVM = InputBar.inputVMs[channel.channelId] {
        return existingVM
      } else {
        let newVM = InputVM(channelStore: channel)
        InputBar.inputVMs[channel.channelId] = newVM
        return newVM
      }
    }

    init(vm: ChannelStore) {
      self.vm = vm
      self._inputVM = State(initialValue: InputBar.vm(for: vm))
    }

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

      @State var pickersClosedWhenChatClosed: (photos: Bool, files: Bool) = (
        false, false
      )
      @State var cameraPickerPresented: Bool = false
    #else
    @State private var fileImporterPresented: Bool = false
    #endif
    
    @FocusState private var isFocused: Bool
    @State var filesRemovedDuringSelection: Error? = nil

    enum SelectionError: LocalizedError {
      case filesPastLimit(limit: Int)
      case filesEmpty

      var errorDescription: String? {
        switch self {
        case .filesPastLimit(let limit):
          let formatter = ByteCountFormatter()
          formatter.allowedUnits = [.useBytes, .useKB, .useMB]
          formatter.countStyle = .file
          let formattedLimit = formatter.string(fromByteCount: Int64(limit))
          return "Please keep files under \(formattedLimit)."
        case .filesEmpty:
          return "Empty files cannot be uploaded."
        }
      }
    }

    var body: some View {
      VStack {
        ZStack(alignment: .top) {
          VStack {
            if inputVM.uploadItems.isEmpty == false {
              AttachmentPreviewBar(inputVM: inputVM)
                .frame(height: 60)
            }
            
            if inputVM.messageAction != nil {
              messageActionBar
                .padding(.bottom, -4)
                .transition(
                  .offset(y: 25)
                  .combined(with: .opacity)
                )
            }

            messageInputBar
          }

          TypingIndicatorBar(vm: vm)
            .shadow(color: .black, radius: 10)
            .padding(.top, -18)  // away from bar
        }
        .background {
          VariableBlurView()
            .rotationEffect(.degrees(180))
            // extend upwards slightly
            .padding(.top, -8 + (vm.typingTimeoutTokens.isEmpty ? 0 : -10))
            #if os(iOS)
              .padding(
                .bottom,
                isFocused ? 0 : (properties.safeArea.bottom * -1)
              )
              .animation(.default, value: isFocused)
            #endif
        }
        .ignoresSafeArea(.container, edges: .horizontal)
      }
      .animation(.default, value: inputVM.messageAction.debugDescription)
      .onFileDrop(
        delegate: .init(onDrop: { droppedItems in
          let files = droppedItems.compactMap(\.loadedURL)
          // now do just like the file picker
          inputVM.selectedFiles = files.compactMap { url in
            var url: URL? = url
            let canAccess =
              url?.startAccessingSecurityScopedResource() ?? false
            defer {
              if canAccess {
                url?.stopAccessingSecurityScopedResource()
              }
            }
            // check filesize
            let fileSize =
              (try? url?.resourceValues(forKeys: [.fileSizeKey])
                .fileSize)
              ?? 0
            // discord wont let you upload empty files.
            if fileSize == 0 {
              url = nil
              self.filesRemovedDuringSelection =
                InputBar.SelectionError.filesEmpty
            }
            let uploadMeta = gw.user.premiumKind.fileUpload(
              size: fileSize,
              to: vm
            )
            if uploadMeta.allowed == false {
              url = nil
              self.filesRemovedDuringSelection =
                InputBar.SelectionError.filesPastLimit(
                  limit: uploadMeta.limit
                )
            }

            return url
          }
        })
      )
    }
    
    @ViewBuilder
    var messageInputBar: some View {
      HStack(alignment: .bottom, spacing: 8) {
        mediaPickerButton

        textField
      }
      .padding([.horizontal, .bottom], 8)
      .padding(.top, 4)
      .geometryGroup()
      #if os(iOS)
        .padding(.bottom, animatedKeyboardHeight)
        .animation(properties.animation, value: animatedKeyboardHeight)
        .animation(properties.animation, value: inputVM.content.isEmpty)
        .animation(properties.animation, value: inputVM.uploadItems.isEmpty)
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
        }  // get kb height
        .sheet(isPresented: $properties.showPhotosPicker) {
          PhotosPicker(
            "",
            selection: $inputVM.selectedPhotos,
            maxSelectionCount: 10,
            selectionBehavior: .continuous,
            preferredItemEncoding: .compatible
          )
          .photosPickerStyle(.inline)
          .photosPickerDisabledCapabilities([
            .stagingArea, .sensitivityAnalysisIntervention,
          ])
          .presentationDetents([
            .height(properties.keyboardHeight), .large,
          ])
          .presentationBackgroundInteraction(
            .enabled(upThrough: .height(properties.keyboardHeight))
          )  // allow whilst not expanded
        }
        .sheet(isPresented: $properties.showFilePicker) {
          DocumentPickerViewController { urls in
            inputVM.selectedFiles = urls.compactMap { url in
              var url: URL? = url
              let canAccess =
                url?.startAccessingSecurityScopedResource() ?? false
              defer {
                if canAccess {
                  url?.stopAccessingSecurityScopedResource()
                }
              }
              // check filesize
              let fileSize =
                (try? url?.resourceValues(forKeys: [.fileSizeKey])
                  .fileSize)
                ?? 0
              // discord wont let you upload empty files.
              if fileSize == 0 {
                url = nil
                self.filesRemovedDuringSelection =
                  SelectionError.filesEmpty
              }
              let uploadMeta = gw.user.premiumKind.fileUpload(
                size: fileSize,
                to: vm
              )
              if uploadMeta.allowed == false {
                url = nil
                self.filesRemovedDuringSelection =
                  SelectionError.filesPastLimit(
                    limit: uploadMeta.limit
                  )
              }

              return url
            }
          }
          .presentationBackground(.clear)
          .presentationDetents([
            .height(properties.keyboardHeight), .large,
          ])
          .presentationBackgroundInteraction(
            .enabled(upThrough: .height(properties.keyboardHeight))
          )
        }
        .alert(
          "Some files were not added",
          isPresented: Binding(
            get: { self.filesRemovedDuringSelection != nil },
            set: { newValue in
              if newValue == false {
                self.filesRemovedDuringSelection = nil
              }
            }
          )
        ) {
          Button("OK", role: .cancel) {}
        } message: {
          if let error = filesRemovedDuringSelection {
            Text(error.localizedDescription)
          } else {
            Text("idk bro ur files cooked")
          }
        }  // show errors for removed files
        .onChange(of: isFocused) {
          if isFocused {
            properties.showPhotosPicker = false
            properties.showFilePicker = false
          }
        }  // dismiss picker when keyboard is activated
        .onChange(of: properties.pickerShown) {
          if properties.pickerShown {
            isFocused = false
          }
        }  // dismiss keyboard when picker is activated
        .onChange(of: appState.chatOpen) {
          if appState.chatOpen == false {
            pickersClosedWhenChatClosed.photos =
              properties.showPhotosPicker
            pickersClosedWhenChatClosed.files = properties.showFilePicker
            properties.showPhotosPicker = false
            properties.showFilePicker = false
          } else {
            // restore pickers if they were open before chat closed
            if pickersClosedWhenChatClosed.photos {
              properties.showPhotosPicker = true
            }
            if pickersClosedWhenChatClosed.files {
              properties.showFilePicker = true
            }
            pickersClosedWhenChatClosed = (false, false)
          }
        }  // dismiss pickers when chat is closed
      #else
        .fileImporter(isPresented: $fileImporterPresented, allowedContentTypes: [.content], allowsMultipleSelection: true) { result in
          do {
            let urls = try result.get()
            inputVM.selectedFiles = urls.compactMap { url in
              var url: URL? = url
              let canAccess =
                url?.startAccessingSecurityScopedResource() ?? false
              defer {
                if canAccess {
                  url?.stopAccessingSecurityScopedResource()
                }
              }
              // check filesize
              let fileSize =
                (try? url?.resourceValues(forKeys: [.fileSizeKey])
                  .fileSize)
                ?? 0
              // discord wont let you upload empty files.
              if fileSize == 0 {
                url = nil
                self.filesRemovedDuringSelection =
                  SelectionError.filesEmpty
              }
              let uploadMeta = gw.user.premiumKind.fileUpload(
                size: fileSize,
                to: vm
              )
              if uploadMeta.allowed == false {
                url = nil
                self.filesRemovedDuringSelection =
                  SelectionError.filesPastLimit(
                    limit: uploadMeta.limit
                  )
              }

              return url
            }
          } catch {
            print("Failed to pick files: \(error)")
          }
        }
        .fileDialogImportsUnresolvedAliases(false)
      #endif
    }

    @ViewBuilder
    var mediaPickerButton: some View {
      #if os(iOS)
        if properties.pickerShown {
          Button {
            properties.showFilePicker = false
            properties.showPhotosPicker = false
          } label: {
            Image(systemName: "plus")
              .imageScale(.large)
              .padding(7.5)
              .background(.regularMaterial)
              .clipShape(.circle)
              .rotationEffect(.degrees(45))
          }
          .buttonStyle(.borderless)
          .tint(.primary)
        } else {
          Menu {
            Button {
              properties.showPhotosPicker = false
              properties.showFilePicker = false

            } label: {
              Label("Camera", systemImage: "camera")
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
            Menu {
              Button {
              } label: {
                Text("1")
              }
            } label: {
              Label("Apps", systemImage: "puzzle.fill")
            }
          } label: {
            Image(systemName: "plus")
              .imageScale(.large)
              .padding(7.5)
              .background(.regularMaterial)
              .clipShape(.circle)
          }
          .buttonStyle(.borderless)
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
            self.fileImporterPresented = true
          } label: {
            Label("Upload Files", systemImage: "doc.on.doc")
          }
        } label: {
          Image(systemName: "plus")
            .imageScale(.large)
            .padding(7.5)
            .background(.regularMaterial)
            .clipShape(.circle)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
      #endif
    }
    
    @ViewBuilder
    var textField: some View {
      HStack {
#if os(iOS)
        TextField("Message", text: $inputVM.content, axis: .vertical)
          .textFieldStyle(.plain)
          .maxHeight(150)
          .fixedSize(horizontal: false, vertical: true)
          .disabled(appState.chatOpen == false)
          .padding(.vertical, 7)
          .padding(.horizontal, 12)
          .focused($isFocused)
#else
        TextView("Message", text: $inputVM.content, submit: sendMessage)
          .padding(8)
#endif
        Button {
        } label: {
          Image(systemName: "face.smiling")
            .imageScale(.large)
            .padding(.trailing, 6)
        }
        .buttonStyle(.borderless)
        .tint(.secondary)
      }
      .background(.regularMaterial)
      .clipShape(.rect(cornerRadius: 18))

      #if os(iOS)
        if inputVM.content.isEmpty == false || inputVM.uploadItems.isEmpty == false {
          Button(action: sendMessage) {
            Image(systemName: "paperplane.fill")
              .imageScale(.large)
              .padding(5)
              .foregroundStyle(.white)
              .background(theme.common.primaryButton)
              .clipShape(.circle)
          }
          .buttonStyle(.borderless)
          .foregroundStyle(theme.common.primaryButton)
          .transition(
            .move(edge: .trailing).combined(with: .opacity).animation(.default)
          )
        }
      #endif
    }

    #if os(iOS)
      var animatedKeyboardHeight: CGFloat {
        (properties.pickerShown || isFocused)
          ? properties.keyboardHeight : 0
      }
    #endif
    
    @ViewBuilder
    var messageActionBar: some View {
      HStack {
        if let action = inputVM.messageAction {
          switch action {
          case .reply(let message, _):
            let author: Text = {
              guard let author = message.author else { return Text("Unknown User").bold() }
              if let member = vm.guildStore?.members[author.id] ?? message.member {
                return Text(member.nick ?? author.global_name ?? author.username).bold()
              } else {
                return Text(author.global_name ?? author.username).bold()
              }
            }()
            Text("Replying to \(author)")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          case .edit(_):
            Text("Editing Message")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          Spacer()
          if case .reply(let message, let mention) = action {
            Button {
              inputVM.messageAction = .reply(message: message, mention: !mention)
            } label: {
              HStack(spacing: 2) {
                Image(systemName: "at")
                Text(mention ? "ON" : "OFF")
              }
              .font(.headline.bold())
            }
            .buttonStyle(.borderless)
            .tint(mention ? nil : .secondary)
          }
            
          Button {
            inputVM.messageAction = nil
          } label: {
            Image(systemName: "xmark.circle.fill")
              .imageScale(.large)
          }
          .buttonStyle(.borderless)
          .tint(.secondary)
        }
      }
      .padding(.horizontal, 6)
      .padding(.leading, 4)
      .padding(.vertical, 4)
      .background(.thinMaterial)
      .clipShape(.capsule)
      .padding(.horizontal, 8)
    }

    private func sendMessage() {
      let msg = inputVM.content.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !msg.isEmpty || inputVM.uploadItems.isEmpty == false else {
        return
      }
      guard let channelId = appState.selectedChannel else { return }
      // create a copy of the vm
      let toSend = inputVM.copy()
      inputVM.reset()
      Task {
        gw.messageDrain.send(toSend, in: channelId)
      }
    }

  }

  #if os(macOS)
    private struct TextView: View {
      var prompt: String
      @Binding var text: String
      var submit: () -> Void

      init(
        _ prompt: String,
        text: Binding<String>,
        submit: @escaping () -> Void = {}
      ) {
        self.prompt = prompt
        self._text = text
        self.submit = submit
      }

      var body: some View {
        _TextView(text: $text, onSubmit: submit)
          .overlay(alignment: .leading) {
            if text.isEmpty {
              Text(prompt)
                .foregroundStyle(.secondary)
                .padding(5)
                .allowsHitTesting(false)
            }
          }
      }

      private struct _TextView: NSViewRepresentable {
        @Binding var text: String
        var onSubmit: () -> Void
        var maxHeight: CGFloat = 150

        func makeNSView(context: Context) -> NSScrollView {
          let textStorage = NSTextStorage()
          let layoutManager = NSLayoutManager()
          textStorage.addLayoutManager(layoutManager)
          let textContainer = NSTextContainer()
          layoutManager.addTextContainer(textContainer)

          let textView = SubmissiveTextView(
            frame: .zero,
            textContainer: textContainer
          )
          textView.isEditable = true
          textView.isRichText = false
          textView.isVerticallyResizable = true
          textView.isHorizontallyResizable = false
          textView.textContainer?.widthTracksTextView = true
          textView.textContainerInset = .zero
          textView.drawsBackground = false
          textView.typingAttributes = [
            .font: preferredBodyFont(),
            .foregroundColor: labelColor(),
          ]
          textView.delegate = context.coordinator
          textView.onSubmit = onSubmit
          textView.minSize = NSSize(width: 0, height: 0)
          textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
          )

          let scrollView = NSScrollView()
          scrollView.documentView = textView
          scrollView.hasVerticalScroller = true
          scrollView.drawsBackground = false
          scrollView.borderType = .noBorder

          textView.autoresizingMask = [.width]

          return scrollView
        }

        func sizeThatFits(
          _ proposal: ProposedViewSize,
          nsView: NSScrollView,
          context: Context
        ) -> CGSize? {
          guard let textView = nsView.documentView as? NSTextView else {
            return nil
          }
          if let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer
          {
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let contentHeight =
              usedRect.height + textView.textContainerInset.height * 2
            return CGSize(
              width: proposal.width ?? usedRect.width,
              height: min(contentHeight, maxHeight)
            )
          }
          return nil
        }

        func updateNSView(_ scrollView: NSScrollView, context: Context) {
          guard let textView = scrollView.documentView as? NSTextView else {
            return
          }

          if textView.string != text {
            textView.string = text
          }
        }

        func makeCoordinator() -> Coordinator {
          Coordinator(self)
        }

        class Coordinator: NSObject, NSTextViewDelegate {
          var parent: _TextView

          init(_ parent: _TextView) {
            self.parent = parent
          }

          func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
              return
            }
            parent.text = textView.string
          }
        }

        class SubmissiveTextView: NSTextView {
          var onSubmit: (() -> Void)?
          
          override var acceptableDragTypes: [NSPasteboard.PasteboardType] {
            [
              NSPasteboard.PasteboardType.string,
              NSPasteboard.PasteboardType.rtf,
              NSPasteboard.PasteboardType.rtfd,
              NSPasteboard.PasteboardType.html
            ]
          }

          override func keyDown(with event: NSEvent) {
            if event.keyCode == 36 {  // Return key
              let shiftPressed = event.modifierFlags.contains(.shift)
              if !shiftPressed {
                onSubmit?()
                return
              }
            }
            super.keyDown(with: event)
          }
        }

        func preferredBodyFont() -> Any {
          #if os(macOS)
            return NSFont.systemFont(ofSize: NSFont.systemFontSize)
          #else
            let font = UIFont.preferredFont(forTextStyle: .body)
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
          #endif
        }

        func labelColor() -> Any {
          #if os(macOS)
            return NSColor.labelColor
          #else
            return UIColor.label
          #endif
        }
      }
    }
  #elseif os(iOS)

  #endif
}

#if os(iOS)
  private struct DocumentPickerViewController: UIViewControllerRepresentable {
    @Environment(\.colorScheme) var colorScheme
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
      // it appears the color theme isn't inherited properly.
      controller.overrideUserInterfaceStyle = .init(colorScheme)
      return controller
    }

    func updateUIViewController(
      _ uiViewController: UIDocumentPickerViewController,
      context: Context
    ) {
      uiViewController.overrideUserInterfaceStyle = .init(colorScheme)
    }

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

//  import FLEX
//
//  #Preview {
//    TestMessageView()
//      .onAppear {
//        FLEXManager.shared.showExplorer()
//      }
//  }
#endif
