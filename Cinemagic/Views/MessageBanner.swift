//
//  MessageDialog.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 15/10/2020.
//

import UIKit
import SnapKit

public enum Theme {
    case success
    case warning
    case error
}

class MessageBanner: UIView {
    
    // MARK: - Properties
    static var sharedInstance = MessageBanner()

    // MARK: - Views
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textColor = .white
        label.font = UIFont(name: "ArialMT", size: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var parentView: UIView!
    
    private var maskingView : UIView!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    // MARK: - Methods
    private func setUpUI(){
        self.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.snp.center)
            }
     }
    
    func showBanner(message:String,theme:Theme){
        parentView = UIApplication.shared.keyWindow
        parentView.addSubview(self)
        addMaskView()
        messageLabel.text = message + " Click to dismiss"
        applyTheme(theme: theme)
        self.frame.size = CGSize(width: parentView.frame.width, height: 100)
        self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.minY - self.frame.height , width: self.frame.width, height: self.frame.height)
        parentView.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: self.parentView.frame.minX, y: self.parentView.frame.minY, width: self.frame.width, height: self.frame.height)
        }
        makeDim()

    }
    
    private func applyTheme(theme:Theme) {
        var backgroundColor : UIColor
        switch theme {
        case .error:
            backgroundColor = UIColor(red: 249.0/255.0, green: 66.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        case .success:
            backgroundColor = UIColor(red: 97.0/255.0, green: 161.0/255.0, blue: 23.0/255.0, alpha: 1.0)
        case .warning:
            backgroundColor = UIColor(red: 238.0/255.0, green: 189.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        }
        self.backgroundColor = backgroundColor
    }
    
    func addMaskView() {
        maskingView = UIView(frame: parentView.bounds)
        parentView.addSubview(maskingView)
        maskingView.backgroundColor = .clear
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.hideBannerOnTap))
        self.addGestureRecognizer(gesture)
        parentView.addSubview(maskingView)
    }
    
    @objc func hideBannerOnTap(sender : UITapGestureRecognizer) {
        self.hideBanner()
    }
    
    func makeDim(){
        self.maskingView.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.2, animations: {
            self.maskingView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        })
    }
    
    @objc func hideBanner(){
        UIView.animate(withDuration: 0.2, animations: {
            self.maskingView.backgroundColor = .clear
            self.frame.origin.y -= 100
        }) { (_) in
            self.maskingView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}
