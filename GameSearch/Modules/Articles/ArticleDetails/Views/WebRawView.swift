import SwiftUI
import WebKit


struct WebRawView: UIViewRepresentable {
    let data: WebRawBlockData

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
                config.allowsInlineMediaPlayback = true
                config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            background-color: black;
        }

        .video-container {
            position: relative;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        .placeholder {
            position: absolute;
            inset: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display";
            font-size: 17px;
            font-weight: 500;
            color: white;
            z-index: 0;
        }
        .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: 0;
        }
        </style>
        </head>
        <body>
        <div class="video-container">
        <div class="placeholder">
            Видео загружается…
        </div>
        \(data.html)
        </div>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
        webView.layer.cornerRadius = 16
        webView.clipsToBounds = true
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
