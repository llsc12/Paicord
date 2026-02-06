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

#if os(iOS)
  import MijickCamera
#endif

extension ChatView {
  struct InputBar: View {
    static var inputVMs: [ChannelSnowflake: InputVM] = [:]
    @Environment(\.appState) var appState
    @Environment(\.gateway) var gw
    @Environment(\.theme) var theme
    var vm: ChannelStore
    @State var inputVM: InputVM
    @ViewStorage private var isManualUpdate = false

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
        var showEmojiPicker: Bool = false

        var keyboardHeight: CGFloat {
          storedKeyboardHeight == 0 ? 300 : storedKeyboardHeight
        }

        var pickerShown: Bool {
          showPhotosPicker || showFilePicker || showEmojiPicker
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

      @State var pickersClosedWhenChatClosed:
        (photos: Bool, files: Bool, emoji: Bool, keyboardFocused: Bool) = (
          false, false, false, false
        )
      @State var cameraPickerPresented: Bool = false
    #else
      @State private var fileImporterPresented: Bool = false
    #endif

    @State private var isFocused: Bool = false
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
          .padding(.top, 4)

          TypingIndicatorBar(vm: vm)
            .background(.bar)
            .padding(.top, -18)  // away from bar
        }
        .background(.bar)
      }
      #if os(iOS)
        .animation(properties.animation, value: animatedKeyboardHeight)
        .animation(properties.animation, value: inputVM.content.isEmpty)
        .animation(properties.animation, value: inputVM.uploadItems.isEmpty)
      #endif
      .animation(.default, value: inputVM.messageAction.debugDescription)
      .animation(.default, value: inputVM.uploadItems)
      .onFileDrop(
        delegate: .init(onDrop: { droppedItems in
          let files = droppedItems.compactMap(\.loadedURL)
          inputVM.selectedFiles = filterUploadableURLs(files)
        })
      )
    }

    @ViewBuilder
    var messageInputBar: some View {
      HStack(alignment: .bottom, spacing: 8) {
        mediaPickerButton
          .disabled(
            {
              switch inputVM.messageAction {
              case .edit: return true
              default: return false
              }
            }()
          )

        textField
      }
      .padding([.horizontal, .bottom], 8)
      .padding(.top, 4)
      .geometryGroup()
      #if os(iOS)
        .padding(.bottom, animatedKeyboardHeight)
        .onReceive(
          NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillChangeFrameNotification
          )
        ) { userInfo in
          guard isFocused else { return }
          if let keyboardFrame = userInfo.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
          ] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            properties.storedKeyboardHeight = max(
              height - properties.safeArea.bottom,
              0
            )
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
            inputVM.selectedFiles = filterUploadableURLs(urls)
          }
          .presentationBackground(.clear)
          .presentationDetents([
            .height(properties.keyboardHeight), .large,
          ])
          .presentationBackgroundInteraction(
            .enabled(upThrough: .height(properties.keyboardHeight))
          )
        }
        .sheet(isPresented: $properties.showEmojiPicker) {
          EmojiPicker()
          .presentationDetents([
            .height(properties.keyboardHeight), .large,
          ])
          .presentationBackgroundInteraction(
            .enabled(upThrough: .height(properties.keyboardHeight))
          )
        }
        .fullScreenCover(isPresented: $cameraPickerPresented) {
          MCamera()
          .setCameraOutputType(.photo)
          .setCloseMCameraAction(closeMCameraAction)
          .onImageCaptured(onImageCaptured)
          .onVideoCaptured(onVideoCaptured)
          .startSession()
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
          guard !isManualUpdate else { return }
          if isFocused {
            properties.showPhotosPicker = false
            properties.showFilePicker = false
            properties.showEmojiPicker = false
          }
        }  // dismiss picker when keyboard is activated
        .onChange(of: properties.pickerShown) {
          guard !isManualUpdate else { return }
          if properties.pickerShown {
            isFocused = false
          }
        }  // dismiss keyboard when picker is activated
        .onChange(of: appState.chatOpen) {
          if appState.chatOpen == false {
            pickersClosedWhenChatClosed.photos =
              properties.showPhotosPicker
            pickersClosedWhenChatClosed.files = properties.showFilePicker
            pickersClosedWhenChatClosed.emoji = properties.showEmojiPicker
            pickersClosedWhenChatClosed.keyboardFocused = isFocused
            properties.showPhotosPicker = false
            properties.showFilePicker = false
            properties.showEmojiPicker = false
            isFocused = false
          } else {
            // restore pickers if they were open before chat closed
            if pickersClosedWhenChatClosed.photos {
              properties.showPhotosPicker = true
            }
            if pickersClosedWhenChatClosed.files {
              properties.showFilePicker = true
            }
            if pickersClosedWhenChatClosed.emoji {
              properties.showEmojiPicker = true
            }
            if pickersClosedWhenChatClosed.keyboardFocused {
              isFocused = true
            }
            pickersClosedWhenChatClosed = (false, false, false, false)
          }
        }  // dismiss pickers when chat is closed
      #else
        .fileImporter(
          isPresented: $fileImporterPresented,
          allowedContentTypes: [.content],
          allowsMultipleSelection: true
        ) { result in
          do {
            let urls = try result.get()
            inputVM.selectedFiles = filterUploadableURLs(urls)
          } catch {
            print("Failed to pick files: \(error)")
          }
        }
        .fileDialogImportsUnresolvedAliases(false)
      #endif
    }

    @Namespace private var mediaPickerNamespace

    @ViewBuilder
    var mediaPickerButton: some View {
      #if os(iOS)
        if properties.pickerShown {
          Button {
            properties.showFilePicker = false
            properties.showPhotosPicker = false
            properties.showEmojiPicker = false
            // refocus keyboard
            isFocused = true
          } label: {
            Image(systemName: "plus")
              .imageScale(.large)
              .padding(7.5)
              .background(.background.secondary.opacity(0.8))
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
              properties.showEmojiPicker = false
              self.cameraPickerPresented = true
            } label: {
              Label("Camera", systemImage: "camera")
            }
            Button {
              properties.showFilePicker = false
              properties.showEmojiPicker = false
              properties.showPhotosPicker = true
            } label: {
              Label("Upload Photos", systemImage: "photo.on.rectangle")
            }
            Button {
              properties.showPhotosPicker = false
              properties.showEmojiPicker = false
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
              Label("Apps", systemImage: "puzzlepiece.fill")
            }
          } label: {
            Image(systemName: "plus")
              .imageScale(.large)
              .padding(7.5)
              .background(.background.secondary.opacity(0.8))
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
              Text(verbatim: "1")
            }
          } label: {
            Label("Apps", systemImage: "puzzlepiece.fill")
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
            .background(.background.secondary.opacity(0.8))
            .clipShape(.circle)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
      #endif
    }

    @ViewBuilder
    var textField: some View {
      HStack(alignment: .bottom) {
        #if os(iOS)
          PastableTextField(
            placeholder: "Message\(vm.channel?.name.map { " #\($0)" } ?? "")",
            text: $inputVM.content,
            isFocused: $isFocused,
            onPasteFiles: handlePastedFiles
          )
          .padding(.vertical, 7)
          .padding(.horizontal, 12)
        #else
          TextView(
            "Message\(vm.channel?.name.map { " #\($0)" } ?? "")",
            text: $inputVM.content,
            submit: sendMessage,
            onPasteFiles: handlePastedFiles
          )
          .padding(8)
        #endif
        Button {
          #if os(iOS)
            isManualUpdate = true
            if !properties.showEmojiPicker {
              properties.showEmojiPicker = true
              isFocused = false
            } else {
              properties.showEmojiPicker = false
              properties.showFilePicker = false
              properties.showPhotosPicker = false
              isFocused = true
            }
            isManualUpdate = false
          #endif
        } label: {
          Image(systemName: "face.smiling")
            .imageScale(.large)
            .padding(.trailing, 6)
        }
        .buttonStyle(.borderless)
        .tint(.secondary)
        .padding(.vertical, 6)
      }
      .background(.background.secondary.opacity(0.8))
      .clipShape(.rect(cornerRadius: 18))

      #if os(iOS)
        if inputVM.content.isEmpty == false
          || inputVM.uploadItems.isEmpty == false
        {
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
              guard let author = message.author else {
                return Text("Unknown User").bold()
              }
              if let member = vm.guildStore?.members[author.id]
                ?? message.member
              {
                return Text(
                  member.nick ?? author.global_name ?? author.username
                ).bold()
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
              inputVM.messageAction = .reply(
                message: message,
                mention: !mention
              )
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
      .background(.background.secondary.opacity(0.8))
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

    private func filterUploadableURLs(_ urls: [URL]) -> [URL] {
      return urls.compactMap { originalURL in
        var url: URL? = originalURL
        let canAccess = url?.startAccessingSecurityScopedResource() ?? false
        defer {
          if canAccess {
            url?.stopAccessingSecurityScopedResource()
          }
        }

        let fileSize =
          (try? url?.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        if fileSize == 0 {
          url = nil
          self.filesRemovedDuringSelection = SelectionError.filesEmpty
        }

        let uploadMeta = gw.user.premiumKind.fileUpload(size: fileSize, to: vm)
        if uploadMeta.allowed == false {
          url = nil
          self.filesRemovedDuringSelection = SelectionError.filesPastLimit(
            limit: uploadMeta.limit
          )
        }

        return url
      }
    }

    private func handlePastedFiles(_ urls: [URL]) {
      let tempDir = FileManager.default.temporaryDirectory
      for url in urls {
        if url.path.hasPrefix(tempDir.path) {
          inputVM.trackTempFile(url)
        }
      }
      inputVM.selectedFiles = filterUploadableURLs(urls)
    }

    #if os(iOS)
      func closeMCameraAction() {
        self.cameraPickerPresented = false
      }
      func onImageCaptured(_ image: UIImage, _ controller: MCamera.Controller) {
        Task {
          let tempDir = FileManager.default.temporaryDirectory
          let fileURL = tempDir.appendingPathComponent(
            UUID().uuidString + ".png"
          )
          if let imageData = image.pngData() {
            do {
              try imageData.write(to: fileURL)
              inputVM.trackTempFile(fileURL)
              inputVM.selectedFiles.append(fileURL)
            } catch {
              print("Failed to save captured image: \(error)")
            }
          }
          controller.closeMCamera()
        }
      }
      func onVideoCaptured(_ videoURL: URL, _ controller: MCamera.Controller) {
        Task {
          let newVideoURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
              UUID().uuidString + ".mov"
            )
          try? FileManager.default.moveItem(
            at: videoURL,
            to: newVideoURL
          )
          inputVM.trackTempFile(newVideoURL)
          inputVM.selectedFiles.append(newVideoURL)

          controller.closeMCamera()
        }
      }
    #endif
  }
}
