//
//  InputBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 17/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension ChatView {
  struct InputBar: View {
    @Environment(\.appState) var appState
    @Environment(\.gateway) var gw
    var vm: ChannelStore

    #if os(iOS)
      @Environment(\.safeAreaInsets) var safeAreaInsets
    #endif

    @FocusState private var isFocused: Bool
    @State var text: String = ""

    var body: some View {
      ZStack(alignment: .top) {
        HStack(alignment: .bottom, spacing: 8) {
          Button {

          } label: {
            Image(systemName: "plus")
              .imageScale(.large)
              .padding(7.5)
              .background(.regularMaterial)
              .clipShape(.circle)
          }
          .buttonStyle(.borderless)
          .tint(.primary)
          #if os(iOS)
            TextField("Message", text: $text, axis: .vertical)
              .textFieldStyle(.plain)
              .maxHeight(150)
              .fixedSize(horizontal: false, vertical: true)
              .disabled(appState.chatOpen == false)
              .padding(8)
              .padding(.horizontal, 4)
              .background(.regularMaterial)
              .clipShape(.rect(cornerRadius: 18))
              .focused($isFocused)
          #else
            TextView("Message", text: $text, submit: sendMessage)
              .padding(8)
              .background(.regularMaterial)
              .clipShape(.rect(cornerRadius: 18))
          #endif

          #if os(iOS)
            if text.isEmpty == false {
              Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                  .imageScale(.large)
                  .padding(5)
                  .foregroundStyle(.white)
                  .background(.primaryButton)
                  .clipShape(.circle)
              }
              .buttonStyle(.borderless)
              .foregroundStyle(.primaryButton)
              .transition(.move(edge: .trailing).combined(with: .opacity))
            }
          #endif
        }
        .padding([.horizontal, .bottom], 8)
        .padding(.top, 4)
        #if os(iOS)
          .animation(.default, value: text.isEmpty)
        #endif
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
            .padding(.bottom, isFocused ? 0 : (safeAreaInsets.bottom * -1))
            .animation(.default, value: isFocused)
          #endif
      }
    }

    private func sendMessage() {
      let msg = text.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !msg.isEmpty else { return }
      guard let channelId = appState.selectedChannel else { return }
      text = ""  // clear input field
      Task.detached {
        //      let message: Payloads.CreateMessage = try! .init(
        //        content: msg,
        //        nonce: .string(MessageSnowflake.makeFake(date: .now).rawValue),
        //        tts: false,
        //        message_reference: nil,
        //        sticker_ids: nil,
        //        files: nil,
        //        attachments: nil,
        //        flags: nil,
        //        poll: nil
        //      )
        do {
          _ = try await gw.client.createMessage(
            channelId: channelId,
            payload: .init(
              content: msg,
              nonce: .string(MessageSnowflake.makeFake(date: .now).rawValue)
            )
          ).guardSuccess()
        } catch {
          await MainActor.run {
            self.appState.error = error
          }
        }
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
  extension EnvironmentValues {
    fileprivate var safeAreaInsets: EdgeInsets {
      self[SafeAreaInsetsKey.self]
    }
  }

  private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
      UIApplication.shared.keyWindow?.safeAreaInsets.swiftUIInsets
        ?? EdgeInsets()
    }
  }

  extension UIEdgeInsets {
    fileprivate var swiftUIInsets: EdgeInsets {
      EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
  }

  extension UIApplication {
    fileprivate var keyWindow: UIWindow? {
      connectedScenes
        .compactMap {
          $0 as? UIWindowScene
        }
        .flatMap {
          $0.windows
        }
        .first {
          $0.isKeyWindow
        }
    }
  }
#endif
