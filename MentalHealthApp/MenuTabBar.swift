//
//  MenuTabBar.swift
//  MentalHealthApp
//
//  Created by Nethra NEU on 4/2/24.
//

import Foundation
import UIKit
import Firebase

class MenuTabBar: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupMenuItems()
        customizeTabBarAppearance()
        extendedLayoutIncludesOpaqueBars = true
    }
    
    private func setupMenuItems() {
        // Create view controllers for each tab using dummy view controllers for this example
        let dashboardVC = ListDashboard()
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "dashboard"), selectedImage: nil)
        
        let moodTrackerVC = MoodTrackerViewController()
        moodTrackerVC.tabBarItem = UITabBarItem(title: "Mood Tracker", image: UIImage(named: "mood"), selectedImage: nil)
        
        let getHelp = GetHelp() // Replace with actual view controller
        getHelp.tabBarItem = UITabBarItem(title: "Get Help", image: UIImage(named: "support"), selectedImage: nil)
        
        let LogoutPlaceholderVC = UIViewController() // Replace with actual view controller
        LogoutPlaceholderVC.tabBarItem = UITabBarItem(title: "Logout", image: UIImage(named: "logOut"), selectedImage: nil)
        
        // Add the view controllers to the tab bar
        viewControllers = [dashboardVC, moodTrackerVC, getHelp, LogoutPlaceholderVC]
        
        // Additional customization here if needed (e.g., tab bar item positioning, colors)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            // Check if the selected view controller is the logout tab
            if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 3 {
                // Perform logout action here
                logout()
                // Return false to prevent switching to the logout tab
                return false
            }
            // Return true to allow switching to the selected view controller
            return true
        }
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if tabBarController.selectedIndex == 3 { // Assuming logout is the fourth tab
//            logout()
//            print("logout trigerred")
//        }
//    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let signInVC = SignInViewController()
                signInVC.modalPresentationStyle = .fullScreen
                
                // Resetting the root view controller to the SignInViewController
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = signInVC
                    window.makeKeyAndVisible()
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            }
            print("Logout successful!")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    
    private func customizeTabBarAppearance() {
        
        // Ensure translucent tab bar for floating effect
        tabBar.isTranslucent = true
        
        
        // Set the selected item color
        tabBar.tintColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1)
        
        // Customize the appearance of all tab bar items
        let tabBarItemAppearance = UITabBarItemAppearance()
        
        // Set the normal state font, color, etc.
        tabBarItemAppearance.normal.iconColor = UIColor.gray // Example for unselected state
        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        
        // Set the selected state font, color, etc.
        tabBarItemAppearance.selected.iconColor = tabBar.tintColor // Selected icon color
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tabBar.tintColor]
        
        
        // Apply a custom background color with opacity for the floating effect
        let backgroundEffectView = UIView(frame: tabBar.bounds)
        backgroundEffectView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
        backgroundEffectView.layer.cornerRadius = 15
        // Important: Allows clicks to pass through the view to the tab bar items
        backgroundEffectView.isUserInteractionEnabled = false
        
        backgroundEffectView.layer.shadowColor = UIColor(red: 177/255, green: 140/255, blue: 254/255, alpha: 1).cgColor
        backgroundEffectView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        backgroundEffectView.layer.shadowOpacity = 0.2
        backgroundEffectView.layer.shadowRadius = 5
        backgroundEffectView.layer.masksToBounds = false
        
        // Insert the custom background view below the tab bar's content
        tabBar.insertSubview(backgroundEffectView, at: 0)
        
        let insetAmount: CGFloat = -5 // Experiment with this value
        tabBar.items?.forEach { item in
            item.imageInsets = UIEdgeInsets(top: insetAmount, left: 0, bottom: insetAmount, right: 0)
        }
        //
        // This ensures that the custom background view resizes with the tab bar.
        backgroundEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    
}
