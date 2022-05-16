//
//  RMBTCmsApiClient.swift
//  RMBT
//
//  Created by Polina on 11.06.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

class RMBTCmsApiClient {
    static let shared = RMBTCmsApiClient()
    
    let config = RMBTConfiguration
    
    func getProject(completion: @escaping (RMBTCmsProject?) -> Void) {
        guard let urlComponents = NSURLComponents(string: "\(config.RMBT_CMS_BASE_URL)/\(config.RMBT_CMS_PROJECTS_URL)") else {
            return completion(nil)
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "_limit", value: "1"),
            URLQueryItem(name: "slug", value: config.clientIdentifier)
        ]
        guard let url = urlComponents.url else {
            return completion(nil)
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let projects = try JSONDecoder().decode([RMBTCmsProject].self, from: data)
                    if projects.count > 0 {
                        completion(projects.first)
                    } else {
                        completion(nil)
                    }
                } catch let parsingError {
                    print("Parsing error: \(parsingError)")
                    completion(nil)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    func getPage(route: String, completion: @escaping (RMBTCmsPageProtocol) -> Void ) {
        let encodedRoute = route.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "\(config.RMBT_CMS_BASE_URL)/\(config.RMBT_CMS_PAGES_URL)\(encodedRoute!)")
        var request = URLRequest(url: url!)
        request.setCMSHeaders()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let page = try JSONDecoder().decode(RMBTCmsPage.self, from: data)
                    if let translation = page.translations.first(where: { t in
                        return t.language == Locale.current.languageCode
                    }) {
                        completion(translation)
                    } else {
                        completion(page)
                    }
                } catch let parsingError {
                    print("Parsing error: \(parsingError)")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }
        task.resume()
    }
}

extension URLRequest {
    mutating func setCMSHeaders() {
        let config = RMBTConfiguration
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue(config.clientIdentifier, forHTTPHeaderField: "X-Nettest-Client")
    }
}
