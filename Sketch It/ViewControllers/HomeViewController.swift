//
//  HomeViewController.swift
//  Sketch It
//
//  Created by kamlesh on 25/08/20.
//  Copyright © 2020 kamlesh. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class HomeViewController: UIViewController {

    private lazy var imgViewLogo : UIImageView = {
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        logo.image = UIImage(named: "logo")
        logo.layer.cornerRadius = logo.frame.height/2
        logo.layer.masksToBounds = true
        return logo
    }()
    
    private lazy var imgViewSketch : UIImageView = {
        let sketch = UIImageView()
        sketch.image = UIImage(named: "draw")
        return sketch
    }()
    
    private lazy var imgViewSavedSketches : UIImageView = {
        let sketch = UIImageView()
        sketch.image = UIImage(named: "saved")
        return sketch
    }()
    
    private lazy var lblTitle : UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "HelveticaNeue-BoldItalic", size: 20)
        title.textAlignment = .center
        title.textColor = .white
        title.text = "WELCOME TO SKETCH IT"
        return title
    }()
    
    private lazy var lblSketch: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        title.textAlignment = .center
        title.textColor = .appThemeColor
        title.text = "Create Sketch"
        return title
    }()
    
    private lazy var lblSavedSketches : UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        title.textAlignment = .center
        title.textColor = .appThemeColor
        title.text = "My Sketches"
        return title
    }()
    
    private lazy var btnSketch : UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(btnSketchTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var btnSavedSketches : UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(btnMySketchesTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackViewContainer : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [btnSketch, btnSavedSketches])
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Home"
        self.navigationItem.hidesBackButton = true
        
        // MARK: Logout Button
        let btnLogout = UIButton()
        btnLogout.setTitle("Logout", for: .normal)
        btnLogout.addTarget(self, action: #selector(btnLogoutTapped), for: .touchUpInside)
        btnLogout.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        btnLogout.setTitleColor(.appThemeColor, for: .normal)
        let logoutItem = UIBarButtonItem(customView: btnLogout)
        self.navigationItem.setRightBarButton(logoutItem, animated: true)
        
        //MARK: Adding Subviews to the Superview
        view.addSubview(lblTitle)
        view.addSubview(imgViewLogo)
        view.addSubview(stackViewContainer)

        //MARK: Adding Subviews to Sketch Button
        btnSketch.addSubview(imgViewSketch)
        btnSketch.addSubview(lblSketch)
        
        //MARK: Adding Subviews to My Sketches Button
        btnSavedSketches.addSubview(imgViewSavedSketches)
        btnSavedSketches.addSubview(lblSavedSketches)
        
        AutoLayoutForAllViews()
        
        view.backgroundColor = .rgb(fromHex: 0x2D4059)
        
    }
    
    private func AutoLayoutForAllViews() {
        
        // For Welcome Text
        lblTitle.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view).inset(30)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view).offset(-180)
        }
        
        // For Image Logo
        imgViewLogo.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.centerX.equalTo(view)
            make.top.equalTo(lblTitle.snp.bottom).offset(30)
        }
        
        // For button StackView
        stackViewContainer.snp.makeConstraints { (make) in
            make.height.equalTo(80)
            make.width.equalTo(250)
            make.centerX.equalTo(view)
            make.top.equalTo(imgViewLogo.snp.bottom).offset(80)
        }
        
        // For button sketch image
        imgViewSketch.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerX.equalTo(btnSketch)
            make.top.equalTo(btnSketch).offset(15)
        }
        
        // For button Sketch label
        lblSketch.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(btnSketch)
            make.centerX.equalTo(btnSketch)
            make.bottom.equalTo(btnSketch).inset(10)
        }
        
        // For button saved sketches image
        imgViewSavedSketches.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerX.equalTo(btnSavedSketches)
            make.top.equalTo(btnSavedSketches).offset(15)
        }
        
        // For button saved sketches label
        lblSavedSketches.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(btnSavedSketches)
            make.centerX.equalTo(btnSavedSketches)
            make.bottom.equalTo(btnSavedSketches).inset(10)
        }
        
    }
    
    //MARK: Sketch Button Action
    @objc func btnSketchTapped() {
        let nextViewController = CreateSketchViewController()
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    //MARK: My Sketches Button Action
    @objc func btnMySketchesTapped() {
        let nextViewController = MySketchesViewController()
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    
    //MARK: Logout Button Action and Logout function
    @objc func btnLogoutTapped() {
        try! Auth.auth().signOut()
            
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("", forKey: "userName")
        UserDefaults.standard.set("", forKey: "mobileNumber")
        UserDefaults.standard.set("", forKey: "userId")
        
        let nextViewController = SignUpViewController()
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
}
