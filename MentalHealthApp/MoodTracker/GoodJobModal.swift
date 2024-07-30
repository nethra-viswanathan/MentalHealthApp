//
//  GoodJobModal.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/1/24.
//

import Foundation
import UIKit

class GoodJobViewController: UIViewController {
    
    let modalView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupDismissGesture()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        modalView.backgroundColor = .black
        modalView.layer.cornerRadius = 12
        modalView.translatesAutoresizingMaskIntoConstraints = false
        modalView.layer.masksToBounds = true
        view.addSubview(modalView)
        
        let backgroundImage = UIImageView(image: UIImage(named: "Modalbg"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(backgroundImage)
        
        
        // Clapping Icon Label
        let clappingIconLabel = UILabel()
        clappingIconLabel.text = "👏"
        clappingIconLabel.font = UIFont.systemFont(ofSize: 54) // Adjust size as needed
        clappingIconLabel.textAlignment = .center
        clappingIconLabel.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(clappingIconLabel)
        
        let messageLabel = UILabel()
        messageLabel.text = "Great Job, Keep Going!"
        messageLabel.font = UIFont(name: "MontserratRoman-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20)
        messageLabel.textColor = UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1) // Custom color
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(messageLabel)
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Underline the text
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1)
            ]
            let attributedTitle = NSAttributedString(string: "Back", attributes: attributes)
            button.setAttributedTitle(attributedTitle, for: .normal)
            
            button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            
            return button
        }()
        modalView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            modalView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            backgroundImage.topAnchor.constraint(equalTo: modalView.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: modalView.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            
            clappingIconLabel.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 120),
            clappingIconLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: clappingIconLabel.bottomAnchor, constant: 10),
            messageLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),
            
            backButton.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5)
            
        ])
    }
    
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true) {
            // Assuming this modal is presented from a UINavigationController or similar
            if let parentVC = self.presentingViewController as? UINavigationController {
                parentVC.popToViewController(ofClass: MoodTrackerViewController.self, animated: true)
            }
        }
    }
    
    
    private func setupDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModalView))
        tapGesture.cancelsTouchesInView = false // This ensures taps on the modalView do not dismiss it
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissModalView(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        // Only dismiss if the tap is outside the modalView
        if !modalView.frame.contains(location) {
            UIView.animate(withDuration: 0.3, animations: {
                self.modalView.alpha = 0 // Fade the modalView out
            }) { _ in
                self.dismiss(animated: false, completion: nil) // Dismiss without animation since we've already animated the modalView
            }
        }
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}
