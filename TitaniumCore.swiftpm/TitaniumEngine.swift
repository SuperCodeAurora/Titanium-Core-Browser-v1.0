import SwiftUI
import WebKit

struct TitaniumWebView: UIViewRepresentable {
    @Binding var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        
        // 🧠 THE MANUS PROTOCOL: Injecting the AI Extractor
        // This JavaScript scrapes the website and sends it to our Swift Coordinator
        let agentScript = """
        function extractDataForAI() {
            var rawText = document.body.innerText;
            // Send the first 500 characters back to the iPad's Native Memory
            window.webkit.messageHandlers.titaniumAgent.postMessage(rawText.substring(0, 500));
        }
        // Run it after 2 seconds
        setTimeout(extractDataForAI, 2000);
        """
        
        let script = WKUserScript(source: agentScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        // 🔌 Wiring the bridge so Javascript can talk to Swift
        config.userContentController.add(context.coordinator, name: "titaniumAgent")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator 
        webView.allowsBackForwardNavigationGestures = true 
        webView.customUserAgent = "TitaniumCore/2.0 (iPad; AI-Native Engine)" 
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url && !uiView.isLoading {
            uiView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 🛡️ THE COORDINATOR: Now equipped with WKScriptMessageHandler
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: TitaniumWebView

        init(_ parent: TitaniumWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Titanium Engine: Page locked.")
        }

        // 🚨 THE CRITICAL MOVE: Receiving data FROM the website
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "titaniumAgent" {
                if let extractedText = message.body as? String {
                    print("🤖 MANUS BRIDGE ACTIVATED. Extracted Data: \\n\\n\\(extractedText)...")
                    // In the future, we will send this text directly to a local LLM!
                }
            }
        }
    }
}
