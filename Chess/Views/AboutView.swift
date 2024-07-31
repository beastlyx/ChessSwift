import SwiftUI
import WebKit

struct AboutView: View {
    var body: some View {
        VStack {
            Text("About this App")
                .font(.largeTitle)
                .padding()

            Text("This app uses free icons from Icons8.")
                .padding()

            WebView(htmlContent: attributionHTML)
                .frame(height: 100) // Increase the height as needed
                .padding()
            
            Spacer()
        }
        .padding()
    }

    private var attributionHTML: String {
        """
        <a target="_blank" href="https://icons8.com/icon/70p3yOrX91d1/chess">Chess</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
        """
    }
}

struct WebView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlContent, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
