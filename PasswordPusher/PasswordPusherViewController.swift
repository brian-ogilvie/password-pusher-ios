//
//  PasswordPusherViewController.swift
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

class PasswordPusherViewController: UIViewController {
    
    //MARK:- Storyboard
    
    @IBOutlet weak var password: UITextField! {
        didSet { password.delegate = self }
    }
    @IBOutlet weak var onePasswordBtn: UIButton!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var viewsStackView: UIStackView!
    @IBOutlet weak var viewsSlider: UISlider!
    @IBOutlet weak var viewsLbl: UILabel!
    
    @IBOutlet weak var optionalDeleteSwitch: UISwitch!
    @IBOutlet weak var saveDefaultsSwitch: UISwitch!
    @IBOutlet weak var pushButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var expirationTxtField: UITextField?
    private var expirationFieldIsAnimating = false
    
    //MARK:- Settings
    private var timeToExpire: Int {
        return Int(timeSlider.value)
    }
    private var viewsToExpire: Int {
        return Int(viewsSlider.value)
    }
    private var optionalDelete: Bool {
        get {
            return optionalDeleteSwitch.isOn
        } set {
            optionalDeleteSwitch.setOn(newValue, animated: true)
        }
    }
    private var saveDefaults: Bool {
        get {
            return saveDefaultsSwitch.isOn
        } set {
            saveDefaultsSwitch.setOn(newValue, animated: true)
        }
    }

    //MARK:- IBActions
    @IBAction func findLoginFrom1Password(_ sender: UIButton) {
        OnePasswordExtension.shared().findLogin(forURLString: URLs.onePswdSearch, for: self, sender: sender) { (loginDictionary, error) in
            if let loginDictionary = loginDictionary {
                self.password.text = loginDictionary[AppExtensionPasswordKey] as? String ?? nil;
            }
        }
    }
    @IBAction func timeSliderChanged(_ sender: UISlider) {
        removeEpirationTextField()
        displaySliderInfo()
    }
    @IBAction func viewsSliderChanged(_ sender: UISlider) {
        removeEpirationTextField()
        displaySliderInfo()
    }
    @IBAction func pushButtonDidTap(_ sender: UIButton) {
        performPush()
    }
    
    let passwordPusherHandler = PasswordPusherHandler()

    //MARK:- Functions
    private func performPush() {
        guard password!.text != nil && password!.text! != "" else {
            self.present(showBasicAlert(message: Strings.noPswdError), animated: true, completion: nil)
            return
        }
        toggleSpinner(on: true)
        let myPassword = password!.text!
        passwordPusherHandler.handlePush(password: myPassword, expireDays: timeToExpire, expireViews: viewsToExpire)
        saveUserDefaults()
    }
    
    private func handleSessionError(_ message: String) {
        toggleSpinner(on: false)
        self.present(showBasicAlert(message: message), animated: true)
    }
    
    private let userDefaultsManager = PasswordPusherUserDefaultsManager()
    
    private func restoreDefaults() {
        password!.text = nil
        
        let defaults = userDefaultsManager.restoreDefaults()
        viewsSlider.setValue(Float(defaults.viewsToExpire), animated: true)
        timeSlider.setValue(Float(defaults.timeToExpire), animated: true)
        optionalDelete = defaults.optionalDelete
        saveDefaults = defaults.saveDefaults
        
        displaySliderInfo()
    }
    
    private func saveUserDefaults() {
        let defaults = DefaultSettings(time: timeToExpire, views: viewsToExpire, delete: optionalDelete, save: saveDefaults)
        userDefaultsManager.saveUserDefaults(defaults: defaults)
    }
    
    private func displaySliderInfo() {
        timeLbl.text = "\(timeToExpire) Days"
        viewsLbl.text = "\(viewsToExpire) Views"
    }
    
