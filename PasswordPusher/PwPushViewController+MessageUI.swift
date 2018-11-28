//
//  PasswordPusherViewController+MessageUI.swift
//  PasswordPusher
//
// Copyright 2018 ArcTouch, LLC.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import UIKit
import MessageUI

extension PasswordPusherViewController: MFMailComposeViewControllerDelegate {
   
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
        controller.presentingViewController?.dismiss(animated: true, completion: {
            if result == .sent {
                self.mailFinished(sent: true)
            } else if result == MFMailComposeResult.failed {
                self.mailFinished(sent: false)
            }
        })
    }
}
