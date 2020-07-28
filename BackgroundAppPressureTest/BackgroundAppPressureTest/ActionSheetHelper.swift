//
//  ActionSheetHelper.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-28.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation
import UIKit

public func showActionSimpleConfirmSheet(controler: UIViewController, result: @escaping (Bool) -> Void) {
    let alert = UIAlertController(title: "Test Result", message: "Positive or negtive?", preferredStyle: .actionSheet)
    let action = UIAlertAction(title: "Positive", style: .default) {
        UIAlertAction in
        result(true)
    }
    alert.addAction(action)

    let cancelAction = UIAlertAction(title: "Negtive", style: .destructive) {
        UIAlertAction in
        result(false)
    }
    alert.addAction(cancelAction)
    controler.present(alert, animated: true, completion: nil)
}
