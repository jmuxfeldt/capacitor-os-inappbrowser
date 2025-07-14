import Capacitor
import UIKit
import SafariServices

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(InAppBrowserPlugin)
public class InAppBrowserPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "InAppBrowserPlugin"
    public let jsName = "InAppBrowser"
    public let pluginMethods: [CAPPluginMethod] = [
        .init(name: "openInExternalBrowser", returnType: CAPPluginReturnPromise),
        .init(name: "openInSystemBrowser", returnType: CAPPluginReturnPromise),
        .init(name: "openInWebView", returnType: CAPPluginReturnPromise),
        .init(name: "close", returnType: CAPPluginReturnPromise)
    ]

    private var openedViewController: UIViewController?

    @objc func openInExternalBrowser(_ call: CAPPluginCall) {
        let urlString = call.getString("url", "")
        guard let url = URL(string: urlString), isSchemeValid(urlString) else {
            call.reject("Invalid URL")
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url) { success in
                if success {
                    call.resolve()
                } else {
                    call.reject("Failed to open URL")
                }
            }
        }
    }

    @objc func openInSystemBrowser(_ call: CAPPluginCall) {
        let urlString = call.getString("url", "")
        guard let url = URL(string: urlString), isSchemeValid(urlString) else {
            call.reject("Invalid URL")
            return
        }
        
        DispatchQueue.main.async {
            let safariVC = SFSafariViewController(url: url)
            self.bridge?.viewController?.present(safariVC, animated: true) {
                call.resolve()
            }
        }
    }

    @objc func openInWebView(_ call: CAPPluginCall) {
        let urlString = call.getString("url", "")
        guard let url = URL(string: urlString), isSchemeValid(urlString) else {
            call.reject("Invalid URL")
            return
        }
        
        DispatchQueue.main.async {
            let safariVC = SFSafariViewController(url: url)
            self.openedViewController = safariVC
            self.bridge?.viewController?.present(safariVC, animated: true) {
                call.resolve()
            }
        }
    }

    @objc func close(_ call: CAPPluginCall) {
        if let openedViewController {
            DispatchQueue.main.async {
                openedViewController.dismiss(animated: true) { [weak self] in
                    self?.openedViewController = nil
                    call.resolve()
                }
            }
        } else {
            call.resolve()
        }
    }
}

// MARK: - Private Extensions
private extension InAppBrowserPlugin {
    func isSchemeValid(_ urlScheme: String) -> Bool {
        ["http://", "https://"].contains(where: urlScheme.hasPrefix)
    }
}

