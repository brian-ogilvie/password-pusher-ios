//
//  ViewController.swift
//  PasswordPusher
//
//  Created by Brian Ogilvie on 9/27/18.
//  Copyright © 2018 Brian Ogilvie Development. All rights reserved.
//

import UIKit

class PwPushViewController: UIViewController {
    
    //MARK:- Storyboard
    
    @IBOutlet weak var password: UITextField! {
        didSet { password.delegate = self }
    }
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeLbl: UILabel!
    @IBAction func timeSliderChanged(_ sender: UISlider) {
        displaySliderInfo()
    }
    @IBOutlet weak var viewsSlider: UISlider!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBAction func viewsSliderChanged(_ sender: UISlider) {
        displaySliderInfo()
    }
    @IBOutlet weak var optionalDeleteSwitch: UISwitch!
    @IBOutlet weak var saveDefaultsSwitch: UISwitch!
    @IBOutlet weak var pushButton: UIButton!
    @IBAction func pushButtonDidTap(_ sender: UIButton) {
        performPush()
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
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
    
    //MARK:- performPush
    private func performPush() {
        guard password!.text != nil && password!.text! != "" else {
            self.present(showBasicAlert(message: "Please enter a password"), animated: true, completion: nil)
            return
        }
        
        toggleSpinner(on: true)
        
        let myPassword = password!.text
        guard let url = URL(string: URLs.placeholder) else {
            print("Unable to create url")
            return
        }
        let parameters = ["password[payload]": myPassword, "password[expire_after_days]": String(timeToExpire), "password[expire_after_views]": String(viewsToExpire), "password[deletable_by_viewer]": String(optionalDelete)]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Unable to create httpBody")
            return
        }
        request.httpBody = httpBody

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("response: \(response)")
            }
            if let data = data {
                
                //TODO: move this into do block when POST request is working
                let urlToEmail = "https://www.thisdoesntworkyet.com/tick-tock"
                DispatchQueue.main.async {
                    self.toggleSpinner(on: false)
                    self.presentMailComposeVC(urlToEmail: urlToEmail)
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("JSON Data: \(json)")
                } catch {
                    print("My Error: \(error)")
                }
            }
        }.resume()
        saveUserDefaults()
        
//        let parameters = ["password[payload]": "myPassword", "password[expire_after_days]": "3", "password[expire_after_views]": "10", "password[deletable_by_viewer]": "true"]
//
//        var request = URLRequest(url: URL(string: URLs.placeholder)!)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        if let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
//
//            request.httpBody = httpBody
//
//            let session = URLSession.shared
//            session.dataTask(with: request) { (data, response, error) in
//                if let response = response {
//                    print(response)
//                    // Gives me a status code of 200
//                }
//                if let data = data {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: [])
//                        print(json)
//                        // I want to parse out the resulting URL to send to clients
//                        // Just like you do in the Javascript alert in the wiki example
//                    } catch {
//                        print("My Error: \(error)")
//                        // I get an error
//                        // data is actually a full HTML page, not parsable JSON
//                    }
//                }
//            }.resume()
//        }
    }
    
    private func restoreDefaults() {
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
    
    private func addBgTapRecognizer() {
        //Calls func to dismiss keyboard and reveal rest of the screen when background is tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    //MARK:- VCLC
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreDefaults()
        displaySliderInfo()
        addBgTapRecognizer()
    }
}

extension PwPushViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyboard() {
        password.resignFirstResponder()
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
    static let pwPush = "https://pwpush.com/p.json"
    static let placeholder = "https://jsonplaceholder.typicode.com/todos/1/posts"
}

