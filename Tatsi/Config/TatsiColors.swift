//
//  TatsiColors.swift
//  Tatsi
//
//  Created by Antoine van der Lee on 25/10/2019.
//  Copyright © 2019 awkward. All rights reserved.
//

import Foundation

/// Defines colors that will be applied to the Tatsi elements.
public protocol TatsiColors {
    /// Used as the background color for all the pages.
    var background: UIColor { get }

    /// This is the primary action color used for tinting buttons like the Cancel and Done buttons.
    var link: UIColor { get }

    /// The main color for text labels.
    var label: UIColor { get }

    /// The color for secondary labels like descriptions.
    var secondaryLabel: UIColor { get }
}

/// Defines the default colors for Tatsi.
public struct TatsiDefaultColors: TatsiColors {
    public var background: UIColor = {
        return .black
    }()

    public var link: UIColor = {
        return UIColor(red: 0.33, green: 0.63, blue: 0.97, alpha: 1.00)
    }()

    public let label: UIColor = {
        return .white
    }()

    public let secondaryLabel: UIColor = {
        return UIColor(white: 142.0 / 255, alpha: 1.0)
    }()
}
