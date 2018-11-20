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
        displaySliderInfo()
    }
    @IBAction func viewsSliderChanged(_ sender: UISlider) {
        displaySliderInfo()
    }
    @IBAction func pushButtonDidTap(_ sender: UIButton) {
        performPush()
    }

    //MARK:- performPush
    private func performPush() {
        guard password!.text != nil && password!.text! != "" else {
            self.present(showBasicAlert(message: Strings.noPswdError), animated: true, completion: nil)
            return
        }
        
        toggleSpinner(on: true)
        
        let myPassword = password!.text
        guard let url = URL(string: URLs.arctouchAPI) else {
            print("Unable to create url")
            return
        }
        let parameters = ["payload": myPassword, "expire_after_days": String(timeToExpire), "expire_after_views": String(viewsToExpire)]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Unable to create httpBody")
            return
        }
        request.httpBody = httpBody
        //TODO: add ability to cancel operation if long response time

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if response == nil {
                DispatchQueue.main.async {
                    self.handleSessionError(Strings.noServerResponse)
                }
            }
            if let data = data {
                do {
                    let pwPushObject = try JSONDecoder().decode(PwPushObject.self, from: data)
                    let urlToEmail = URLs.arctouchPrefix + pwPushObject.urlToken
                    DispatchQueue.main.async {
                        self.toggleSpinner(on: false)
                        self.presentMailComposeVC(urlToEmail: urlToEmail)
                    }
                } catch let sessionError {
                    DispatchQueue.main.async {
                        self.handleSessionError(String(describing: sessionError))
                    }
                }
            }
        }.resume()
        saveUserDefaults()
    }
    
    private func handleSessionError(_ message: String) {
        toggleSpinner(on: false)
        self.present(showBasicAlert(message: message), animated: true)
    }
    
    private func restoreDefaults() {
        password!.text = nil
        //if settings have been saved before, restore from UserDefaults
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.saveDefaults.rawValue) == true {
            viewsSlider.setValue(UserDefaults.standard.float(forKey: UserDefaultsKeys.viewsToExpire.rawValue), animated: true)
            timeSlider.setValue(UserDefaults.standard.float(forKey: UserDefaultsKeys.timeToExpire.rawValue), animated: true)
            optionalDelete = UserDefaults.standard.bool(forKey: UserDefaultsKeys.optionalDelete.rawValue)
            saveDefaults = UserDefaults.standard.bool(forKey: UserDefaultsKeys.saveDefaults.rawValue)
        } else { //restore from FactoryDefaults
            viewsSlider.setValue(FactoryDefaults.viewsToExpire, animated: true)
            timeSlider.setValue(FactoryDefaults.timeToExpire, animated: true)
            optionalDelete = FactoryDefaults.optionalDelete
            saveDefaults = FactoryDefaults.saveDefaults
        }
        displaySliderInfo()
    }
    
    private func saveUserDefaults() {
        if saveDefaults { //if user has selected to save settings for future
            UserDefaults.standard.set(viewsToExpire, forKey: UserDefaultsKeys.viewsToExpire.rawValue)
            UserDefaults.standard.set(timeToExpire, forKey: UserDefaultsKeys.timeToExpire.rawValue)
            UserDefaults.standard.set(optionalDelete, forKey: UserDefaultsKeys.optionalDelete.rawValue)
            UserDefaults.standard.set(saveDefaults, forKey: UserDefaultsKeys.saveDefaults.rawValue)
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.saveDefaults.rawValue)
        }
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
        if let existingField = expirationTxtField {
            existingField.endEditing(true)
        }
       
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

private struct FactoryDefaults {
    static let timeToExpire: Float = 7
    static let viewsToExpire: Float = 5
    static let optionalDelete: Bool = true
    static let saveDefaults: Bool = false
}

private enum UserDefaultsKeys: String {
    case saveDefaults
    case timeToExpire
    case viewsToExpire
    case optionalDelete
}

private struct URLs {
    static let pwPushAPI = "https://pwpush.com/p.json"
    static let arctouchAPI = "https://pwpush.arctouch.com/passwords.json"
    static let onePswdSearch = "www.pwpush.com"
    static let pwPushPrefix = "https://pwpush.com/p/"
    static let arctouchPrefix = "https://pwpush.arctouch.com/p/"
    static let placeholder = "https://jsonplaceholder.typicode.com/todos/1/posts"
}

private struct AnimationConstants {
    static let txtFieldFadeIn: TimeInterval = 0.3
    static let successMsgFade: TimeInterval = 0.5
    static let successMsgLinger: TimeInterval = 1
}

private struct Constants {
    static let successMsgFontSize: CGFloat = 24
    static let successMsgYConstant: CGFloat = -50
}

private struct Strings {
    static let successMsg = "Your password has been sent!"
    static let mailFail = "Mail could not be sent."
    static let noPswdError = "Please enter a password"
    static let noServerResponse = "Unable to get response from server."
}

