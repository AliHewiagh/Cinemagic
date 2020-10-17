//
//  ActivityIndicator.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 15/10/2020.
//

import UIKit


protocol loadingViewable {
    func startAnimating()
    func stopAnimating()
}
extension loadingViewable where Self : UIViewController {
    func startAnimating(){
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        view.addSubview(spinner)
        spinner.restorationIdentifier = "loadingIndicator"
        spinner.color = .black
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.bringSubviewToFront(spinner)
    }
    func stopAnimating() {
        for item in view.subviews
            where item.restorationIdentifier == "loadingIndicator" {
                UIView.animate(withDuration: 0.3, animations: {
                    item.alpha = 0
                }) { (_) in
                    item.removeFromSuperview()
                }
        }
    }
}

