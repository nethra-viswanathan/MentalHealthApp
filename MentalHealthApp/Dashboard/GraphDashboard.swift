//
//  GraphDashboard.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/13/24.
//

import Foundation
import UIKit
import SwiftUI
import SwiftUICharts
import Firebase
import FirebaseFirestore
import FSCalendar

// ViewModel to manage data and month navigation
class MoodTrackerViewModel: ObservableObject {
    @Published var dataPoints: [Double] = []
    @Published var emojiCounts: [String: Int] = ["VHappy": 0, "Happy": 0, "Neutral": 0, "Sad": 0, "VSad": 0]
    @Published var currentMonth: Date = Date()
    var showAlert: ((String) -> Void)?
    
    init() {
        fetchData(for: currentMonth)
    }
    
    func fetchData(for date: Date) {
        
        let db = Firestore.firestore()
        let dateRange = monthDateRange(from: date)
        let startTimestamp = Timestamp(date: dateRange.start)
        let endTimestamp = Timestamp(date: dateRange.end)
        
        guard let user = Auth.auth().currentUser else {
            showAlert?("User is not signed in.")
            return
        }
        
        db.collection("moodTracker")
            .whereField("userId", isEqualTo: user.uid)
            .whereField("timestamp", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("timestamp", isLessThanOrEqualTo: endTimestamp)
            .order(by: "timestamp", descending: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.dataPoints = [] // Handle the error appropriately
                } else {
                    var newDataPoints: [Double] = []
                    var counts = [String: Int]()
                    for document in querySnapshot!.documents {
                        let mood = document.get("emoji") as? String ?? ""
                        let moodValue = self.moodValue(from: mood)
                        counts[mood, default: 0] += 1
                        newDataPoints.append(moodValue)
                    }
                    
                    print("newData",newDataPoints)
                    DispatchQueue.main.async {
                        self.dataPoints = newDataPoints
                        self.emojiCounts = counts
                    }
                }
            }
    }
    
    func moodValue(from mood: String) -> Double {
        switch mood {
        case "VHappy":
            return 5
        case "Happy":
            return 4
        case "Neutral":
            return 3
        case "Sad":
            return 2
        case "VSad":
            return 1
        default:
            return 0 // Handle unknown moods
        }
    }
    
    func monthDateRange(from date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start)!
        return (start, end)
    }
    
    func goToNextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        fetchData(for: currentMonth)
    }
    
    func goToPreviousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        fetchData(for: currentMonth)
    }
}

struct GraphDashboard: View {
    @ObservedObject var viewModel: MoodTrackerViewModel
    var onNavigateBackToList: (() -> Void)?
    let chartLineStyle = ChartStyle(backgroundColor: .white, accentColor: .yellow, gradientColor: GradientColor(start: Color(UIColor(red: 241/255, green: 201/255, blue: 254/255, alpha: 1)), end: Color(UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1))), textColor: .black, legendTextColor: .gray, dropShadowColor: .black)
    let emojis = ["😄", "🙂", "😐", "🙁", "😡"]
    var body: some View {
        NavigationView {
            VStack {
                customHeader
                emojiCount.padding(.top, 20)
                //                Spacer().frame(height: 40)
                chartContainer.padding(.top, 20)
                Spacer()
                
            }
            .navigationBarTitle("") // Removes the default navigation title
            .navigationBarHidden(true) // Hide the navigation bar to remove any default elements
            .background(Color(red: 248/255.0, green: 246/255.0, blue: 252/255.0, opacity: 1))
        }
        .alert("Action Needed", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            viewModel.fetchData(for: viewModel.currentMonth)
            viewModel.showAlert = { message in
                alertMessage = message
                showingAlert = true
            }
        }
        .background(Color(red: 248/255.0, green: 246/255.0, blue: 252/255.0, opacity: 1))
        .edgesIgnoringSafeArea(.all)
    }
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var emojiCount: some View {
        let emojiTags = ["VHappy", "Happy", "Neutral", "Sad", "VSad"]
        let emojis = ["😄", "🙂", "😐", "🙁", "😡"]
        
        // Make sure to return the ScrollView directly
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(zip(emojis.indices, emojis)), id: \.0) { index, emoji in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 100, height: 80)
                        .shadow(color: Color(red: 177/255, green: 140/255, blue: 254/255, opacity: 0.5), radius: 4, x: 0, y: 2)
                        .overlay(
                            VStack {
                                Text(emoji)
                                    .font(.largeTitle)
                                Text("\(viewModel.emojiCounts[emojiTags[index], default: 0])")
                                    .bold()
                                    .font(.custom("MontserratRoman-SemiBold", size: 24))
                                    .foregroundColor(Color(red: 177/255, green: 140/255, blue: 254/255))
                            }
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
        }
    }
    
    
    private var chartContainer: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .fill(Color.white)
            .shadow(color: Color(red: 177/255, green: 140/255, blue: 254/255, opacity: 0.5), // Match the color and opacity
                    radius: 4, // Match the shadow radius
                    x: 0, // Horizontal offset
                    y: 2) // Vertical offset
            .padding([.leading, .trailing], 20)
            .overlay(
                LineView(data: viewModel.dataPoints, title: "", style: chartLineStyle)
                    .padding(EdgeInsets(top: 8, leading: 30, bottom: 8, trailing: 30))
                    .animation(.linear(duration: 0.5), value: viewModel.dataPoints)
            )
            .frame(height: 400)
    }
    
    private var customHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                // Dashboard label on the left
                Text("Dashboard")
                    .font(.custom("MontserratRoman-SemiBold", size: 28)) // Custom font, adjust name if needed
                    .foregroundColor(Color(red: 177/255, green: 140/255, blue: 254/255))
                
                Spacer() // Spacer to push content to edges
                
                // List view button (left icon)
                Button(action: {
                    self.onNavigateBackToList?()
                }) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22) // Adjusted size
                        .foregroundColor(Color(UIColor.lightGray))
                        .padding(.trailing, 13)
                    
                }
                
                // Graph view button (right icon)
                Button(action: {
                    
                }) {
                    Image(systemName: "chart.bar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28) // Adjusted size
                        .foregroundColor(Color(red: 177/255, green: 140/255, blue: 254/255))
                }
            }
            .padding([.leading, .trailing], 20) // Padding on the sides
            .padding(.top, 40) // Top padding to match UIKit's layout
            
            HStack {
                Text("Monthly Overview")
                    .font(.custom("MontserratRoman-Medium", size: 18))
                    .foregroundColor(Color(red: 132/255, green: 136/255, blue: 132/255))
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: viewModel.goToPreviousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 177/255, green: 140/255, blue: 254/255))
                    }
                    
                    Text(viewModel.currentMonthLabel)
                        .font(.custom("MontserratRoman-Medium", size: 18))
                        .foregroundColor(Color(red: 177/255, green: 140/255, blue: 254/255))
                    
                    Button(action: viewModel.goToNextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 177/255, green: 140/255, blue: 254/255))
                    }
                }
            }
            .padding([.leading, .trailing], 20)
            .padding([.top], 16)
        }
    }
}

extension MoodTrackerViewModel {
    // Formatting the current month for display
    var currentMonthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YY"
        return formatter.string(from: currentMonth)
    }
}
