//
//  OnboardingViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/28/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, OnboardingPageViewControllerDelegate {

    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var nextButton: UIButton!

    var pageViewController: OnboardingPageViewController? = nil
    var pageIndex = 0
    var pageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if( pageIndex >= pageCount - 1){
            dismiss(animated: true, completion: nil)
        } else {
            pageViewController?.scrollToNextViewController()
        }
    }
    
    func onboardingPageViewController(_ onboardingPageViewController: OnboardingPageViewController, didUpdatePageCount count: Int) {
        pageCount = count
    }
    
    func onboardingPageViewController(_ onboardingPageViewController: OnboardingPageViewController, didUpdatePageIndex index: Int) {
        pageIndex = index
        if pageIndex >= pageCount - 1 {
            nextButton.setTitle("Done", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageVC = segue.destination as? OnboardingPageViewController {
            pageViewController = pageVC
            pageViewController?.onboardingDelegate = self
        }
    }

}
