//
//  LogoAnimatedView.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/24/24.
//

import Foundation
import UIKit
import SwiftyGif

class LogoAnimationView: UIView {
    
    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "Splash-final.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 1)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 246.0 / 255.0, alpha: 1)
        addSubview(logoGifImageView)
//        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
//        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        //        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //        logoGifImageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        //        logoGifImageView.heightAnchor.constraint(equalToConstant: 108).isActive = true
//        logoGifImageView.topAnchor.constraint(equalTo: self.topAnchor),
//        logoGifImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//        logoGifImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//        logoGifImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    }
    func pinLogoGifImageViewToSuperView() {
        guard let superView = self.superview else { return }
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoGifImageView.topAnchor.constraint(equalTo: superView.topAnchor),
            logoGifImageView.leftAnchor.constraint(equalTo: superView.leftAnchor),
            logoGifImageView.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
            logoGifImageView.rightAnchor.constraint(equalTo: superView.rightAnchor)
        ])
    }
    
}

