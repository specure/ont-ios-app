//
//  RMBTMapHttpService.swift
//  RMBT
//
//  Created by Polina on 20.09.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

class RMBTMapHttpService {
    var debounceTimer:Timer?
    
    func getLocationsFromQuery(query: String = "", completion: @escaping ([RMBTGeocodingFeature]) -> Void) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {_ in
            let config = RMBTConfiguration
            guard let urlComponents = NSURLComponents(string: "https://geocode.search.hereapi.com/v1/geocode") else {
                return
            }
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "at", value: "\(config.RMBT_MAP_INITIAL_LNG),\(config.RMBT_MAP_INITIAL_LAT)"),
                URLQueryItem(name: "in", value: "countryCode:\(config.RMBT_MAP_COUNTRY_CODE)"),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "apiKey", value: config.RMBT_MAP_GEOCODING_API_KEY)
            ]
            guard let url = urlComponents.url else {
                return
            }
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(RMBTGeocodingResponse.self, from: data)
                        completion(response.items)
                        
                    } catch let parsingError {
                        print("Parsing error: \(parsingError)")
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                }
            }
            task.resume()
        })
    }
    
    func getOperators(completion: @escaping ([RMBTMapOperator]) -> Void) {
        let config = RMBTConfiguration
        let url = URL(string: "\(config.RMBT_URL_HOST)/nationalTable")
        var request = URLRequest(url: url!)
        request.setCMSHeaders()
        var list = RMBTMapOperator.list
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let nationalTable = try JSONDecoder().decode(RMBTNationalTable.self, from: data)
                    nationalTable.statsByProvider.forEach({ stats in
                        list.append(
                            RMBTMapOperator(name: stats.providerName.uppercased(), shortLabel: stats.providerName, longLabel: nil )
                        )
                    })
                } catch let parsingError {
                    print("Parsing error: \(parsingError)")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
            completion(list)
        }
        task.resume()
    }
}

struct RMBTMapView: Codable {
    let east: Double
    let west: Double
    let north: Double
    let south: Double
}

struct RMBTLatLng: Codable {
    let lat: Double
    let lng: Double
}

struct RMBTGeocodingFeature: Codable {
    let title: String
    let id: String
    let mapView: RMBTMapView?
    let position: RMBTLatLng
    let resultType: String
}

struct RMBTGeocodingResponse: Codable {
    let items: [RMBTGeocodingFeature]
}

struct RMBTNationalTable: Codable {
    var statsByProvider: [RMBTProviderStats]
}

struct RMBTProviderStats: Codable {
    var providerName: String
}
