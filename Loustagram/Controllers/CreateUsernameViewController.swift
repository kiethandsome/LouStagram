//
//  CreateUsernameViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/1/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import DynamicColor
import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController  {
    
    let titileLabel: UILabel = {
       let label = UILabel()
        
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 24),
                                                      .foregroundColor: UIColor.black]
        label.attributedText = NSAttributedString(string: "Create Username", attributes: attribute)
        label.textAlignment = .center
        return label
    }()
    
    let underTitleLabel: UILabel = {
        let label = UILabel()
        
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 16),
                                                      .foregroundColor: UIColor.black]
        label.attributedText = NSAttributedString(string: "Add a username so your friends can find you.",
                                                  attributes: attribute)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let nextButton: UIButton = {
       let btn = UIButton()
        btn.backgroundColor = DynamicColor(hexString: "61A8ED")
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 15),
                                                      .foregroundColor: UIColor.white]
        btn.setAttributedTitle(NSAttributedString(string: "Next", attributes: attribute) , for: .normal)
        btn.layer.cornerRadius = 5.0
        btn.clipsToBounds = true
        return btn
    }()
    
    let textField: UITextField = {
       let tf = UITextField()
        tf.backgroundColor = DynamicColor(hexString: "FAFAFA")
        tf.placeholder = "  Username"
        tf.layer.cornerRadius = 5.0
        tf.clipsToBounds = true
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.layer.borderWidth = 0.5
        tf.textAlignment = .left
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [titileLabel, underTitleLabel, textField, nextButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 18.0
        view.addSubview(stackView)
        view.addContraintsWithFormat(format: "H:|[v0]|", views: stackView)
        view.addContraintsWithFormat(format: "V:|-30-[v0]", views: stackView)

        stackView.backgroundColor = .purple
        stackView.addContraintsWithFormat(format: "H:|-35-[v0]-35-|", views: textField)
        stackView.addContraintsWithFormat(format: "H:|-35-[v0]-35-|", views: nextButton)
        stackView.addContraintsWithFormat(format: "H:|-35-[v0]-35-|", views: underTitleLabel)
        stackView.addContraintsWithFormat(format: "V:|-18-[v0]-18-[v1]-20-[v2(44)]-18-[v3(44)]", views: titileLabel, underTitleLabel, textField, nextButton)
        nextButton.addTarget(self, action: #selector(nextButtonWTapped), for: .touchUpInside)
    }
    
    @objc func nextButtonWTapped() {
        
        //1. check that a FIRUser is logged in and that the user has provided a username in the text field.
        guard let firUser = Auth.auth().currentUser,
            let username = textField.text,
            !username.isEmpty else { return }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else {
                // Handle error
                return
            }
            print("Created new user: \(user.username)")
            User.setCurrent(user, writeToUserDefalt: true)
            self.didLogin()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
}










