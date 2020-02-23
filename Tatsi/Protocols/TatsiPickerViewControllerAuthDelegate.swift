//
//  TatsiPickerViewControllerAuthDelegate.swift
//  Tatsi
//
//  Created by Stefan Wirth on 2/23/20.
//  Copyright © 2020 awkward. All rights reserved.
//

import Foundation

public protocol TatsiAuthPickerViewControllerDelegate: class {
    func didRequestAuthorization(success: Bool)
}
