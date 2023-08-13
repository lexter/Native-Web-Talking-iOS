//
//  ViewController.swift
//  NativeAndWebTaking
//
//  Created by Lexter Labra on 8/4/23.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "toggleMessageHandler")
        let js = """
            var _selector = document.querySelector('input[name=myCheckbox]');
            _selector.addEventListener('change', function(event) {
                var message = (_selector.checked) ? "Toggle Switch is on" : "Toggle Switch is off";
                let responseData = {
                            "message": message,
                            "action": "toggle"
                        };
                // For native iOS
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.toggleMessageHandler) {
                    window.webkit.messageHandlers.toggleMessageHandler.postMessage(responseData);
                }
                // For native Android
                else {
                    JSBridge.showMessageInNative(JSON.stringify(responseData));
                }
            });
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)
    }
    
    @IBAction func additionButtonTapped(_ sender: UIBarButtonItem) {
        // Call the javascript addition function directly from the loaded HTML
        let a = 3
        let b = 4
        let script = "addition(\(a),\(b))"

        webView.evaluateJavaScript(script) { (result, error) in
            if let result = result {
                print("The \(a) + \(b) = \(result)")
            } else if let error = error {
                print("An error occurred in calling addition: \(error)")
            }
        }
    }
}

extension ViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }

        guard let message = dict["message"],
              let action = dict["action"] as? String
        else { return }
        
        switch action {
        case "toggle":
            // Read the switch element value in the loaded HTML
            let script = "document.getElementById('value').innerText = \"\(message)\""

            webView.evaluateJavaScript(script) { (result, error) in
                if let result = result {
                    print("Label is updated with message: \(result)")
                } else if let error = error {
                    print("An error occurred: \(error)")
                }
            }
            
        case "dismiss":
            // Respond to the dismiss button tap in loaded HTML
            dismiss(animated: true)
            
            
        default: ()
        }

        
    }
}

