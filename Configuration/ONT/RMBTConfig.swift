/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import CoreLocation

let RMBT_MAP_VIEW_TYPE_DEFAULT = RMBTMapOptionsMapViewType.standard
let RMBT_MAPBOX_LIGHT_STYLE_URL = "mapbox://styles/account/id"
let RMBT_MAPBOX_DARK_STYLE_URL = "mapbox://styles/account/id"
let RMBT_MAPBOX_BASIC_STYLE_URL = "mapbox://styles/account/id"
let RMBT_MAPBOX_STREET_STYLE_URL = "mapbox://styles/account/id"
let RMBT_MAPBOX_SATELLITE_STYLE_URL = "mapbox://styles/account/id"

let RMBT_IS_USE_DARK_MODE = false
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
let RMBT_TEST_LOOPMODE_WAIT_DISTANCE_RETRIES_S = 10.0

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
let RMBT_VERSION_NEW = false

let RMBT_IS_NEED_BACKGROUND = true

let RMBT_IS_SHOW_TOS_ON_START = false

//

let RMBT_ABOUT_URL       = "https://example.org"
let RMBT_PROJECT_URL     = RMBT_ABOUT_URL
let RMBT_PROJECT_EMAIL   = "feedback@example.org"

let RMBT_REPO_URL        = "https://github.com/specure"
let RMBT_DEVELOPER_URL   = "https://specure.com"

// MARK: Map options

/// Initial map center coordinates and zoom level
let RMBT_MAP_INITIAL_LAT: CLLocationDegrees = 48.209209 // Stephansdom, Wien
let RMBT_MAP_INITIAL_LNG: CLLocationDegrees = 16.371850

let RMBT_MAP_INITIAL_ZOOM: Float = 12.0

/// Zoom level to use when showing a test result location
let RMBT_MAP_POINT_ZOOM: Float = 12.0

/// In "auto" mode, when zoomed in past this level, map switches to points
let RMBT_MAP_AUTO_TRESHOLD_ZOOM: Float = 12.0

let RMBT_MAP_SKIP_RESPONSE_OPERATORS = true

let RMBT_MAP_SHOW_INFO_POPUP = false
// Google Maps API Key

///#warning Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
let RMBT_GMAPS_API_KEY = ""

// MARK: Misc

/// Current TOS version. Bump to force displaying TOS to users again.
let RMBT_TOS_VERSION = 1

///////////////////

let RMBT_SHOW_PRIVACY_POLICY = true
let TEST_STORE_ZERO_MEASUREMENT = true
let IS_SHOW_ADVERTISING = true
let TEST_IPV6_ONLY = false
let INFO_SHOW_OPEN_DATA_SOURCES = true

let TEST_USE_PERSONAL_DATA_FUZZING = false

// If set to false: Statistics is not visible, tap on map points doesn't show bubble, ...
let USE_OPENDATA = false

let SHOW_CITY_AT_POSITION_VIEW = true

let RMBT_MAIN_COMPANY_FOR_DATA_SOURCES = ""
let RMBT_COMPANY_FOR_DATA_SOURCES = ""
let RMBT_SITE_FOR_DATA_SOURCES = ""
let RMBT_COUNTRY_FOR_DATA_SOURCES = ""
let RMBT_URL_SITE_FOR_DATA_SOURCES = ""
let RMBT_TITLE_URL_SITE_FOR_DATA_SOURCES = ""

let RMBT_IS_USE_BASIC_STREETS_SATELLITE_MAP_TYPE = true

let RMBT_USE_OLD_SERVERS_RESPONSE = false

let RMBT_SHOW_PRIVACY_IN_SETTINGS = true

let RMBT_WIZARD_PRIVACY_EMAIL = "info@example.com"
let RMBT_WIZARD_AGE_LIMITATION = "+16"
let RMBT_IS_NEED_WIZARD = true
let RMBT_SETTINGS_MODE = RMBTConfig.SettingsMode.remotely

let DEV_CODE = "44786124"
