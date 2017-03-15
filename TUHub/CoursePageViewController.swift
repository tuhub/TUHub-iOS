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
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        delegate = self
        dataSource = self
        pages = [UIViewController]()
        
    }

}

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
        return 0
    }
    
}
