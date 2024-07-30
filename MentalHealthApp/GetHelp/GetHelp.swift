//
//  GetHelp.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/24/24.
//

import Foundation
import UIKit

class GetHelp: UIViewController, UITextViewDelegate {
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true // Automatically hide when stopped
        return indicator
    }()
    
    let getHelpLabel: UILabel = {
        let label = UILabel()
        label.text = "Get Help"
        label.font = UIFont(name: "MontserratRoman-SemiBold", size: 28) ?? UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let placeholderText = "Hey! How can I help you today?"
    
    lazy var getHelpInput: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont(name: "MontserratRoman-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
        textView.textColor = .darkGray
        textView.layer.borderColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.text = placeholderText
        textView.textColor = UIColor.lightGray
        return textView
    }()
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray && textView.text == placeholderText {
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Check if the text was the placeholder and now will be changed
        if textView.textColor == UIColor.lightGray && textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.darkGray
            return true
        }
        
        // Normal text input handling
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    let submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont(name: "MontserratRoman-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        submitButton.layer.cornerRadius = 10
        submitButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        return submitButton
    }()
    
    let viewOnlyTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        //        textView.text = "Some dummy text for display."
        textView.textColor = UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1)
        textView.font = UIFont(name: "MontserratRoman-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupViews()
        getHelpInput.delegate = self
    }
    
    func animateText(_ text: String, in textView: UITextView) {
        let characters = Array(text)
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            if index < characters.count {
                let char = characters[index]
                textView.text.append(char)
                index += 1
            } else {
                timer.invalidate() // Stop the timer when all characters are displayed
                DispatchQueue.main.async {
                    self?.submitButton.isEnabled = true // Re-enable the submit button
                }
            }
        }
    }
    
    @objc func submitAction() {
        guard let userInput = getHelpInput.text, !userInput.isEmpty, userInput != placeholderText else {
            return
        }
        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        self.viewOnlyTextView.text = ""
        fetchChatGPTResponse(for: userInput) { [weak self] response in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let response = response {
                    self?.animateText(response, in: self?.viewOnlyTextView ?? UITextView())
                } else {
                    self?.animateText("Failed to get response. Please try again.", in: self?.viewOnlyTextView ?? UITextView())
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    
    private func setupViews() {
        view.addSubview(getHelpLabel)
        view.addSubview(getHelpInput)
        view.addSubview(submitButton)
        view.addSubview(viewOnlyTextView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            getHelpLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            getHelpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            getHelpInput.topAnchor.constraint(equalTo: getHelpLabel.bottomAnchor, constant: 20),
            getHelpInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getHelpInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            getHelpInput.heightAnchor.constraint(equalToConstant: 150),
            
            submitButton.topAnchor.constraint(equalTo: getHelpInput.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            viewOnlyTextView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 40),
            viewOnlyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            viewOnlyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            viewOnlyTextView.heightAnchor.constraint(equalToConstant: 270),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func fetchChatGPTResponse(for userInput: String, completion: @escaping (String?) -> Void) {
        let url = "Enter OPenAPI URL Here"!
        let apiKey = "Enter openAPI KEY Here"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let fullPrompt = "\(userInput) Help me feel better by giving 3 points through which I can feel better. Remember to be compassionate and respond with empathy. Keep it short"
        
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",  // or another model you prefer
            "messages": [
                ["role": "user", "content": fullPrompt]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion("Error: Invalid response from the server.")
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion("Error: No data received from the server")
                    }
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let choices = json?["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        DispatchQueue.main.async {
                            completion(content)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("Error: Invalid response format")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("Error: Failed to parse JSON data - \(error.localizedDescription)")
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    completion("Error: Unauthorized - Check your API key")
                }
            case 429:
                DispatchQueue.main.async {
                    completion("Error: Rate limit exceeded - Try again later")
                }
            default:
                DispatchQueue.main.async {
                    completion("Error: Received HTTP status code \(httpResponse.statusCode)")
                }
            }

        }
        task.resume()
    }
}
