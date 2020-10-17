//
//  Extentions.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import UIKit
import RxSwift
import RxCocoa

extension UIColor {
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIViewController: loadingViewable {}

extension Reactive where Base: UIViewController {
    
    public var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (vc, active) in
            if active {
                vc.startAnimating()
            } else {
                vc.stopAnimating()
            }
        })
    }
}

extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

public extension UIImageView {
    func loadImage(imageURL url: String, path: String) {
        
        let imageUrl = url + path
        
        guard let imageURL = URL(string: imageUrl) else {
            return
        }
        
        if path.count == 0 {
            let image = UIImage(named: "poster_not_available")
            self.transition(toImage: image)
            
        } else {
            
            let cache =  URLCache.shared
            let request = URLRequest(url: imageURL)
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.transition(toImage: image)
                    }
                } else {
                    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                        if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                            let cachedData = CachedURLResponse(response: response, data: data)
                            cache.storeCachedResponse(cachedData, for: request)
                            DispatchQueue.main.async {
                                self.transition(toImage: image)
                            }
                        }
                    }).resume()
                }
            }
        }
    }
    
    
    func transition(toImage image: UIImage?) {
        UIView.transition(with: self, duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.image = image
                          },
                          completion: nil)
    }
}



extension MovieDetailsViewController {
    func returnHours(runtime: Int) -> String  {
        let hoursWithMinutes = (runtime / 60, (runtime % 60))
        return "Duration: " + String(hoursWithMinutes.0) + "h " + String(hoursWithMinutes.1) + "min"
    }
    
    
    func returnGeners(geners: [Genre]) -> String {
        let genersNamesArray = geners.map{ String($0.name ?? "") }
        let combinedNames = genersNamesArray.joined(separator: ", ")
        return combinedNames
    }
}
