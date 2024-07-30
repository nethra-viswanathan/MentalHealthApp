//
//  DetailedEntryModal.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/25/24.
//

import Foundation
import UIKit

class DetailedEntryViewController: UIViewController {
    
    let modalView = UIView()
    let emojiLabel = UILabel()
    let dateLabel = UILabel()
    let moodLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupDismissGesture()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 12
        modalView.translatesAutoresizingMaskIntoConstraints = false
        modalView.layer.masksToBounds = true
        view.addSubview(modalView)
        
        // Setup emojiLabel
        emojiLabel.font = UIFont.systemFont(ofSize: 50) // Example size
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup dateLabel
        dateLabel.textColor = .gray
        dateLabel.font = UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup moodLabel
        moodLabel.textColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        moodLabel.font = UIFont(name: "MontserratRoman-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [emojiLabel, dateLabel, moodLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10 // Adjust the spacing between labels as needed
        stackView.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            modalView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            stackView.centerXAnchor.constraint(equalTo: modalView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: modalView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: modalView.widthAnchor),
            
        ])
    }
    
    
    func setupWithData(emoji: String, date: String, mood: String) {
        emojiLabel.text = emoji
        dateLabel.text = date
        moodLabel.text = mood
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


