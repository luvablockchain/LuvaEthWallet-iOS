//
//  MainTabbarViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/16/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainTabbarViewController: UITabBarController,UITabBarControllerDelegate {

    fileprivate var previousIndex = 0
    
    var scrollEnabled: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        SettingApp.sharedInstance.loadLocalized()
        UITabBar.appearance().tintColor = BaseViewController.MainColor
        self.selectedIndex = 0
        self.previousIndex = self.selectedIndex
        self.delegate = self
        for index in 0..<tabBar.items!.count {
            if(index == 0) {
                tabBar.items![index].title = "Home".localizedString()
            } else if(index == 1) {
                tabBar.items![index].title = "Settings".localizedString()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard scrollEnabled else {
            return
        }
        
        guard let index = viewControllers?.index(of: viewController) else {
            return
        }
        var parentView: UIView = self.view
        
        if index == previousIndex {
            
            if let navigationController = viewController as? UINavigationController {
                if let pagerTabStripViewController = navigationController.topViewController as? PagerTabStripViewController {
                    if let view = pagerTabStripViewController.viewControllers.first?.view {
                        parentView = view
                    }
                    if(pagerTabStripViewController.currentIndex != 0) {
                        pagerTabStripViewController.moveToViewController(at: 0, animated: true)
                        
                        previousIndex = index
                        return
                    }
                    
                }
            }
            
            
            var scrollViews = [UIScrollView]()
            self.iterateThroughSubviews(parentView: parentView) { (scrollView) in
                scrollViews.append(scrollView)
            }
            
            guard let scrollView = scrollViews.first else {
                return
            }
            
            var offset = CGPoint(x: -scrollView.contentInset.left, y: -scrollView.contentInset.top)
            
            if #available(iOS 11.0, *) {
                offset = CGPoint(x: -scrollView.adjustedContentInset.left, y: -scrollView.adjustedContentInset.top)
            }
            scrollView.setContentOffset(offset, animated: true)
        }
        
        previousIndex = index
        
    }
    
    
    private func iterateThroughSubviews(parentView: UIView?, onRecognition: (UIScrollView) -> Void) {
        guard let view = parentView else {
            return
        }
        if let scrollView = parentView as? UIScrollView {
            onRecognition(scrollView)
        }
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView, scrollView.scrollsToTop == true {
                onRecognition(scrollView)
            }
            
            iterateThroughSubviews(parentView: subview, onRecognition: onRecognition)
        }
    }

}
