//
// Copyright iOS Mastery.
// All Rights Reserved.

import UIKit
import CoreLocation
import MapKit

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeading: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingTrailing: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leadingAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeading: CGFloat = 0, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let leading = leadingAnchor {
            anchor(leading: leading, paddingLeading: paddingLeading)
        }
    }
    
    func setSize(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, leading: view.leadingAnchor,
               bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func addSubViews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}

extension UILabel {
    convenience public init(text: String? = "", font: UIFont? = UIFont.systemFont(ofSize: 12),
                            textColor: UIColor = .black, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1) {
        self.init()
        
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
}

extension CLLocation {
    func fetchLocationInformation(completion: @escaping (_ city: String?, _ country: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) {
            completion($0?.first?.locality, $0?.first?.country,$1)
            //placemarks, error in
           // if let error = error {
                //   completion(nil, nil, error)
               // return
            }
           // let placemark = placemarks?.first
            //completion(placemark?.locality, placemark?.country, nil)
        }
 //   }
    
}

extension UIImageView {
    func loadWeatherIcon(icon: String) {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.image = image
                    }
                }
            } catch {
                print("Failed to load icon: \(error)")
            }
        }
    }
}
