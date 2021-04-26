//
//  TeamHomeTurfAuth0Service.swift
//  TestTeamApp
//
//

import Auth0
import Foundation
import HomeTurf

final class TeamHomeTurfAuth0Service: HomeTurfBaseAuth0Service {
    var javascriptService: HomeTurfJavascriptService? = nil
    var audience: String? = nil
    var clientId: String? = nil
    var domain: String? = nil
    var isAuthenticating = false
    
    init() {
        
    }
    
    func setJavascriptService(javascriptService: HomeTurfJavascriptService) {
       self.javascriptService = javascriptService
    }
    
    func setCredentials(audience: String, clientId: String, domain: String) {
        self.audience = audience
        self.clientId = clientId
        self.domain = domain
    }
    
    func login() {
        if (isAuthenticating) {
            javascriptService!.runJavascriptInWebView(action: "LOGIN_AUTH0_ALREADY_IN_PROGRESS")
        } else {
            isAuthenticating = true;
            loginWithNativeAuth0();
        }
    }

    private func loginWithNativeAuth0() {
        Auth0
            .webAuth(clientId: clientId!, domain: domain!)
            .audience(audience!)
            .start { result in
                switch result {
                case .success(let credentials):
                    let accessToken = credentials.accessToken ?? "";
                    if (accessToken != "") {
                        self.authenticateWithNativeAuth0(accessToken: accessToken)
                    } else {
                        self.handleNativeAuth0Error(message: "No access token returned")
                    }
                case .failure(let error):
                    print("Failed with \(error)")
                    self.handleNativeAuth0Error(message: error.localizedDescription)
                }
            }
    }
    
    func authenticateWithNativeAuth0(accessToken: String) {
        Auth0
            .authentication(clientId: clientId!, domain: domain!)
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch result {
                case .success(let profile):
                    self.handleNativeAuth0Success(data: "{accessToken: '\(accessToken)', sub: '\(profile.sub)'}")
                case .failure(let error):
                    print("Failed with \(error)")
                    self.handleNativeAuth0Error(message: error.localizedDescription)
                }
        }
    }
    
    func handleNativeAuth0Success(data: String) {
        isAuthenticating = false
        self.javascriptService!.runJavascriptInWebView(action: "LOGIN_AUTH0_SUCCESS", data: data, sendDataAsString: false)
    }
    
    func handleNativeAuth0Error(message: String) {
        isAuthenticating = false
        self.javascriptService!.runJavascriptInWebView(action: "LOGIN_AUTH0_ERROR", data: message, sendDataAsString: true)
    }
    
    func logout() {
        Auth0
            .webAuth(clientId: clientId!, domain: domain!)
            .clearSession(federated: true) { result in
                if result {
                    self.javascriptService!.runJavascriptInWebView(action: "LOGOUT_AUTH0_SUCCESS")
                } else {
                    self.javascriptService!.runJavascriptInWebView(action: "LOGOUT_AUTH0_ERROR", data: "Unknown error logging out", sendDataAsString: true)
                }
                // Handle failure?
            }
    }
}
