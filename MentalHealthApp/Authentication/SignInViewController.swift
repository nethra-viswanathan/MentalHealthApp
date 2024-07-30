//
//  SignInViewController.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 3/19/24.
//

import Foundation
import UIKit
import Firebase


class SignInViewController: UIViewController {
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.font = UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.borderStyle = .roundedRect
        textField.textContentType = .oneTimeCode
        textField.isSecureTextEntry = true
        textField.font = UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        return textField
    }()
    
    let submitButton: GradientBorderButton = {
        let button = GradientBorderButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
        button.borderColors = [UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1).cgColor, UIColor(red: 241/255, green: 201/255, blue: 254/255, alpha: 1).cgColor]
        button.borderWidth = 3
        button.setTitleColor(UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1), for: .normal)
        button.layer.cornerRadius = 6 // Set the corner radius here
        button.titleLabel?.font = UIFont(name: "MontserratRoman-Medium", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    func createSignUpLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        let normalText = "Sign in to  your Journee account"
        let attributedString = NSAttributedString(string: normalText, attributes: [
            .font: UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor(red: 152/255, green: 152/255, blue: 152/255, alpha: 1) // Adjusted to #989898
        ])
        label.attributedText = attributedString
        return label
    }

    
    func createSignInLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 //Allow multiple lines
        
        let normalText = "Don't have an account? "
        let coloredText = "Sign Up here"
        
        let attributedString = NSMutableAttributedString(string: normalText, attributes: [
            .font: UIFont(name: "MontserratRoman-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
        ])
        
        let coloredAttributedString = NSAttributedString(string: coloredText, attributes: [
            .font: UIFont(name: "MontserratRoman-SemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor(red: 241/255, green: 201/255, blue: 254/255, alpha: 1)
        ])
        
        attributedString.append(coloredAttributedString)
        
        label.attributedText = attributedString
        
        // Add gesture recognizer if you want "here" to be tappable
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signInTapped))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }

    @objc func signInTapped() {
        
        let signUpVC = SignUpViewController()
        signUpVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }

    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "Signup")
        return imageView
    }()
    
    func createGradientLabel() -> UIView {
        let label = UILabel()
        label.text = "Journee"
//        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        label.font = UIFont(name: "Satisfy", size: 24)
        label.font = UIFont(name: "Satisfy-Regular", size: 30)
        label.textAlignment = .center
        label.sizeToFit()
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1).cgColor,
            UIColor(red: 241/255, green: 201/255, blue: 254/255, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Create a view that will act as a mask for the gradient layer
        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width, height: label.frame.height))
        maskView.backgroundColor = .clear
        maskView.addSubview(label)
        
        // Set the gradient layer's frame to the maskView's bounds
        gradientLayer.frame = maskView.bounds
        
        // Create a new UIView that will contain the gradient layer
        let gradientView = UIView(frame: maskView.frame)
        gradientView.layer.addSublayer(gradientLayer)
        
        // Use the maskView to mask the gradient layer
        gradientLayer.mask = label.layer
        
        // Return the gradientView
        return gradientView
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        // Set up the background image
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let gradientTitleView = GradientLabelView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60), text: "Journee")
        gradientTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        let signUpLabel = createSignUpLabel()
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 2).isActive = true

        let stackView = UIStackView(arrangedSubviews: [gradientTitleView, signUpLabel, emailTextField, passwordTextField, spacerView, submitButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        let signInLabel = createSignInLabel()
        stackView.addArrangedSubview(signInLabel)
        // Constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gradientTitleView.heightAnchor.constraint(equalToConstant: 60),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 40),
            gradientTitleView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.widthAnchor.constraint(equalToConstant: 300),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    
    
    
    @objc func handleSubmitButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Handle empty fields
            showAlert(withTitle: "Error", message: "Email and password are required")
            return
        }
        
        if isValidEmail(email) {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: error.localizedDescription)
                    return
                }
//                self.showAlert(withTitle: "Success", message: "User signed up successfully")
//                
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            
            let menuTabBar = MenuTabBar()
            // Assuming MoodTrackerViewController should be selected first after sign-in
            menuTabBar.selectedIndex = 1 // Adjust based on the index of MoodTrackerViewController in your tab bar setup
            
            // Now using the window property from sceneDelegate
            sceneDelegate.window?.rootViewController = menuTabBar
            sceneDelegate.window?.makeKeyAndVisible()
        }
            }
        } else {
            self.showAlert(withTitle: "Error", message: "Invalid email format")
        }
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
