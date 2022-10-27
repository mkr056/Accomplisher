//
//  CelebrationViewController.swift
//  Accomplisher
//
//  Created by Artem Mkr on 21.10.2022.
//

import UIKit

class CelebrationViewController: UIViewController {
    
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Congrats homie"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Do any additional setup after loading the view.
    }

    


}
