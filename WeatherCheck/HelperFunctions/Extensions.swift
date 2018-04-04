//
//  Extensions.swift
//  WeatherCheck
//
//  Created by logan on 2018/4/4.
//  Copyright © 2018 Chuanqi. All rights reserved.
//

import UIKit

extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading{
            self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let trailing = trailing{
            self.trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if size.width != 0{
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0{
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
