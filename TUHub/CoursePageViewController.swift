//
//  CoursePageViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/14/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CoursePageViewController: UIPageViewController {
    
    var pages: [UIViewController]!
    var current: CourseListViewController!
    var presentationIndex = 0
    var currentIndex: Int? {
        return pages.index(of: current)
    }
    var terms: [Term]? {
        didSet {
            if let terms = terms {
                for term in terms {
                    if let courseListVC = storyboard?.instantiateViewController(withIdentifier: "courseListVC") as? CourseListViewController {
                        courseListVC.term = term
                        pages.append(courseListVC)
                    }
                }
                if let first = pages.first {
                    setViewControllers([first], direction: .forward, animated: false, completion: nil)
                    current = first as! CourseListViewController
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        pages = [UIViewController]()
    }

    func slideToPage(index: Int, completion: (() -> Void)?) {
        
        var direction: UIPageViewControllerNavigationDirection!
        if index < currentIndex! {
            direction = .reverse
        } else if index > currentIndex! {
            direction = .forward
        } else {
            return
        }
        presentationIndex = index

        let page = pages[index]
        current = page as! CourseListViewController
        setViewControllers([page], direction: direction, animated: true) { _ in
            DispatchQueue.main.async {
                self.setViewControllers([page], direction: direction, animated: false, completion: nil)
            }
        }
    }
    
}

// MARK: - UIPageViewControllerDataSource
extension CoursePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return presentationIndex
    }
    
}

// MARK: - UIPageViewControllerDelegate
extension CoursePageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        current = previousViewControllers.first as? CourseListViewController
    }
    
}
