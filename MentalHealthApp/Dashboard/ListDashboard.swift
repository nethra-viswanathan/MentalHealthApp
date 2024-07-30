//
//  Dashboard.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/3/24.
//

import Foundation
import UIKit
import SwiftUI
import FSCalendar
import Firebase
import FirebaseFirestore

class ListDashboard: UIViewController{
    
    var emojiDashboardController: UIHostingController<GraphDashboard>?
    
    var currentMonthLabel: UILabel!
    var calendar: FSCalendar!
    let headerStackView = UIStackView()
    var scrollView: UIScrollView!
    var contentView: UIView!

    
    let listViewButton = UIButton(type: .system)
    let graphViewButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255.0, green: 246/255.0, blue: 252/255.0, alpha: 1)
        edgesForExtendedLayout = [.all]
        self.calendar = FSCalendar() // Initialize the FSCalendar
        self.calendar.translatesAutoresizingMaskIntoConstraints = false
        setupHeader()
        setupMonthHeader()
        updateCurrentMonthLabel()
        setupScrollView()
        fetchMoodData()
        
        //graph
        setupGraphDashboard()
    }
    
    func setupGraphDashboard() {
        let viewModel = MoodTrackerViewModel()
        let graphDashboard = GraphDashboard(viewModel: viewModel, onNavigateBackToList: {
            // Manage the visibility or perform other actions needed to show the list dashboard
            self.contentView.isHidden = false
            self.scrollView.isHidden = false
            self.emojiDashboardController?.view.isHidden = true
        })
        let hostingController = UIHostingController(rootView: graphDashboard)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.isHidden = true  // Initially hide the graph dashboard
        hostingController.didMove(toParent: self)
        emojiDashboardController = hostingController // Store it to manage visibility later
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        fetchMoodData()
    }
    
    func setupHeader(){
        
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        
        let label = UILabel()
        label.text = "Dashboard"
        label.font = UIFont(name: "MontserratRoman-SemiBold", size: 28) ?? UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        listViewButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        listViewButton.tintColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        listViewButton.translatesAutoresizingMaskIntoConstraints = false
        listViewButton.addTarget(self, action: #selector(toggleViewSelection(_:)), for: .touchUpInside)
        listViewButton.tag = 1
        
        graphViewButton.setImage(UIImage(systemName: "chart.bar"), for: .normal)
        graphViewButton.tintColor = UIColor.lightGray
        graphViewButton.translatesAutoresizingMaskIntoConstraints = false
        graphViewButton.addTarget(self, action: #selector(toggleViewSelection(_:)), for: .touchUpInside)
        graphViewButton.tag = 2
        
        headerView.addSubview(listViewButton)
        headerView.addSubview(graphViewButton)
        
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            graphViewButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            graphViewButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            listViewButton.trailingAnchor.constraint(equalTo: graphViewButton.leadingAnchor, constant: -15), // 10 points space between buttons
            listViewButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            headerView.heightAnchor.constraint(equalToConstant: label.intrinsicContentSize.height) // Adjust the header height based on label height
        ])
    }
    
    @objc func toggleViewSelection(_ sender: UIButton) {
        if sender.tag == 1 {
            // List view button was tapped
//            listViewButton.tintColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1) // Highlight in purple
//            graphViewButton.tintColor = UIColor.lightGray // De-highlight
            contentView.isHidden = false // Show the list view
            scrollView.isHidden = false
            emojiDashboardController?.view.isHidden = true // Hide the graph view
        } else if sender.tag == 2 {
            // Graph view button was tapped
//            graphViewButton.tintColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1) // Highlight in purple
//            listViewButton.tintColor = UIColor.lightGray // De-highlight
            contentView.isHidden = true // Hide the list view
            scrollView.isHidden = true
            emojiDashboardController?.view.isHidden = false
        }
    }
    
    func setupMonthHeader() {
        
            headerStackView.axis = .horizontal
            headerStackView.distribution = .equalSpacing
            headerStackView.alignment = .center
            headerStackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(headerStackView)

            // Monthly Overview Label
            let monthlyOverviewLabel = UILabel()
            monthlyOverviewLabel.text = "Monthly Overview"
            monthlyOverviewLabel.font = UIFont(name: "MontserratRoman-Medium", size: 18)
            monthlyOverviewLabel.textColor = UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1)

            // Spacer View
            let spacerView = UIView()
            spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            // Current Month Label
            currentMonthLabel = UILabel()
            currentMonthLabel.font = UIFont(name: "MontserratRoman-Medium", size: 18)
            currentMonthLabel.textColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1) //purple
            currentMonthLabel.textAlignment = .center
        
            
            // Left Arrow Button
            let leftArrowButton = UIButton(type: .system)
            leftArrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            leftArrowButton.tintColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
            leftArrowButton.addTarget(self, action: #selector(goToPreviousMonth), for: .touchUpInside)

            // Right Arrow Button
            let rightArrowButton = UIButton(type: .system)
            rightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            rightArrowButton.tintColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
            rightArrowButton.addTarget(self, action: #selector(goToNextMonth), for: .touchUpInside)

            headerStackView.addArrangedSubview(monthlyOverviewLabel)
            headerStackView.addArrangedSubview(spacerView) 
            headerStackView.addArrangedSubview(leftArrowButton)
            headerStackView.addArrangedSubview(currentMonthLabel)
            headerStackView.addArrangedSubview(rightArrowButton)

            NSLayoutConstraint.activate([
                headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
                headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
    }
    
    @objc func goToNextMonth() {
        let currentMonth = self.calendar.currentPage
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        calendar.setCurrentPage(nextMonth, animated: true)
        updateCurrentMonthLabel(date: nextMonth)
        fetchMoodData()
    }

    @objc func goToPreviousMonth() {
        let currentMonth = self.calendar.currentPage
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        calendar.setCurrentPage(previousMonth, animated: true)
        updateCurrentMonthLabel(date: previousMonth)
        fetchMoodData()
    }
    
    func updateCurrentMonthLabel(date: Date = Date()) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YY" // Adjust format as needed
        currentMonthLabel.text = dateFormatter.string(from: date)
    }
    
    func fetchMoodData() {
        var lastBottomAnchor = contentView.topAnchor
        let spacingBetweenRectangles: CGFloat = 20
        let db = Firestore.firestore()
        
        let dateRange = monthDateRange(from: calendar.currentPage)
        let startTimestamp = Timestamp(date: dateRange.start)
        let endTimestamp = Timestamp(date: dateRange.end)
        
        guard let user = Auth.auth().currentUser else {
            showAlert(message: "User is not signed in.")
            return
        }
        
        db.collection("moodTracker")
            .whereField("userId", isEqualTo: user.uid)
            .whereField("timestamp", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("timestamp", isLessThanOrEqualTo: endTimestamp)
            .order(by: "timestamp", descending: true)
            .getDocuments { (snapshot, error) in
                DispatchQueue.main.async {
                    self.clearContentView() // Clear the content view and any no data labels before processing new data
                }
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let documents = snapshot?.documents, documents.isEmpty {
                DispatchQueue.main.async {
                    self.showNoDataFound()
                }
            } else {
                let documentCount = snapshot!.documents.count
                var completionCount = 0
                
                self.contentView.subviews.forEach { $0.removeFromSuperview() }  // Clear previous data
                var lastBottomAnchor = self.contentView.topAnchor
                
                for document in snapshot!.documents {
                    
                    let data = document.data()
                    let emojiTag = data["emoji"] as? String ?? ""
                    let oneLiner = data["oneLiner"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()

                    // Convert timestamp to Date
                    let date = timestamp.dateValue()
                    
                    // Convert emojiTag to actual emoji
                    let emoji = self.mapEmojiTagToEmoji(emojiTag: emojiTag)
                    
                    // Format date
                    let formattedDate = self.formatDate(date: date)
                    
                    // Now, you can use emoji, formattedDate, and oneLiner to update your UI accordingly
                    DispatchQueue.main.async {
                        let rectangleView = UIView()
                        rectangleView.backgroundColor = .white
                        rectangleView.translatesAutoresizingMaskIntoConstraints = false
                        rectangleView.layer.cornerRadius = 20
                        rectangleView.layer.shadowColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1).cgColor
                        rectangleView.layer.shadowOpacity = 0.5
                        rectangleView.layer.shadowOffset = CGSize(width: 0, height: 2)
                        rectangleView.layer.shadowRadius = 4
                        rectangleView.layer.masksToBounds = false
                        self.contentView.addSubview(rectangleView)

                        // Rectangle View Constraints
                        NSLayoutConstraint.activate([
                            rectangleView.topAnchor.constraint(equalTo: lastBottomAnchor, constant: spacingBetweenRectangles),
                            rectangleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                            rectangleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                            rectangleView.heightAnchor.constraint(equalToConstant: 100),
                        ])

                        self.setupContents(in: rectangleView, emoji: emoji, date: formattedDate, mood: oneLiner)
                        lastBottomAnchor = rectangleView.bottomAnchor
                        
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleRectangleTap(_:)))
                        rectangleView.addGestureRecognizer(tapGesture)
                        rectangleView.isUserInteractionEnabled = true
                        
                        rectangleView.accessibilityLabel = "\(emoji)|\(formattedDate)|\(oneLiner)"
                        rectangleView.tag = completionCount
                        
                        // Increment completion count and check if all views are processed
                        completionCount += 1
                        if completionCount == documentCount {
                            NSLayoutConstraint.activate([
                                lastBottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -spacingBetweenRectangles)
                            ])
                            self.view.layoutIfNeeded()  // Ensure all layout updates are processed
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleRectangleTap(_ sender: UITapGestureRecognizer) {
        if let rectangleView = sender.view {
            let data = rectangleView.accessibilityLabel?.split(separator: "|").map(String.init)
            guard let emoji = data?[0], let date = data?[1] else { return }
            
            let mood = (data?.count ?? 0) > 2 ? data?[2] : nil
            
            let modalVC = DetailedEntryViewController()
            modalVC.setupWithData(emoji: emoji, date: date, mood: mood ?? "")  // Handle optional mood
            modalVC.modalPresentationStyle = .overCurrentContext
            modalVC.modalTransitionStyle = .crossDissolve
            present(modalVC, animated: true, completion: nil)
        }
    }


    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Action Needed", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showNoDataFound() {
        let messageLabel = UILabel()
        messageLabel.text = "No Data Found"
        messageLabel.textColor = UIColor(red: 132/255, green: 136/255, blue: 132/255, alpha: 1)
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(messageLabel)  // Add to scrollView directly for better centering

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            messageLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -(scrollView.bounds.height / 4)),
//            // Adjust based on your view's padding and header sizes
            messageLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    func clearContentView() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.subviews.forEach { subview in
            if subview is UILabel && (subview as! UILabel).text == "No Data Found" {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mapEmojiTagToEmoji(emojiTag: String) -> String {
        let emojiTags = ["VHappy", "Happy", "Neutral", "Sad", "VSad"]
        let emojis = ["😄", "🙂", "😐", "🙁", "😡"]

        if let index = emojiTags.firstIndex(of: emojiTag) {
            return emojis[index]
        }

        return "" // Return a default emoji or an empty string if not found
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy" // Example: April 5, 2024
        return dateFormatter.string(from: date)
    }
    
    //what days are in a month
    func monthDateRange(from date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start)!
        return (start, end)
    }

    
    func setupScrollView() {
        scrollView = UIScrollView()
        contentView = UIView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Important to ensure vertical scrolling only
        ])
    }
    func adjustScrollViewContentSize(lastBottomAnchor: NSLayoutYAxisAnchor) {
        NSLayoutConstraint.activate([
            lastBottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // adjust constant as needed
        ])
    }
    

    func setupContents(in rectangleView: UIView, emoji: String, date: String, mood: String){
        print("inside setupContent", mood)
        let emojiImg = UILabel()
        emojiImg.text = emoji
        emojiImg.translatesAutoresizingMaskIntoConstraints = false
        emojiImg.font = UIFont.systemFont(ofSize: 50)
        emojiImg.layer.shadowColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1).cgColor
        emojiImg.layer.shadowOpacity = 0.5 // Adjust this value to make the shadow lighter or darker
        emojiImg.layer.shadowOffset = CGSize(width: 0, height: 2) // Adjust as needed
        emojiImg.layer.shadowRadius = 7 // This blurs the shadow making it softer
        emojiImg.layer.masksToBounds = false
        rectangleView.addSubview(emojiImg)
        
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont(name: "MontserratRoman-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        rectangleView.addSubview(dateLabel)
        
        let moodLabel = UILabel()
        let cleanMood = mood.replacingOccurrences(of: "\n", with: " ")
        moodLabel.text = truncateText(cleanMood, toLength: 19)
        moodLabel.textColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1) // Purple color
        moodLabel.font = UIFont(name: "MontserratRoman-SemiBold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        rectangleView.addSubview(moodLabel)
        
        
        NSLayoutConstraint.activate([
            emojiImg.leadingAnchor.constraint(equalTo: rectangleView.leadingAnchor, constant: 20),
            emojiImg.centerYAnchor.constraint(equalTo: rectangleView.centerYAnchor),
            emojiImg.widthAnchor.constraint(equalToConstant: 50),
            emojiImg.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: emojiImg.trailingAnchor, constant: 20),
            dateLabel.topAnchor.constraint(equalTo: moodLabel.bottomAnchor, constant: 5)
        ])
        
        NSLayoutConstraint.activate([
            moodLabel.leadingAnchor.constraint(equalTo: emojiImg.trailingAnchor, constant: 20),
            moodLabel.topAnchor.constraint(equalTo: rectangleView.topAnchor, constant: 25),
        ])
    }
    
    func truncateText(_ text: String, toLength length: Int) -> String {
        guard text.count > length else { return text }
        let index = text.index(text.startIndex, offsetBy: length)
        return String(text[..<index]) + "..."
    }
    

}




