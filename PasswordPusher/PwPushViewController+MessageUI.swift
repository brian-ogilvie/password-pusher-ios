//
//  PwPushViewController+MessageUI.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 10/1/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit
import MessageUI

extension PwPushViewController: MFMailComposeViewControllerDelegate {
   
    //create an email with the URL to view password
    func configureMailController(urlToEmail url: String) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setSubject("Your new login credentials")
        
        let messageBody = "<p>Your password: <a href='\(url)'>\(url)</a></p>"
        mailComposeVC.setMessageBody(messageBody, isHTML: true)
        
        return mailComposeVC
    }
    
    //show an error if device cannot send mail
    func showMailError() {
        let mailSendAlertVC = UIAlertController(title: "Could not send email", message: "Your device is not configured to send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        mailSendAlertVC.addAction(dismiss)
        self.present(mailSendAlertVC, animated: true, completion: nil)
    }
    
    //present the mail VC
    func presentMailComposeVC(urlToEmail url: String) {
        let mailComposerVC = configureMailController(urlToEmail: url)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    //Delegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
