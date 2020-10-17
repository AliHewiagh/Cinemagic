//
//  WebViewController.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 14/10/2020.
//

import WebKit
import Layoutless

class WebViewController: UIViewController {
    
    
    // MARK: - Views
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        return view
    }()
    
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        return progressView
    }()
    
    // MARK: - Init
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        
        guard let url = URL(string: url) else { return }
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
        
        title = "Loading..."
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Methods
    func setupUI() {
        stack(.vertical)(
            progressView,
            webView
        ).fillingParent().layout(in: view)
    }
}

// MARK: - Extensions
extension WebViewController: WKNavigationDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}
