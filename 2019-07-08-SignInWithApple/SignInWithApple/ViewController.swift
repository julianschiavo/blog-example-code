//
//  ViewController.swift
//  SignInWithApple
//
//  Created by Julian Schiavo on 26/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import AuthenticationServices
import UIKit

class ViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    let identifierLabel = UILabel()
    let statusLabel = UILabel()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    
    var signInWithAppleButton = ASAuthorizationAppleIDButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        setupLabels()
    }
    
    // MARK: - UI Setup
    
    private func setupLabels() {
        identifierLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        identifierLabel.textAlignment = .center
        identifierLabel.numberOfLines = 0
        
        statusLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        
        nameLabel.text = "Tap Sign in with Apple to begin."
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        
        emailLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        emailLabel.textAlignment = .center
        emailLabel.numberOfLines = 0
        
        let labelStackView = UIStackView(arrangedSubviews: [identifierLabel, statusLabel, nameLabel, emailLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 10
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelStackView)
        
        labelStackView.bottomAnchor.constraint(equalTo: signInWithAppleButton.topAnchor, constant: -20).isActive = true
        labelStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        labelStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    /// Set up the ASAuthorizationAppleIDButton button which should be used to let the user know they will Sign in with Apple
    private func setupButton() {
        signInWithAppleButton = ASAuthorizationAppleIDButton(type: .signIn, style: traitCollection.userInterfaceStyle == .dark ? .whiteOutline : .black)
        signInWithAppleButton.cornerRadius = 10
        signInWithAppleButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInWithAppleButton)
        
        signInWithAppleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        signInWithAppleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        signInWithAppleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    // MARK: - Sign in with Apple Flow
    
    /// Create an instance of the provider and a sign in request, then use an ASAuthorizationController to perform the request, which shows the Sign in with Apple dialog
    @objc private func signInButtonTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    /// Handle failed sign ins
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }

    /// Handle successful sign ins
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        identifierLabel.text = "Identifier: " + credentials.user
        
        let statusText: String
        switch credentials.realUserStatus {
        case .likelyReal:
            statusText = "You are trusted by Apple"
        case .unsupported:
            statusText = "You're not trusted by Apple"
        case .unknown:
            statusText = "Apple does not know whether to trust you"
        @unknown default:
            statusText = "Unknown trust status"
        }
        statusLabel.text = statusText
        
        // On secondary sign ins, credentials are no longer provided, instead, only the user ID is available
        nameLabel.text = credentials.fullName?.description ?? nameLabel.text
        emailLabel.text = credentials.email ?? emailLabel.text
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }

}

