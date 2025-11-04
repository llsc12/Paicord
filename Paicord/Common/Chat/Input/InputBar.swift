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
    @Environment(PaicordAppState.self) var appState
    @Environment(GatewayStore.self) var gw
  var vm: ChannelStore
    
    #if os(iOS)
      @Environment(\.safeAreaInsets) var safeAreaInsets
    #endif

    @FocusState private var isFocused: Bool
    @State var text: String = ""

    var body: some View {
      VStack(spacing: 0) {
        TypingIndicatorBar(vm: vm)
          .shadow(color: .black, radius: 10)
        
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
              .background(.regularMaterial)
              .clipShape(.rect(cornerRadius: 16))
              .focused($isFocused)
          #else
            TextView("Message", text: $text, submit: sendMessage)
              .padding(8)
              .background(.regularMaterial)
              .clipShape(.rect(cornerRadius: 16))
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
      }
        .background {
          VariableBlurView(blurRadius: 10)
          .rotationEffect(.degrees(180))
  #if os(iOS)
          .padding(.bottom, isFocused ? 0 : (safeAreaInsets.bottom * -1) )
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
          let scrollView = NSTextView.scrollableTextView()
          let textView = scrollView.documentView as! NSTextView

          textView.isEditable = true
          textView.isRichText = false
          textView.isVerticallyResizable = true
          textView.isHorizontallyResizable = false
          textView.textContainer?.widthTracksTextView = true
          textView.textContainerInset = .zero
          textView.delegate = context.coordinator
          textView.drawsBackground = false
          textView.typingAttributes = [
            .font: preferredBodyFont(),
            .foregroundColor: labelColor(),
          ]

          scrollView.hasVerticalScroller = true
          scrollView.drawsBackground = false
          scrollView.borderType = .noBorder

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

        // horrid way of doing this
        func textUpdated(
          oldText: String,
          newText: String
        ) {
          // detect if a new line was added
          if newText.count > oldText.count,
            newText.hasSuffix("\n")
          {
            // return early if shift key is pressed (to allow new lines)
            let shiftPressed = NSEvent.modifierFlags.contains(.shift)
            if shiftPressed { return }
            // trim new lines and submit
            text = newText.trimmingCharacters(in: .newlines)
            onSubmit()
          }
        }

        func makeCoordinator() -> Coordinator {
          Coordinator(self)
        }

        class Coordinator: NSObject, NSTextViewDelegate {
          var parent: _TextView
          private var lastText: String

          init(_ parent: _TextView) {
            self.parent = parent
            self.lastText = parent.text
          }

          func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
              return
            }

            let oldText = lastText
            let newText = textView.string
            lastText = newText

            parent.text = newText

            parent.textUpdated(oldText: oldText, newText: newText)
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
