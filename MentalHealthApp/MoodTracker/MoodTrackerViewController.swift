//
//  MoodTrackerViewController.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 3/20/24.
//

import Foundation
import FSCalendar
import Firebase
import FirebaseFirestore

class MoodTrackerViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource{
    var calendar: FSCalendar!
    var selectedDate: Date?
    var selectedEmojiIndex: Int? {
        didSet {
            updateEmojiButtonStyles()
        }
    }
    let emojiButtonsStackView = UIStackView()
    let emojis = ["😄", "🙂", "😐", "🙁", "😡"]
    let emojiTags = ["VHappy", "Happy", "Neutral", "Sad", "VSad"]
    let oneLinerTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        edgesForExtendedLayout = [.all]
        setupCalendarBackground()
        setupCalendar()
        adjustCalendarHeaderAlignment()
        setupMoodtracker()
        setupOneLiner()
        setupSubmitBtn()
        
    }
    
    func setupCalendarBackground() {
        let calendarBackgroundView = UIView()
        calendarBackgroundView.backgroundColor = UIColor(red: 229/255, green: 204/255, blue: 255/255, alpha: 1) //light purple
        calendarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarBackgroundView)
        view.sendSubviewToBack(calendarBackgroundView) // Ensure it's behind all other views
        
        calendarBackgroundView.layer.cornerRadius = 30 // Adjust the corner radius as needed
        calendarBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Round only the bottom corners
        
        NSLayoutConstraint.activate([
            // Extend from the top edge of the view, not just from under the navigation bar
            calendarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Adjust the bottom anchor as needed
            calendarBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170 )
        ])
    }
    
    func setupCalendar() {
        calendar = FSCalendar(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.scope = .week // Display only one week at a time for a "strip" effect
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0 // Hides the header's previous and next month buttons
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.headerTitleColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1) // purple
        calendar.appearance.todayColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)// Highlight today's date
        calendar.appearance.selectionColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        calendar.appearance.titleSelectionColor = .white
        
        calendar.appearance.headerTitleFont = UIFont(name: "MontserratRoman-SemiBold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        calendar.appearance.titleFont = UIFont(name: "MontserratRoman-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15)
        calendar.appearance.weekdayFont = UIFont(name: "MontserratRoman-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        
        //bring month to the left
        calendar.appearance.headerTitleOffset = .init(x: -105, y: -10)
        
        calendar.headerHeight = 50 // Hide the header
        calendar.weekdayHeight = 25 // Adjust the weekday row height
        
        view.addSubview(calendar)
        view.bringSubviewToFront(calendar)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        // Get today's date with time set to midnight
        let today = Calendar.current.startOfDay(for: Date())
        // Get the date to be selected with time set to midnight
        let dateToSelect = Calendar.current.startOfDay(for: date)
        // Compare and return true if the date to be selected is today or before
        return dateToSelect <= today
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizeNavigationBarAppearance(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customizeNavigationBarAppearance(false)
    }
    
    func customizeNavigationBarAppearance(_ isCustom: Bool) {
        guard let navigationController = navigationController else { return }
        
        if isCustom {
            // Custom appearance
            let customAppearance = UINavigationBarAppearance()
            customAppearance.configureWithOpaqueBackground()
            customAppearance.backgroundColor = UIColor(red: 229/255, green: 204/255, blue: 255/255, alpha: 1)
            customAppearance.shadowColor = nil // Removes the shadow line
            
            navigationController.navigationBar.standardAppearance = customAppearance
            navigationController.navigationBar.scrollEdgeAppearance = customAppearance
        } else {
            // Reset to default or other desired appearance
            let defaultAppearance = UINavigationBarAppearance()
            defaultAppearance.configureWithDefaultBackground()
            // Customize the default appearance if needed
            
            navigationController.navigationBar.standardAppearance = defaultAppearance
            navigationController.navigationBar.scrollEdgeAppearance = defaultAppearance
        }
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date // Track the selected date
        calendar.today = nil
        print("date",selectedDate) // Force the calendar to refresh its appearance
    }
    
    func adjustCalendarHeaderAlignment() {
        guard let headerView = calendar.subviews.first(where: { String(describing: type(of: $0)) == "FSCalendarHeaderView" }) else {
            return
        }
        
        for subview in headerView.subviews {
            if let label = subview as? UILabel {
                label.textAlignment = .right
                label.frame = CGRect(x: 0, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height) // Adjust padding as needed
            }
        }
    }
    
    func setupMoodtracker() {
        let label = UILabel()
        label.text = "How are you feeling today?"
        label.font = UIFont(name: "MontserratRoman-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false // This line is crucial
        view.addSubview(label)
        
        // Adjusting the topAnchor to position label correctly
        NSLayoutConstraint.activate([
            // Position label below the calendarBackgroundView with some padding. Adjust constant as needed.
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 210),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        
        
        //        let emojiButtonsStackView = UIStackView()
        emojiButtonsStackView.axis = .horizontal
        emojiButtonsStackView.distribution = .equalSpacing
        emojiButtonsStackView.alignment = .center
        emojiButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        emojiButtonsStackView.spacing = 20
        
        for (index, emoji) in emojis.enumerated() {
            let button = UIButton()
            button.setTitle(emoji, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 40)
            button.tag = index // Use index as tag to identify the button later
            button.addTarget(self, action: #selector(emojiButtonTapped(_:)), for: .touchUpInside)
            
            emojiButtonsStackView.addArrangedSubview(button)
            print("Adding emoji button: \(emoji)")
        }
        view.addSubview(emojiButtonsStackView)
        
        NSLayoutConstraint.activate([
            emojiButtonsStackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            emojiButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiButtonsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emojiButtonsStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
    }
    
    @objc func emojiButtonTapped(_ sender: UIButton) {
        guard let emoji = sender.titleLabel?.text else { return }
        selectedEmojiIndex = sender.tag
        print("Emoji \(emoji) tapped")
    }
    
    func updateEmojiButtonStyles() {
        UIView.animate(withDuration: 0.3) {
            for (index, button) in self.emojiButtonsStackView.arrangedSubviews.enumerated() {
                guard let emojiButton = button as? UIButton else { continue }
                let isSelected = index == self.selectedEmojiIndex
                emojiButton.titleLabel?.font = isSelected ? .systemFont(ofSize: 60) : .systemFont(ofSize: 40)
                // Add any additional style updates here if needed
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func setupOneLiner(){
        let label = UILabel()
        label.text = "Would you like to add something?"
        label.font = UIFont(name: "MontserratRoman-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false // This line is crucial
        view.addSubview(label)
        
        // Adjusting the topAnchor to position label correctly
        NSLayoutConstraint.activate([
            // Position label below the calendarBackgroundView with some padding. Adjust constant as needed.
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 350),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        
        oneLinerTextView.translatesAutoresizingMaskIntoConstraints = false
        oneLinerTextView.font = UIFont(name: "MontserratRoman-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
        oneLinerTextView.textColor = UIColor.darkGray
        oneLinerTextView.layer.borderColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1).cgColor
        oneLinerTextView.layer.borderWidth = 1.0
        oneLinerTextView.layer.cornerRadius = 5.0
        oneLinerTextView.isScrollEnabled = true // Enable scrolling for long texts
        oneLinerTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5) // Padding inside the textView
        
        view.addSubview(oneLinerTextView)
        
        NSLayoutConstraint.activate([
            oneLinerTextView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15), // Space between label and textView
            oneLinerTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            oneLinerTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            oneLinerTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            oneLinerTextView.heightAnchor.constraint(equalToConstant: 150) // Fixed height for textView
        ])
    }
    
    func setupSubmitBtn() {
        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont(name: "MontserratRoman-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        submitButton.layer.cornerRadius = 10
        submitButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 580),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func submitAction() {
        // Implement submission logic here
        guard let emojiIndex = selectedEmojiIndex else {
            showAlert(message: "Please select an emoji before submitting.")
            return
        }
        guard let user = Auth.auth().currentUser else {
            showAlert(message: "User is not signed in.")
            return
        }
        print("Submit button tapped")
        let dateToSave = selectedDate ?? Date()
        let emoji = emojiTags[emojiIndex]
        let oneLinerText = oneLinerTextView.text ?? ""
        print("emoji", emoji)
        print("oneLiner", oneLinerText)
        // Firestore reference
        let db = Firestore.firestore()
        let data: [String: Any] = ["emoji": emoji, "oneLiner": oneLinerText, "timestamp": Timestamp(date: dateToSave), "userId": user.uid]
        
        db.collection("moodTracker").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                DispatchQueue.main.async {
                    self.showSuccessModal()
                }
            }
        }
    }
    
    func showSuccessModal() {
        let modalViewController = GoodJobViewController()
        modalViewController.modalPresentationStyle = .overCurrentContext // or .overFullScreen
        modalViewController.modalTransitionStyle = .crossDissolve
        present(modalViewController, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Action Needed", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
