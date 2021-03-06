//
//  OnboardingPageViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/28/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    weak var onboardingDelegate: OnboardingPageViewControllerDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingId1"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingId2"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingId3"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingId4"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingId5")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    
        onboardingDelegate?.onboardingPageViewController(self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if( (onboardingDelegate?.pageIndex)! < (onboardingDelegate?.pageCount)! - 1 ){
            scrollToViewController(index: (onboardingDelegate?.pageIndex)! + 1 )
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(_ viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyOnboardingDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyOnboardingDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            onboardingDelegate?.onboardingPageViewController(self, didUpdatePageIndex: index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        notifyOnboardingDelegateOfNewIndex()

    }
    
    
}

// MARK: UIPageViewControllerDataSource
extension OnboardingPageViewController {
    

        @objc(pageViewController:viewControllerBeforeViewController:) func pageViewController(_ pageViewController: UIPageViewController,
                                                                                              viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }
    
    @objc(pageViewController:viewControllerAfterViewController:) func pageViewController(_ pageViewController: UIPageViewController,
                                                                                         viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }
}

protocol OnboardingPageViewControllerDelegate: class {
    
    var pageIndex:Int { get }
    var pageCount:Int { get }

    /**
     Called when the number of pages is updated.
     
     - parameter onboardingPageViewController: the OnboardingPageViewController instance
     - parameter count: the total number of pages.
     */
    func onboardingPageViewController(_ onboardingPageViewController: OnboardingPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter onboardingPageViewController: the OnboardingPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func onboardingPageViewController(_ onboardingPageViewController: OnboardingPageViewController,
                                    didUpdatePageIndex index: Int)
    
}
