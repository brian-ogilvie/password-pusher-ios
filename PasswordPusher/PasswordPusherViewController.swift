//
//  PasswordPusherViewController.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 3/22/19.
//  Copyright © 2019 Brian Ogilvie Development. All rights reserved.

//
import UIKit

class PasswordPusherViewController: UIViewController {
    
    //MARK:- Storyboard
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet { passwordTextField.delegate = self }
    }
    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var passwordDaysToExpireStackView: UIStackView!
    @IBOutlet weak var passwordDaysToExpireSlider: UISlider!
    @IBOutlet weak var passwordDaysToExpireLabel: UILabel!
    @IBOutlet weak var passwordViewsToExpireStackView: UIStackView!
    @IBOutlet weak var passwordViewsToExpireSlider: UISlider!
    @IBOutlet weak var passwordViewsToExpireLabel: UILabel!
    
    @IBOutlet weak var optionalPasswordDeleteSwitch: UISwitch!
    @IBOutlet weak var saveDefaultSettingsSwitch: UISwitch!
    @IBOutlet weak var pushPasswordButton: UIButton!
    @IBOutlet weak var backgroundActivitySpinner: UIActivityIndicatorView!
    
    private var passwordExpirationTextField: UITextField?
    private var passwordExpirationTextFieldIsAnimating = false
    
    //MARK:- Settings
    private var passwordDaysToExpire: Int {
        return Int(passwordDaysToExpireSlider.value)
    }
    private var passwordViewsToExpire: Int {
        return Int(passwordViewsToExpireSlider.value)
    }
    private var passwordOptionalDelete: Bool {
        get {
            return optionalPasswordDeleteSwitch.isOn
        } set {
            optionalPasswordDeleteSwitch.setOn(newValue, animated: true)
        }
    }
    private var saveDefaultSettings: Bool {
        get {
            return saveDefaultSettingsSwitch.isOn
        } set {
            saveDefaultSettingsSwitch.setOn(newValue, animated: true)
        }
    }
    
    //MARK:- VCLC
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreSettings()
        addBackgroundTapGestureRecognizer()
        addExpireLabelTapGestureRecognizer(to: passwordDaysToExpireLabel)
        addExpireLabelTapGestureRecognizer(to: passwordViewsToExpireLabel)
        checkOnePasswordAvailable();
        setNeedsStatusBarAppearanceUpdate()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detectClipboardContent()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    //MARK:- IBActions
    @IBAction func onePasswordButtonPressed(_ sender: UIButton) {
        onePasswordHandler.searchOnePassword(for: URLs.onePasswordSearch, presentOn: self, sender: sender, success: handleOnePasswordSearchSuccess(_:), failure: handleOnePasswordSearchError(_:))
    }
    @IBAction func passwordDaysToExpireSliderValueChanged(_ sender: UISlider) {
        removeExpirationTextField()
        displaySliderInfo()
    }
    @IBAction func passwordViewsToExpireSliderValueChanged(_ sender: UISlider) {
        removeExpirationTextField()
        displaySliderInfo()
    }
    @IBAction func pushPasswordButtonPressed(_ sender: UIButton) {
        performPasswordPush()
    }
    
    //MARK:- Model
    private let passwordPusherHandler = PasswordPusherHandler()
    private let settingsManager = PasswordPusherSettingsManager()
    private let onePasswordHandler = OnePasswordHandler()

    //MARK:- Private Functions
    private func handleOnePasswordSearchSuccess(_ password: String) {
        passwordTextField.text = password
    }
    
    private func handleOnePasswordSearchError(_ error: Error?) {
        showBasicAlert(message: Strings.onePasswordSearchError)
    }
    
    private func performPasswordPush() {
        guard let passwordText = passwordTextField!.text?.trimmingCharacters(in: .whitespaces), !passwordText.isEmpty else {
            showBasicAlert(message: Strings.noPasswordError)
            return
        }
        dismissKeyboard()
        toggleSpinner(on: true)
        passwordPusherHandler.handlePush(
            password: passwordText,
            expireDays: passwordDaysToExpire,
            expireViews: passwordViewsToExpire,
            success: handleSessionSuccess(_:),
            failure: handleSessionError(_:)
        )
    }
    
    private func handleSessionSuccess(_ url: String) {
        DispatchQueue.main.async { [weak self] in
            self?.toggleSpinner(on: false)
            self?.shareURL(url)
        }
    }
    
    private func handleSessionError(_ error: UrlSessionError) {
        DispatchQueue.main.async { [weak self] in
            self?.toggleSpinner(on: false)
            self?.showBasicAlert(message: error.localizedDescription)
        }
    }
    
    private func shareURL(_ urlString: String) {
        assert(URL(string: urlString) != nil, Strings.invalidUrlErrorMessage)
        let itemProvider = SharePasswordActivityItemProvider(urlToShare: urlString)
        let shareSheet = UIActivityViewController(activityItems: [itemProvider], applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { [weak self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                self?.showBasicAlert(message: Strings.passwordNotShared)
            } else {
                self?.displayShareSuccessMessage()
                self?.saveSettings()
                self?.restoreSettings()
            }
        }
        present(shareSheet, animated: true, completion: nil)
        //activityVC is presented inside popoverVC on iPad
        if let popOver = shareSheet.popoverPresentationController {
            popOver.sourceView = view
            popOver.sourceRect = pushPasswordButton.frame
        }
    }
    

    
    private func restoreSettings() {
        passwordTextField!.text = nil
        
        let settings = settingsManager.restoreSettings()
        passwordViewsToExpireSlider.setValue(Float(settings.viewsToExpire), animated: true)
        passwordDaysToExpireSlider.setValue(Float(settings.timeToExpire), animated: true)
        passwordOptionalDelete = settings.optionalDelete
        saveDefaultSettings = settings.saveDefaults
        
        displaySliderInfo()
    }
    
    private func saveSettings() {
        settingsManager.saveUserDefaults(time: passwordDaysToExpire, views: passwordViewsToExpire, delete: passwordOptionalDelete, save: saveDefaultSettings)
    }
    
    private func displaySliderInfo() {
        passwordDaysToExpireLabel.text = createExpirationString(for: passwordDaysToExpire, with: "Day")
        passwordViewsToExpireLabel.text = createExpirationString(for: passwordViewsToExpire, with: "View")
    }
    
    private func createExpirationString(for number: Int, with noun: String) -> String {
        return "\(number) \(noun)" + (number == 1 ? "" : "s")
    }
    
    private func toggleSpinner(on: Bool) {
        if on {
            pushPasswordButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0), for: .normal)
            backgroundActivitySpinner.startAnimating()
        } else {
            pushPasswordButton.setTitleColor(UIColor(named: "Button Text"), for: .normal)
            backgroundActivitySpinner.stopAnimating()
        }
    }
    
    private func checkOnePasswordAvailable() {
        onePasswordButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
    }
    
    private func addBackgroundTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func addExpireLabelTapGestureRecognizer(to label: UILabel) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayExpirationField(recognizer:)))
        label.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //displays UITextField to enter expiration days or views
    @objc private func displayExpirationField(recognizer: UITapGestureRecognizer) {
        removeExpirationTextField()
       
        //avoid multiple text fields being put on screen at once
        guard let sender = recognizer.view as? UILabel, !passwordExpirationTextFieldIsAnimating else {return}
        passwordExpirationTextFieldIsAnimating = true
        
        let placeholder = sender == passwordDaysToExpireLabel ? passwordDaysToExpireLabel.text! : passwordViewsToExpireLabel.text!
        let tag = sender == passwordDaysToExpireLabel ? TextFieldTag.daysToExpire.rawValue : TextFieldTag.viewsToExpire.rawValue
        passwordExpirationTextField = createExpirationTextField(placeholder: placeholder, tag: tag)
        view.addSubview(passwordExpirationTextField!)
        matchConstraints(of: passwordExpirationTextField!, to: sender)
        UIView.animate(withDuration: AnimationConstants.textFieldFadeIn, animations: { [weak self] in
            self?.passwordExpirationTextField!.alpha = 1
        }) { (complete) in
            if complete {
                self.passwordExpirationTextFieldIsAnimating = false
                self.passwordExpirationTextField!.becomeFirstResponder()
            }
        }
    }
    
    private func createExpirationTextField(placeholder: String, tag: Int) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.tag = tag
        textField.delegate = self
        textField.backgroundColor = UIColor(named: "TextField BG")
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.alpha = 0
        return textField
    }
    
    private func removeExpirationTextField() {
        if let existingField = passwordExpirationTextField {
            existingField.endEditing(true)
        }
    }
    
    private func displayShareSuccessMessage() {
        let successMessageLabel = createSuccessMessageLabel(with: Strings.passwordSuccessfullySharedMessage)
        view.addSubview(successMessageLabel)
        let successMessageLabelConstraints = createSuccessLabelConstraints(label: successMessageLabel)
        NSLayoutConstraint.activate(successMessageLabelConstraints)
        
        UIView.animate(withDuration: AnimationConstants.successMessageFade, animations: {
            successMessageLabel.alpha = 1
        }) { (complete) in
            if complete {
                UIView.animate(
                    withDuration: AnimationConstants.successMessageFade,
                    delay: AnimationConstants.successMessageLinger, options: [],
                    animations: {
                        successMessageLabel.alpha = 0
                },
                    completion: { (complete) in
                        if complete {
                            NSLayoutConstraint.deactivate(successMessageLabelConstraints)
                            successMessageLabel.removeFromSuperview()
                        }
                })
            }
        }
    }
  
    //only show Clipboard alert once
    private var pasteHasBeenOffered = false
    
    private func detectClipboardContent() {
        let pasteboard = UIPasteboard.general
        guard !pasteHasBeenOffered, let pasteboardString = pasteboard.string else { return }
        offerToPasteFromClipboard(pasteboardString)
        pasteHasBeenOffered = true
    }
    
    private func offerToPasteFromClipboard(_ pasteboardString: String) {
        let title = "Use Clipboard?"
        let message = "You currently have text in your clipboard. Would you like to use your clipboard as input?"
        let yesString = "Use Clipboard"
        let noString = "Don't Use Clipboard"
        let pasteAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: yesString, style: .default) { [weak self] (action) in
            self?.passwordTextField.text = pasteboardString
        }
        pasteAlertController.addAction(yesAction)
        let noAction = UIAlertAction(title: noString, style: .default, handler: nil)
        pasteAlertController.addAction(noAction)
        pasteAlertController.preferredAction = yesAction
        
        present(pasteAlertController, animated: true, completion: nil)
    }

    
    private func createSuccessMessageLabel(with text: String) -> UILabel {
        let successLabel = UILabel()
        successLabel.backgroundColor = UIColor(named: "Push Button BG")
        successLabel.textColor = UIColor(named: "Body Text")
        successLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(Constants.successMessageFontSize)
        successLabel.numberOfLines = 0
        successLabel.textAlignment = .center
        successLabel.text = text
        successLabel.alpha = 0
        return successLabel
    }
    
    private func createSuccessLabelConstraints(label: UILabel) -> [NSLayoutConstraint] {
        label.translatesAutoresizingMaskIntoConstraints = false
        let messageCenterX = label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let messageCenterY = label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Constants.successMessageYConstant)
        let messageWidth = label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
        let messageConstraints = [messageCenterX, messageCenterY, messageWidth]
        return messageConstraints
    }
}

