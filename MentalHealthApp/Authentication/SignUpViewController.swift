//
//  SignUpViewController.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 3/18/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class GradientLabelView: UIView {
    private var textAttributes: [NSAttributedString.Key: Any]?
    private let text: String
    
    init(frame: CGRect, text: String) {
        self.text = text
        super.init(frame: frame)
        self.backgroundColor = .clear
        adjustFrameToFitText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        
        // Define the gradient
        let colors = [
            UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1).cgColor,
            UIColor(red: 241/255, green: 201/255, blue: 254/255, alpha: 1).cgColor
        ]
        let locations: [CGFloat] = [0, 1]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        
        // Create an image from the gradient
        let imageSize = CGSize(width: rect.width, height: rect.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let imageContext = UIGraphicsGetCurrentContext()
        imageContext?.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.width, y: rect.height), options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Create an attributed string with the gradient pattern
        let textSize = text.size(withAttributes: [.font: UIFont(name: "Satisfy-Regular", size: 40)!])
        let textRect = CGRect(x: (rect.width - textSize.width) / 2, y: (rect.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        let attributedString = NSAttributedString(string: text, attributes: [.font: UIFont(name: "Satisfy-Regular", size: 40)!, .foregroundColor: UIColor(patternImage: gradientImage!)])
        
        // Draw the attributed string with the gradient
        attributedString.draw(in: textRect)
        
        context.restoreGState()
    }
    
    private func adjustFrameToFitText() {
        let textSize = text.size(withAttributes: [.font: UIFont(name: "Satisfy-Regular", size: 34)!])
        let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: textSize.width, height: textSize.height)
        frame = newFrame
    }
}


class GradientBorderButton: UIButton {
    private var gradientLayer: CAGradientLayer?

    // colors for the gradient border
    var borderColors: [CGColor]? {
        didSet {
            setupGradientBorder()
        }
    }

    var borderWidth: CGFloat = 2 {
        didSet {
            setupGradientBorder()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientBorder()
    }

    private func setupGradientBorder() {
        gradientLayer?.removeFromSuperlayer() // Remove the existing layer to avoid duplicates

        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = borderColors
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)

        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        layer.addSublayer(gradient)
        gradientLayer = gradient
    }
}



class SignUpViewController: UIViewController {
    
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
        textField.font = UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        textField.isSecureTextEntry = true
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
        let normalText = "Create your Journee account"
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
        
        let normalText = "Already have an account? "
        let coloredText = "Sign In here"
        
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
        let signInVC = SignInViewController() 
        signInVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(signInVC, animated: true)
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
        
        // Initialize the custom gradient label view
        let gradientTitleView = GradientLabelView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60), text: "Journee")
        gradientTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        let signUpLabel = createSignUpLabel()
        
        // Create the spacer view
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 2).isActive = true // Set the spacer height to 40

        // Create and configure the stack view
        let stackView = UIStackView(arrangedSubviews: [gradientTitleView, signUpLabel, emailTextField, passwordTextField, spacerView, submitButton])
        stackView.axis = .vertical
        stackView.spacing = 20 // This sets the default spacing for elements that don't require specific spacing
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
        
        // Validate the email
        if isValidEmail(email) {
            // Proceed with Firebase sign up
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: error.localizedDescription)
                    return
                }
                self.showAlert(withTitle: "Success", message: "User signed up successfully")
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

