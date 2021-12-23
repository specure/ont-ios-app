//
//  RMBTHomeViewController.swift
//  RMBT
//
//  Created by Polina on 06.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation
import CoreTelephony
import RMBTClient

class RMBTHomeViewController: TopLevelViewController {
    
    static let startLoopModeSegue = "startLoopModeSegue"
    static let startTestSegue = "startTestSegue"
    
    @IBOutlet weak var loopModeSwitchButton: UIButton!
    @IBOutlet weak var startTestButton: UIButton?
    @IBOutlet weak var serverTitleLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    @IBOutlet weak var networkInfoView: UIView!
    @IBOutlet weak var networkTypeTitle: UILabel!
    @IBOutlet weak var networkTypeImageView: UIImageView?
    @IBOutlet weak var networkTypeLabel: UILabel?
    @IBOutlet weak var networkNameTitle: UILabel!
    @IBOutlet weak var networkNameLabel: UILabel?
    @IBOutlet weak var logoBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var heroHeight: NSLayoutConstraint!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var loopModeIndicator: UIButton!
    @IBOutlet weak var heroBottom: NSLayoutConstraint!
    @IBOutlet weak var heroImage: UIImageView!
    
    internal var connectivityTracker: RMBTConnectivityTracker?
    private var location: String?
    private var networkLocation: String?
    private var networkTypeImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.networkTypeImageView?.image = self.networkTypeImage
            }
        }
    }
    private let locationManager = CLLocationManager() // Needed only for authorization request permission
    private var servers: [MeasurementServerInfoResponse.Servers] = []
    private var currentServer: MeasurementServerInfoResponse.Servers?
    private var ipInfo: ConnectivityInfo?
    private let connectivityService = ConnectivityService()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem.title = L("tabbar.title.test")
        tabBarItem.image = UIImage(named: "navbar_test_dark")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        applyColorScheme()
        setTexts()
        setActionHandlers()
        
        if RMBTTOS.sharedTOS.isCurrentVersionAccepted() || RMBTConfiguration.RMBT_IS_SHOW_TOS_ON_START == false {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        reloadServers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if view.frameHeight < 600 {
            logoBottomMargin.constant = 70
            heroHeight.constant = 100
        }
        setHeroSizeAndMargin(size: UIScreen.main.bounds.size)
        
        if RMBT_TEST_LOOPMODE_ENABLE == false {
            loopModeSwitchButton.isHidden = true
            RMBTSettings.sharedSettings.debugLoopMode = false
        }
        
        updateLoopModeSwitcher()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setHeroSizeAndMargin(size: size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startConnectivityTracker()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopConnectivityTracker()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == RMBTHomeViewController.startTestSegue,
            let vc = segue.destination as? RMBTTestViewController {
            vc.isQosEnabled = self.isQOSEnabled()
            vc.networkInfo = RMBTNetworkInfo(
                location: self.location,
                networkType: self.networkTypeLabel?.text,
                networkName: self.networkNameLabel?.text,
                networkLocation: self.networkLocation
            )
        }
        if segue.identifier == RMBTHomeViewController.startLoopModeSegue,
            let vc = segue.destination as? RMBTLoopModeViewController {
            vc.networkInfo = RMBTNetworkInfo(
                location: self.location,
                networkType: self.networkTypeLabel?.text,
                networkName: self.networkNameLabel?.text,
                networkLocation: self.networkLocation
            )
        }
    }
    
    override func applyColorScheme() {
        view.backgroundColor = RMBTColorManager.background
        if let startTestButton = startTestButton as? RMBTStartTestButton {
            startTestButton.colors = [
                RMBTColorManager.tintPrimaryColor,
                RMBTColorManager.tintSecondaryColor
            ]
        }
        serverNameLabel.textColor = RMBTColorManager.tintLightColor
        networkInfoView.layer.shadowColor = UIColor.black.cgColor
        networkInfoView.layer.shadowRadius = 8
        networkInfoView.layer.shadowOpacity = 0.25
        networkInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        networkInfoView.layer.cornerRadius = 16
        detailsButton.tintColor = RMBTColorManager.tintLightColor
    }
    
    private func setHeroSizeAndMargin(size: CGSize) {
        guard UIDevice.isDeviceTablet() else {return}
        if size.width > size.height {
            heroHeight.constant = UIScreen.main.bounds.width / 3
            heroBottom.constant = -(heroHeight.constant - UIScreen.main.bounds.height / 3) + 25 * (size.width / size.height)
        } else {
            heroHeight.constant = UIScreen.main.bounds.height / 3
            heroBottom.constant = -(heroHeight.constant - UIScreen.main.bounds.width / 3) + 25 * (size.height / size.width)
        }
    }
    
    func setTexts() {
        loopModeSwitchButton.setTitle(L("loopmode.init.btn.loop-switch"), for: .normal)
        startTestButton?.setTitle(L("loopmode.init.btn.test"), for: .normal)
        serverTitleLabel.text = L("loopmode.init.server")
        networkNameTitle.text = LC("loopmode.init.network-name")
        networkTypeTitle.text = LC("history.filter.networktype")
    }
    
    func setActionHandlers() {
        loopModeSwitchButton.addTarget(self, action: #selector(switchLoopMode), for: .touchUpInside)
        startTestButton?.addTarget(self, action: #selector(startTest), for: .touchUpInside)
        detailsButton.addTarget(self, action: #selector(showNetworkInfoDetails), for: .touchUpInside)
        let tapReconginzer = UITapGestureRecognizer(target: self, action: #selector(showNetworkInfoDetails))
        networkInfoView.addGestureRecognizer(tapReconginzer)
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidChange), name: NSNotification.Name(rawValue: "RMBTLocationTrackerNotification"), object: nil)
    }

    func reloadServers() {
        getMeasurementServerInfo(success: { [weak self] response in
            self?.servers = response.servers ?? []
            self?.setDefaultServer()
        }, error: { [weak self] _ in
            self?.setDefaultServer()
        })
    }
    
    func setDefaultServer() {
        let ms = self.servers.filter({ item in
            if let server = RMBTConfig.sharedInstance.measurementServer {
                return item.id?.intValue == server.id?.intValue
            } else if let serverId = RMBTApplicationController.measurementServerId {
                return item.id?.intValue == serverId
            } else {
                return false
            }
        })
        
        if ms.count > 0, let server = ms.first {
            self.assignNewServer(server)
        } else if let server = self.servers.first {
            self.assignNewServer(server)
        }
    }
    
    private func assignNewServer(_ theServer: MeasurementServerInfoResponse.Servers) {
        RMBTConfig.sharedInstance.measurementServer = theServer
        self.currentServer = theServer
        serverNameLabel.text = theServer.fullNameWithDistanceAndSponsor
    }
    
    private func isQOSEnabled() -> Bool {
        if RMBTSettings.sharedSettings.nerdModeQosEnabled == RMBTSettings.NerdModeQosMode.always.rawValue {
            return true
        } else if RMBTSettings.sharedSettings.nerdModeQosEnabled == RMBTSettings.NerdModeQosMode.newNetwork.rawValue {
            if self.networkNameLabel?.text != RMBTSettings.sharedSettings.previousNetworkName {
                return true
            }
        }
        
        return false
    }
}

// MARK: ManageConnectivity
extension RMBTHomeViewController: ManageConnectivity, ConnectivityLabels {
    
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didDetectConnectivity connectivity: RMBTConnectivity) {
        connectivityDidChange(connectivity)
    }
    
    func connectivityNetworkTypeDidChange(connectivity: RMBTConnectivity) {}
    
    func connectivityTracker(_ tracker: RMBTConnectivityTracker, didStopAndDetectIncompatibleConnectivity connectivity: RMBTConnectivity) {
        trackerDidFail()
    }
    
    func connectivityTrackerDidDetectNoConnectivity(_ tracker: RMBTConnectivityTracker) {
        trackerDidFail()
    }
    
    private func connectivityDidChange(_ connectivity: RMBTConnectivity) {
        manageViewAfterDidConnect(connectivity: connectivity)
        
        if connectivity.networkType == .wiFi {
            networkTypeImage = UIImage(named: "wifi")?.tintedImageUsingColor(tintColor: .black)
        } else if connectivity.networkType == .cellular {
            networkTypeImage = UIImage(named: "mobil4")?.tintedImageUsingColor(tintColor: .black)
        }
        
        setIpInfo()
    }
    
    private func trackerDidFail() {
        manageViewInactiveConnect()
        networkTypeImage = UIImage(named: "intro_none")?.tintedImageUsingColor(tintColor: .black)
        setIpInfo()
    }
    
    private func setIpInfo() {
        DispatchQueue.global(qos: .default).async {
            self.connectivityService.checkConnectivity({ [weak self] connection in
                self?.ipInfo = connection
            })
        }
    }
}

// MARK: Action handlers
extension RMBTHomeViewController {
    
    @objc func switchLoopMode() {
        if RMBTSettings.sharedSettings.debugLoopMode == false, let navController = UIStoryboard.loopModeAlert() as? UINavigationController, let vc = navController.viewControllers.first as? RMBTLoopModeAlertViewController {
            vc.onComplete = { [weak self] in
                self?.updateLoopModeSwitcher()
            }
            self.present(navController, animated: true, completion: nil)
        } else {
            RMBTSettings.sharedSettings.debugLoopMode = false
        }
        updateLoopModeSwitcher()
    }

    private func updateLoopModeSwitcher() {
        loopModeSwitchButton.isSelected = RMBTSettings.sharedSettings.debugLoopMode
        loopModeIndicator.isHidden = !RMBTSettings.sharedSettings.debugLoopMode
    }

    @objc func startTest() {
        if servers.count > 0 {
            if RMBT_TEST_LOOPMODE_ENABLE && RMBTSettings.sharedSettings.debugLoopMode {
                performSegue(withIdentifier: RMBTHomeViewController.startLoopModeSegue, sender: self)
            } else {
                performSegue(withIdentifier: RMBTHomeViewController.startTestSegue, sender: self)
            }
        } else {
            _ = UIAlertController.presentAlert(L("history.error.server_not_available")) { (_) in
            }
        }
    }
    
    @objc func showNetworkInfoDetails() {
        guard let vc = UIStoryboard.networkInfoBottomSheet() as? RMBTNetworkInfoViewController else {
            return
        }
        vc.sheetHeight = 399
        vc.networkTypeImage = networkTypeImage
        vc.networkInfo = RMBTNetworkInfo(
            location: location,
            networkType: networkTypeLabel?.text,
            networkName: networkNameLabel?.text,
            networkLocation: networkLocation
        )
        vc.ipInfo = ipInfo
        self.present(vc, animated: false)
    }
    
    @objc func locationDidChange(_ notification: Notification) {
        var location: CLLocation?
        
        for l in notification.userInfo?["locations"] as! [CLLocation] { // !
            if CLLocationCoordinate2DIsValid(l.coordinate) {
                location = l
                
                logger.debug("Location updated to (\(l.rmbtFormattedString()))")
            }
        }
        
        guard let location = location else {
            return
        }
        
        location.fetchCountryAndCity { (_, city) in
            if city == nil || SHOW_CITY_AT_POSITION_VIEW == false {
                self.location = location.rmbtFormattedArray().first
            } else {
                self.location = city
            }
        }
        
        let formattedArray = location.rmbtFormattedArray()
        if formattedArray.count > 1 {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            let string = String(format: "%@ %@ @%@", formattedArray[0], formattedArray[1], dateFormatter.string(from: Date()))
            networkLocation = string
        }
    }
}

// MARK: CLLocationManagerDelegate
extension RMBTHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        reloadServers()
    }
}
