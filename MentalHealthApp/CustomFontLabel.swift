//
//  CustomFontLabel.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 3/25/24.
//

import Foundation
import UIKit

class CustomFontLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Replace "YourCustomFontName" with your actual font name and adjust the size as needed.
        self.font = UIFont(name: "MontserratRoman-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
    }
}

class CustomFontTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Adjust the size as needed.
        self.font = UIFont(name: "MontserratRoman-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
    }
}

extension UIButton {
    func applyCustomFont() {
        // Adjust the size as needed.
        self.titleLabel?.font = UIFont(name: "MontserratRoman-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
    }
}
