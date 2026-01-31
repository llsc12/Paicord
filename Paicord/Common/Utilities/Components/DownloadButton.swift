//
//  DownloadButton.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 31/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import SwiftUIX

struct DownloadButton<T: Sendable>: View {
  enum DownloadState: Equatable {
    case inactive  // not pressed
    case pending  // pressed, waiting to start
    case downloading(progress: Progress)  // in progress
    case error(Error)  // failed
    case completed  // finished

    static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
      switch (lhs, rhs) {
      case (.inactive, .inactive): return true
      case (.pending, .pending): return true
      case (.downloading(let p1), .downloading(let p2)):
        return p1.fractionCompleted == p2.fractionCompleted
      case (.error, .error): return true
      case (.completed, .completed): return true
      default: return false
      }
    }
  }

  @State var downloadState: DownloadState = .inactive

  /// Passed into action to provide a way to report progress, safe to use from any thread
  public struct DownloadProxy {
    let onUpdate: (Progress?) -> Void
    let onReset: () -> Void
    func progress(_ progress: Progress?) {
      onUpdate(progress)
    }
    func reset() {
      onReset()
    }
  }

  // async throws func to run in a detached task
  var action: (DownloadProxy) async throws -> T
  var completion: ((DownloadProxy, T) -> Void)? = nil

  @State var pendingIndicatorAnimationTrigger = false
  @State var warningShown = false
  @State var warningCanHover = false
  @State var result: T?

  // stuff
  enum CompletionBehavior {
    case stayCompleted(allowsInteraction: Bool)
    case resetToInactive
  }
  
  var _errorTitle: String = "Download Failed"
  var downloadButtonSymbolName = "icloud.and.arrow.down"
  var completionButtonSymbolName = "checkmark.circle"
  var _completionBehavior: CompletionBehavior = .resetToInactive

  @ViewStorage var proxy: DownloadProxy?

  init(
    action: @Sendable @escaping (DownloadProxy) async throws -> T,
    completion: (@Sendable (DownloadProxy, T) -> Void)? = nil
  ) {
    self.action = action
    self.completion = completion
  }

  var body: some View {
    Button {
      if proxy == nil {
        self.proxy = DownloadProxy { progress in
          Task { @MainActor in
            withAnimation(.spring) {
              if let progress {
                downloadState = .downloading(progress: progress)
              } else {
                downloadState = .pending
              }
            }
          }
        } onReset: {
          Task { @MainActor in
            withAnimation(.spring) {
              downloadState = .inactive
            }
          }
        }
      }

      switch downloadState {
      case .inactive: startDownload()
      case .downloading: cancelDownload()
      case .error: downloadState = .inactive
      case .completed:
        switch _completionBehavior {
        case .stayCompleted(allowsInteraction: true):
          if let result {
            self.completion?(proxy!, result)
          }
        default: break
        }
      default: break
      }
    } label: {
      switch downloadState {
      case .inactive:
        Image(systemName: downloadButtonSymbolName)
          .resizable()
          .scaledToFit()
          .transition(
            .scale(scale: 0.8).combined(with: .opacity).animation(.spring)
          )
          .foregroundStyle(.primary.opacity(0.8))
      case .pending:
        Circle()
          .trim(from: 0, to: 0.8)
          .stroke(lineWidth: 2)
          .fill(.secondary)
          .transition(
            .scale(scale: 0.5).combined(with: .opacity).animation(.spring)
          )
          .animation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            $0
              .rotationEffect(
                .degrees(pendingIndicatorAnimationTrigger ? 360 : 0)
              )
          }
          .onAppear {
            pendingIndicatorAnimationTrigger = true
          }
          .onDisappear {
            pendingIndicatorAnimationTrigger = false
          }
      case .downloading(let progress):
        Circle()
          .trim(from: 0, to: CGFloat(progress.fractionCompleted))
          .stroke(lineWidth: 2)
          .fill(.tint)
          .rotationEffect(.degrees(-90))
          .overlay(
            Image(systemName: "stop.fill")
              .imageScale(.small)
              .foregroundStyle(.tint)
          )
      case .error(let error):
        Image(systemName: "exclamationmark.triangle.fill")
          .resizable()
          .scaledToFit()
          .foregroundStyle(.red)
          .transition(
            .scale(scale: 0.8).combined(with: .opacity).animation(.spring)
          )
          .popover(isPresented: $warningShown) {
            ScrollView {
              VStack(alignment: .leading) {
                Text(_errorTitle)
                  .font(.headline)
                Text(error.localizedDescription)
                  .font(.subheadline)
              }
            }
            .padding()
            .frame(maxWidth: 300)
          }
          .onAppear {
            // show warning for at least 3 seconds
            warningCanHover = false
            warningShown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
              warningShown = false
              warningCanHover = true
            }
          }
      case .completed:
        Image(systemName: completionButtonSymbolName)
          .resizable()
          .scaledToFit()
          .transition(
            .scale(scale: 0.8).combined(with: .opacity).animation(.spring)
          )
          .foregroundStyle(.primary.opacity(0.8))
          .task {
            switch _completionBehavior {
            case .resetToInactive:
              try? await Task.sleep(nanoseconds: 2_000_000_000)
              withAnimation(.spring) {
                downloadState = .inactive
              }
            default: break
            }
          }
      }
    }
    .buttonStyle(.borderless)
    .frame(width: 24, height: 24)
    .onHover(perform: { warningShown = $0 && warningCanHover })
    .disabled(
      {
        switch downloadState {
        case .inactive: return false
        case .downloading: return false
        case .error: return !warningCanHover
        case .completed:
          switch _completionBehavior {
          case .stayCompleted(allowsInteraction: false): return true
          default: return false
          }
        default: return true
        }
      }()
    )
  }

  @State var task: Task<Void, Never>? = nil

  private func startDownload() {
    // Reset rotation for new pending state
    downloadState = .pending
    task?.cancel()
    task = nil
    task = Task.detached {
      // also handle cancellation
      do {
        let result = try await action(proxy!)
        await MainActor.run {
          self.result = result
          downloadState = .completed
          completion?(proxy!, result)
        }
      } catch {
        if error is CancellationError { return }
        await MainActor.run { downloadState = .error(error) }
      }
    }
  }

  func cancelDownload() {
    task?.cancel()
    downloadState = .inactive
    warningCanHover = false
  }

  // initial modifiers
  /// Changes the download button symbol
  public func downloadSymbol(systemName: String) -> DownloadButton {
    var copy = self
    copy.downloadButtonSymbolName = systemName
    return copy
  }
  /// Changes the completion button symbol
  public func completionSymbol(systemName: String) -> DownloadButton {
    var copy = self
    copy.completionButtonSymbolName = systemName
    return copy
  }
  /// Changes the behavior after completion
  public func completionBehavior(_ behavior: CompletionBehavior)
    -> DownloadButton
  {
    var copy = self
    copy._completionBehavior = behavior
    return copy
  }
  /// Changes the error title shown in the popover
  public func errorTitle(_ title: String) -> DownloadButton {
    var copy = self
    copy._errorTitle = title
    return copy
  }
}

#Preview {
  DownloadButton { proxy in
    for i in 0...10 {
      try await Task.sleep(nanoseconds: 300_000_000)
      let progress = Progress(totalUnitCount: 10)
      progress.completedUnitCount = Int64(i)
      proxy.progress(progress)
    }
    return "Downloaded Result"
  } completion: { (proxy, result: String) in
    print("Completed with result: \(result)")
  }
  .padding()
}
