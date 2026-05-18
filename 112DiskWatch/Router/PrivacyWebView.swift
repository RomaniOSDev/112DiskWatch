//
//  PrivacyWebView.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import SwiftUI
import WebKit

struct HostedLinkBrowser: View {
    let urlString: String
    var onFailure: () -> Void
    var onSuccess: (() -> Void)? = nil

    @State private var webView: WKWebView = WKWebView()
    @State private var canGoBack: Bool = false
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        webView.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(canGoBack ? .white : .gray)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                    .disabled(!canGoBack)

                    Spacer()

                    Button(action: {
                        webView.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 60)
                .background(Color.black)

                WKHostBridge(
                    webView: webView,
                    urlString: urlString,
                    canGoBack: $canGoBack,
                    isLoading: $isLoading,
                    onFailure: onFailure,
                    onSuccess: onSuccess
                )
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)

            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                }
            }
        }
    }
}

enum ExternalSchemeLane {
    case mail
    case phone
    case text
}

struct WKHostBridge: UIViewRepresentable {
    let webView: WKWebView
    let urlString: String
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    var onFailure: () -> Void
    var onSuccess: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .black
        webView.isOpaque = false

        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.allowsBackForwardNavigationGestures = true

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> BrowserSessionObserver {
        BrowserSessionObserver(parent: self)
    }

    final class BrowserSessionObserver: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WKHostBridge
        private var failureCalled = false

        private static let mailSchemeBytes: [UInt8] = [0x2A, 0x26, 0x2E, 0x2B, 0x33, 0x28]
        private static let telSchemeBytes: [UInt8] = [0x33, 0x22, 0x2B]
        private static let smsSchemeBytes: [UInt8] = [0x34, 0x2A, 0x34]

        private var externalSchemes: [String] {
            [
                RouteLiteralDecoder.reveal(Self.mailSchemeBytes),
                RouteLiteralDecoder.reveal(Self.telSchemeBytes),
                RouteLiteralDecoder.reveal(Self.smsSchemeBytes)
            ]
        }

        init(parent: WKHostBridge) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                if SessionRouteStore.shared.savedUrl == nil && !failureCalled {
                    if (400...599).contains(httpResponse.statusCode) {
                        failureCalled = true
                        SessionRouteStore.shared.hasShownContentView = true
                        decisionHandler(.cancel)

                        DispatchQueue.main.async {
                            self.parent.onFailure()
                        }
                        return
                    }
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                if externalSchemes.contains(url.scheme ?? "") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.canGoBack = webView.canGoBack
            parent.isLoading = false

            if SessionRouteStore.shared.savedUrl == nil {
                if let currentUrl = webView.url?.absoluteString {
                    SessionRouteStore.shared.savedUrl = currentUrl
                    SessionRouteStore.shared.hasSuccessfulWebViewLoad = true
                    DispatchQueue.main.async {
                        self.parent.onSuccess?()
                    }
                }
            } else {
                SessionRouteStore.shared.hasSuccessfulWebViewLoad = true
                DispatchQueue.main.async {
                    self.parent.onSuccess?()
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false

            if SessionRouteStore.shared.savedUrl == nil && !failureCalled {
                failureCalled = true

                SessionRouteStore.shared.hasShownContentView = true
                DispatchQueue.main.async {
                    self.parent.onFailure()
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

protocol InlineBrowserCoordinating: AnyObject {}
