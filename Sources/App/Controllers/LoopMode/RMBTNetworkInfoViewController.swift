//
//  RMBTNetworkInfoViewController.swift
//  RMBT
//
//  Created by Polina on 07.10.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit
import RMBTClient

class RMBTNetworkInfoViewController: RMBTBottomSheetViewController {

    @IBOutlet weak var tableView: UITableView!
    var networkTypeImage: UIImage?
    var networkInfo: RMBTNetworkInfo?
    var ipInfo: ConnectivityInfo?
    
    private enum RMBTNetworkInfoRow: Int {
        case networkTypeAndName
        case IPv4
        case IPv6
        case location
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset.left = 0
        tableView.register(UINib(nibName: "RMBTNetworkInfoDetailsCell", bundle: nil), forCellReuseIdentifier: RMBTNetworkInfoDetailsCell.id)
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = .white
    }

    private func setNetworkTypeAndNameData(for cell: RMBTNetworkInfoDetailsCell) {
        cell.addEntry(networkInfo?.networkType, titled: L("history.filter.networktype"), image: networkTypeImage)
        cell.addEntry(networkInfo?.networkName, titled: L("loopmode.init.network-name"), image: nil)
    }
    
    private func setLocationData(for cell: RMBTNetworkInfoDetailsCell) {
        cell.addEntry(networkInfo?.location ?? networkInfo?.networkLocation, titled: L("intro.popup.location.position"), image: nil)
    }
    
    private func setIPv4Data(for cell: RMBTNetworkInfoDetailsCell) {
        cell.addEntry(ipInfo?.ipv4.internalIp ?? L("intro.popup.ip.no-ip-text"), titled: L("intro.popup.ip.private-address"), image: nil)
        cell.addEntry(ipInfo?.ipv4.externalIp ?? L("intro.popup.ip.no-ip-text"), titled: L("intro.popup.ip.public-address"), image: nil)
        cell.toggleIPVButton(isHidden: false, titled: "IPv4", color: nil, titleColor: nil)
    }
    
    private func setIPv6Data(for cell: RMBTNetworkInfoDetailsCell) {
        cell.addEntry(ipInfo?.ipv6.internalIp ?? ipInfo?.ipv6.externalIp ?? L("intro.popup.ip.no-ip-text"), titled: nil, image: nil)
        cell.toggleIPVButton(isHidden: false, titled: "IPv6", color: UIColor(rgb: 0x6dd400), titleColor: .white)
    }
}

extension RMBTNetworkInfoViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = RMBTNetworkInfoRow(rawValue: indexPath.row)
        switch(rowType) {
        case .IPv4:
            return 110
        default:
            return 82
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMBTNetworkInfoDetailsCell.id) as! RMBTNetworkInfoDetailsCell
        let rowType = RMBTNetworkInfoRow(rawValue: indexPath.row)
        switch(rowType) {
        case .networkTypeAndName:
            setNetworkTypeAndNameData(for: cell)
        case .IPv4:
            setIPv4Data(for: cell)
        case .IPv6:
            setIPv6Data(for: cell)
        case .location:
            setLocationData(for: cell)
        default:
            break
        }
        return cell
    }
    
}