    private func toggleSpinner(on: Bool) {
        if on {
            pushButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0), for: .normal)
            spinner.startAnimating()
        } else {
            pushButton.setTitleColor(UIColor(named: "Button Text"), for: .normal)
            spinner.stopAnimating()
        }
    }
    
    private func checkOnePswdAvailable() {
        onePasswordBtn.isHidden = (false == OnePasswordExtension.shared().isAppExtensionAvailable())
    }
    
    private func addBgTapRecognizer() {
        //Calls func to dismiss keyboard and reveal rest of the screen when background is tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    //Gesture recognizer for expiration labels
    private func addLblTapRecognizer(to label: UILabel) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(displayExpirationField(recognizer:)))
        label.addGestureRecognizer(tap)
    }
    
    //displays UITextField to enter expiration days or views
    @objc private func displayExpirationField(recognizer: UITapGestureRecognizer) {
        removeEpirationTextField()
       
        //avoid multiple text fields being put on screen at once
        guard !expirationFieldIsAnimating else {return}
        expirationFieldIsAnimating = true
        
        if let sender = recognizer.view as? UILabel {
            expirationTxtField = UITextField(frame: sender.frame)
            expirationTxtField!.delegate = self
            expirationTxtField!.backgroundColor = UIColor(named: "TextField BG")
            expirationTxtField!.textAlignment = .center
            expirationTxtField!.placeholder = sender == timeLbl ? "\(timeToExpire) Days" : "\(viewsToExpire) Views"
            expirationTxtField!.keyboardType = .numberPad
            //Tag says which slider to update on textFieldDidEndEditing
            expirationTxtField!.tag = sender == timeLbl ? 1 : 2
            expirationTxtField!.alpha = 0
            view.addSubview(expirationTxtField!)
            matchConstraints(of: expirationTxtField!, to: sender)
            UIView.animate(withDuration: AnimationConstants.txtFieldFadeIn, animations: {
                self.expirationTxtField!.alpha = 1
            }) { (complete) in
                if complete {
                    self.expirationFieldIsAnimating = false
                    self.expirationTxtField!.becomeFirstResponder()
                }
            }
        }
    }
    
    // removes any existing expiration text field
    private func removeEpirationTextField() {
        if let existingField = expirationTxtField {
            existingField.endEditing(true)
        }
    }
    
    // called after mail VC is dismissed
    func mailFinished(sent: Bool) {
        if sent {
            displayMailSuccessMsg()
            restoreDefaults()
        } else {
            present(showBasicAlert(message: Strings.mailFail), animated: true, completion: nil)
        }
    }
    
    //displays a success message after sending email
    func displayMailSuccessMsg() {
        let successLbl = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize.zero))
        successLbl.backgroundColor = UIColor(named: "Push Button BG")
        successLbl.textColor = UIColor(named: "Body Text")
        successLbl.font = UIFont.preferredFont(forTextStyle: .body).withSize(Constants.successMsgFontSize)
        successLbl.numberOfLines = 0
        successLbl.textAlignment = .center
        successLbl.text = Strings.successMsg
        successLbl.alpha = 0
        
        successLbl.translatesAutoresizingMaskIntoConstraints = false
        let msgCenterX = successLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let msgCenterY = successLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Constants.successMsgYConstant)
        let msgWidth = successLbl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
        let msgConstraints = [msgCenterX, msgCenterY, msgWidth]
        
        view.addSubview(successLbl)
        NSLayoutConstraint.activate(msgConstraints)
        
        UIView.animate(withDuration: AnimationConstants.successMsgFade, animations: {
            successLbl.alpha = 1
        }) { (complete) in
            if complete {
                UIView.animateKeyframes(
                    withDuration: AnimationConstants.successMsgFade,
                    delay: AnimationConstants.successMsgLinger, options: [],
                    animations: {
                        successLbl.alpha = 0
                    },
                    completion: { (complete) in
                    if complete {
                        NSLayoutConstraint.deactivate(msgConstraints)
                        successLbl.removeFromSuperview()
                    }
                })
            }
        }
    }

    //MARK:- VCLC
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordPusherHandler.delegate = self
        restoreDefaults()
        addBgTapRecognizer()
        addLblTapRecognizer(to: timeLbl)
        addLblTapRecognizer(to: viewsLbl)
        //TODO: fix checkOnePswdAvailable
//        checkOnePswdAvailable();
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension PasswordPusherViewController: PasswordPusherHandlerDelegate {
    func handleSessionSuccess(url: String) {
        toggleSpinner(on: false)
        self.presentMailComposeVC(urlToEmail: url)
    }
    
    func handleSessionError(message: String) {
        toggleSpinner(on: false)
        self.present(showBasicAlert(message: message), animated: true, completion: nil)
    }
}

extension PasswordPusherViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == expirationTxtField {
            let sliderToUpdate = textField.tag == 1 ? timeSlider : viewsSlider
            if let textVal = textField.text, let numberVal = Int(textVal) {
                sliderToUpdate?.setValue(Float(exactly: numberVal)!, animated: true)
                displaySliderInfo()
            }
            deactivateConstraints(from: textField)
            animateOffTxtField(textField)
        }
    }
    
    private func animateOffTxtField(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConstants.txtFieldFadeIn, animations: {
            textField.alpha = 0
        }) { (complete) in
            if complete {
                textField.removeFromSuperview()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //called when view background is tapped
    @objc private func dismissKeyboard() {
        password.resignFirstResponder()
        expirationTxtField?.resignFirstResponder()
    }
}

extension PasswordPusherViewController {
    private struct AnimationConstants {
        static let txtFieldFadeIn: TimeInterval = 0.3
        static let successMsgFade: TimeInterval = 0.5
        static let successMsgLinger: TimeInterval = 1
    }
    
    private struct Constants {
        static let successMsgFontSize: CGFloat = 24
        static let successMsgYConstant: CGFloat = -50
    }
    
    private struct URLs {
        static let onePswdSearch = "www.pwpush.com"
    }
    
    private struct Strings {
        static let successMsg = "Your password has been sent!"
        static let mailFail = "Mail could not be sent."
        static let noPswdError = "Please enter a password"
    }
}
