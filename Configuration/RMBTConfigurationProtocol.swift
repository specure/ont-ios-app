//
//  RMBTConfigurationProtocol.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/26/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

class RMBTConfigurationProtocol {
    var settingsDict: NSDictionary? {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            return NSDictionary(contentsOfFile: path)
        }
        return nil
    }
    
    let RMBT_MAP_VIEW_TYPE_DEFAULT = RMBTMapOptionsMapViewType.standard
    let RMBT_MAPBOX_LIGHT_STYLE_URL = "mapbox://styles/account/id"
    let RMBT_MAPBOX_DARK_STYLE_URL = "mapbox://styles/account/id"
    var RMBT_MAPBOX_BASIC_STYLE_URL: String {
        return "mapbox://styles/account/id"
    }
    let RMBT_MAPBOX_STREET_STYLE_URL = "mapbox://styles/account/id"
    let RMBT_MAPBOX_SATELLITE_STYLE_URL = "mapbox://styles/account/id"
    
    let RMBT_IS_USE_DARK_MODE = true
    // MARK: Fixed test parameters
    
    ///
    let RMBT_TEST_CIPHER = SSL_RSA_WITH_RC4_128_MD5
    
    ///
    let RMBT_TEST_SOCKET_TIMEOUT_S = 30.0
    
    let RMBT_TEST_LOOPMODE_ENABLE = true
    /// Maximum number of tests to perform in loop mode
    let RMBT_TEST_LOOPMODE_LIMIT = 100
    
    ///
    let RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S = 5
    
    ///
    let RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST = 4
    
    ///
    let RMBT_TEST_PRETEST_DURATION_S = 2.0
    
    ///
    let RMBT_TEST_PING_COUNT = 10
    
    /// In case of slow upload, we finalize the test even if this many seconds still haven't been received:
    let RMBT_TEST_UPLOAD_MAX_DISCARD_S = 1.0
    
    /// Minimum number of seconds to wait after sending last chunk, before starting to discard.
    let RMBT_TEST_UPLOAD_MIN_WAIT_S    = 0.25
    
    /// Maximum number of seconds to wait for server reports after last chunk has been sent.
    /// After this interval we will close the socket and finish the test on first report received.
    let RMBT_TEST_UPLOAD_MAX_WAIT_S    = 3
    
    /// Measure and submit speed during test in these intervals
    let RMBT_TEST_SAMPLING_RESOLUTION_MS = 250
    
    ///
    var RMBT_CONTROL_SERVER_PATH: String { return "/" }
    var RMBT_CONTROL_MEASUREMENT_SERVER_PATH: String { return "/" }
    
    ///
    var RMBT_MAP_SERVER_PATH: String { return "/" }
    
    // MARK: Default control server URLs
    
    var RMBT_CONTROL_MEASUREMENT_SERVER_URL: String {
        return "\(RMBT_URL_HOST)\(RMBT_CONTROL_MEASUREMENT_SERVER_PATH)"
    }
    var RMBT_CONTROL_SERVER_URL: String {
        return "\(RMBT_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    var RMBT_CONTROL_SERVER_IPV4_URL: String {
        return "\(RMBT_IPV4_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    var RMBT_CONTROL_SERVER_IPV6_URL: String {
        return "\(RMBT_IPV6_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    var RMBT_CHECK_IPV4_URL: String {
        return "\(RMBT_IPV4_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    
    // MARK: - Other URLs used in the app
    
    var RMBT_URL_HOST: String {
        return (settingsDict?["CONTROL_SERVER_URL"] as? String) ?? ""
    }
    var RMBT_IPV4_URL_HOST: String {
        return (settingsDict?["CHECK_IPV4_URL"] as? String) ?? ""
    }
    var RMBT_IPV6_URL_HOST: String {
        return (settingsDict?["CHECK_IPV6_URL"] as? String) ?? ""
    }
    
    #if DEBUG || TEST
    var RMBT_MAP_SERVER_URL: String { return "https://example.com\(RMBT_MAP_SERVER_PATH)" }
    #else
    var RMBT_MAP_SERVER_URL: String { return "https://example.com\(RMBT_MAP_SERVER_PATH)" }
    #endif
    
    ///
    var RMBT_VERSION_NEW: Bool { return false }
    
    let RMBT_IS_NEED_BACKGROUND = true
    
    /// Note: $lang will be replaced by the device language (de, en, sl, etc.)
    var RMBT_STATS_URL: String {
        return "\(RMBT_URL_HOST)/$lang/"
    }
    var RMBT_HELP_URL: String {
        return "\(RMBT_URL_HOST)/$lang/"
    }
    var RMBT_HELP_RESULT_URL: String {
        return "\(RMBT_URL_HOST)/$lang/"
    }
    
    var RMBT_PRIVACY_TOS_URL: String {
        return "\(RMBT_URL_HOST)/$lang/"
    }
    
    var RMBT_ABOUT_WEB_URL: String {
        return "\(RMBT_URL_HOST)/$lang/"
    }
    
    var RMBT_TERMS_TOS_URL: String {
        return "\(RMBT_URL_HOST)/$lang/"
    }
    let RMBT_IS_SHOW_TOS_ON_START = false
    
    //
    
    let RMBT_ABOUT_URL       = "https://example.com"
    var RMBT_PROJECT_URL: String {
        return RMBT_ABOUT_URL
    }
    let RMBT_PROJECT_EMAIL   = "feedback@example.com"
    
    let RMBT_REPO_URL        = "https://github.com/specure"
    let RMBT_DEVELOPER_URL   = "https://specure.com"
    
    /// Initial map center coordinates and zoom level
    var isMapAvailable: Bool { return true }
    
    var RMBT_MAP_INITIAL_LAT: CLLocationDegrees { return 48.209209 }  // Stephansdom, Wien
    var RMBT_MAP_INITIAL_LNG: CLLocationDegrees { return 16.371850 }
    
    var RMBT_MAP_INITIAL_ZOOM: Float { return 12.0 }
    
    /// Zoom level to use when showing a test result location
    let RMBT_MAP_POINT_ZOOM: Float = 12.0
    
    /// In "auto" mode, when zoomed in past this level, map switches to points
    let RMBT_MAP_AUTO_TRESHOLD_ZOOM: Float = 12.0
    
    let RMBT_MAP_SKIP_RESPONSE_OPERATORS = true
    let RMBT_MAP_SHOW_INFO_POPUP = true
    // Google Maps API Key
    
    ///#warning Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
    let RMBT_GMAPS_API_KEY = ""
    
    // MARK: Misc
    
    /// Current TOS version. Bump to force displaying TOS to users again.
    let RMBT_TOS_VERSION = 1
    
    ///////////////////
    
    let RMBT_SHOW_PRIVACY_POLICY = true
    let TEST_STORE_ZERO_MEASUREMENT = true
    var IS_SHOW_ADVERTISING: Bool { return true }
    let TEST_IPV6_ONLY = false
    let INFO_SHOW_OPEN_DATA_SOURCES = true
    
    let TEST_USE_PERSONAL_DATA_FUZZING = false
    
    // If set to false: Statistics is not visible, tap on map points doesn't show bubble, ...
    let USE_OPENDATA = false
    
    let SHOW_CITY_AT_POSITION_VIEW = true
    
    let RMBT_MAIN_COMPANY_FOR_DATA_SOURCES = "Specure GmbH"
    let RMBT_COMPANY_FOR_DATA_SOURCES = ""
    let RMBT_SITE_FOR_DATA_SOURCES = ""
    let RMBT_COUNTRY_FOR_DATA_SOURCES = ""
    let RMBT_URL_SITE_FOR_DATA_SOURCES = ""
    let RMBT_TITLE_URL_SITE_FOR_DATA_SOURCES = ""
    
    var appName: String {
        return "Open NetTest"
    }
    
    let RMBT_IS_USE_BASIC_STREETS_SATELLITE_MAP_TYPE = true
    
    let RMBT_USE_OLD_SERVERS_RESPONSE = false
    
    var RMBT_VERSION: Int { return 3 }
    
    let RMBT_SHOW_PRIVACY_IN_SETTINGS = true
    
    let RMBT_WIZARD_PRIVACY_EMAIL = "info@example.com"
    let RMBT_WIZARD_AGE_LIMITATION = "+16"
    let RMBT_IS_NEED_WIZARD = true
    
    var RMBT_SETTINGS_MODE: RMBTConfig.SettingsMode {
        return .remotely
    }
    
    let DEV_CODE = "44786124"
    
    var RMBT_DEFAULT_IS_CURRENT_COUNTRY: Bool {
        return true
    }
    
    var RMBT_USE_MAIN_LANGUAGE: Bool { return false }
    var RMBT_MAIN_LANGUAGE: String { return "en" }
    
    var clientIdentifier: String { return "" }
    
    var RMBT_CMS_BASE_URL: String { return "https://example.com" }
    var RMBT_CMS_PAGES_URL: String { return "/" }
    var RMBT_CMS_ABOUT_URL: String { return "/" }
    var RMBT_CMS_PRIVACY_URL: String { return "/" }
    var RMBT_CMS_TERMS_URL: String { return "/" }
    var RMBT_CMS_PROJECTS_URL: String { return "/" }
    
    struct ServerConfig {
        let identifier: String
        let clientIdentifier: String
        let controlServer: String
        let measurementControlServer: String
        let ipv4: String
        let ipv6: String
        let mapServer: String
    }
    
    var serverConfigurations: [ServerConfig] { return [] }
    
    func mapRegionalPrefix(by zoom: Double) -> RMBTMapRegionalPrefix {
        switch true {
        case zoom <= 5:
            return RMBTMapRegionalPrefix.county
        case zoom <= 7.5:
            return RMBTMapRegionalPrefix.municipality
        case zoom <= 10:
            return RMBTMapRegionalPrefix.squares10meters
        case zoom <= 12:
            return RMBTMapRegionalPrefix.squares1meters
        case zoom <= 14:
            return RMBTMapRegionalPrefix.squares01meters
        default:
            return RMBTMapRegionalPrefix.squares001meters
        }
    }
    
    var RMBT_MAP_COUNTRY_CODE: String {
        return ""
    }
    
    var RMBT_MAP_GEOCODING_API_KEY: String {
        return ""
    }
    
    var RMBT_MAP_ACCESS_TOKEN: String {
        return ""
    }
    
    var RMBT_USE_CUSTOM_FONT: Bool {
        return false
    }
    
    var RMBT_CUSTOM_FONT_NAME: String? {
        return nil
    }
}
