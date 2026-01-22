//
//  UpdateCheck.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 22/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

#if os(iOS)

  extension View {
    func updateSheet() -> some View {
      self
        .modifier(UpdateSheetModifier())
    }
  }

  struct UpdateSheetModifier: ViewModifier {
    @State var update: UpdateMeta?
    
    struct UpdateMeta: Identifiable {
      var id: Int { latest }
      let current: Int
      let latest: Int
      let url: URL
    }

    func body(content: Content) -> some View {
      content
        .task {
          // get the SUFeedURL from info.plist, but replace appcast.xml with latest.json
          guard
            let feedURLString = Bundle.main.object(
              forInfoDictionaryKey: "SUFeedURL"
            ) as? String,
            let feedURL = URL(
              string: feedURLString.replacingOccurrences(
                of: "appcast.xml",
                with: "latest.json"
              )
            ),
            // get the current app build number from info.plist
            let currentBuildString = Bundle.main.object(
              forInfoDictionaryKey: "CFBundleVersion"
            ) as? String,
            let currentBuild = Int(currentBuildString)
          else {
            return
          }
          
          do {
            let (data, _) = try await URLSession.shared.data(from: feedURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let info = try decoder.decode(UpdateInfo.self, from: data)
            
            let ignoredBuild = UserDefaults.standard.integer(
              forKey: "Paicord.UpdateCheck.IgnoredBuild"
            )
            
            // compare the mac version with the current build number
            if info.ios.version > currentBuild, info.ios.version != ignoredBuild {
              self.update = .init(
                current: currentBuild, latest: info.ios.version,
                url: info.ios.url
              )
            }
          } catch {
            print("Failed to check for updates: \(error)")
          }
        }
        .sheet(item: $update) { info in
          UpdateCheckView(info: $update)
        }
    }

    //  {
    //    "commit": "10bced3",
    //    "published_at": "2026-01-22T00:32:03Z",
    //    "mac": {
    //      "version": "257",
    //      "url": "https://github.com/llsc12/Paicord/releases/download/paicord-nightly-21230871661/Paicord-macOS-10bced3.dmg"
    //    },
    //    "ios": {
    //      "version": "257",
    //      "url": "https://github.com/llsc12/Paicord/releases/download/paicord-nightly-21230871661/Paicord-iOS-10bced3.ipa"
    //    }
    //  }
    struct UpdateInfo: Decodable {
      let commit: String
      let publishedAt: Date
      let mac: PlatformInfo
      let ios: PlatformInfo

      struct PlatformInfo: Decodable {
        let version: Int  // commit count, monotonically increasing
        let url: URL

        init(from decoder: any Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          version =
            Int(try container.decode(String.self, forKey: .version)) ?? 0
          url = try container.decode(URL.self, forKey: .url)
        }

        enum CodingKeys: String, CodingKey {
          case version
          case url
        }
      }

      enum CodingKeys: String, CodingKey {
        case commit
        case publishedAt = "published_at"
        case mac
        case ios
      }
    }

    struct UpdateCheckView: View {
      @Environment(\.openURL) var openURL
      @Binding var info: UpdateMeta?

      var body: some View {
        ScrollView {
          VStack {
            Text("Update Available")
              .font(.title)
              .fontWeight(.semibold)
              .padding(.vertical, 8)

            VStack(spacing: 12) {
              Text(
                "A new version of Paicord is available! Head to [the releases page](https://github.com/llsc12/Paicord/releases/latest), or [the Discord server](https://discord.gg/fqhPGHPyaK) to download the latest version."
              )
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal)

              Text(
                "You're on build \(info?.current ?? 0), and the latest build is \(info?.latest ?? 0)."
              )
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal)
              .font(.subheadline)
            }
          }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
          VStack {
            Button {
              downloadNow()
            } label: {
              Text("Download IPA")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .font(.title2)
            .fontWeight(.semibold)
            
            Button {
              remindMeLater()
            } label: {
              Text("Remind Me Later")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.extraLarge)
            .font(.title2)
            .fontWeight(.semibold)
            
            Button("Skip this update") {
              skipThisUpdate()
            }
            .buttonStyle(.borderless)
            .controlSize(.large)
            .font(.title3)
            .fontWeight(.semibold)
            .padding([.horizontal, .top], 5)
          }
        }
        .maxWidth(.infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.thinMaterial)
      }

      func skipThisUpdate() {
        let defaults = UserDefaults.standard
        defaults.set(info?.latest, forKey: "Paicord.UpdateCheck.IgnoredBuild")
        self.info = nil
      }

      func remindMeLater() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Paicord.UpdateCheck.IgnoredBuild")
        self.info = nil
      }

      func downloadNow() {
        if let url = info?.url {
          openURL(url)
        }
        self.info = nil
      }
    }
  }

#else
extension View {
  func updateSheet() -> some View {
    self
  }
}

#endif