extension PasswordPusherViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordExpirationTextField {
            let sliderToUpdate = textField.tag == TextFieldTag.daysToExpire.rawValue ? passwordDaysToExpireSlider : passwordViewsToExpireSlider
            if let textVal = textField.text, let numberVal = Int(textVal) {
                sliderToUpdate?.setValue(Float(exactly: numberVal)!, animated: true)
                displaySliderInfo()
            }
            deactivateConstraints(from: textField)
            animateOffTextField(textField)
        }
    }
    
    private func animateOffTextField(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConstants.textFieldFadeIn, animations: {
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
    
    @objc private func dismissKeyboard() {
        passwordTextField.resignFirstResponder()
        passwordExpirationTextField?.resignFirstResponder()
    }
}

extension PasswordPusherViewController {
    private struct AnimationConstants {
        static let textFieldFadeIn: TimeInterval = 0.3
        static let successMessageFade: TimeInterval = 0.5
        static let successMessageLinger: TimeInterval = 1
    }
    
    private struct Constants {
        static let successMessageFontSize: CGFloat = 24
        static let successMessageYConstant: CGFloat = -50
    }
    
    private struct URLs {
        static let onePasswordSearch = "www.pwpush.com"
    }
    
    private struct Strings {
        static let passwordSuccessfullySharedMessage = "Your password has been shared!"
        static let passwordNotShared = "Password not shared."
        static let noPasswordError = "Please enter a password. It needs to have at least one character."
        static let onePasswordSearchError = "Password not retrieved from OnePassword"
        static let invalidUrlErrorMessage = "String is not a valid URL."
    }

    private enum TextFieldTag: Int {
        case daysToExpire = 1000
        case viewsToExpire = 1001
    }
}
