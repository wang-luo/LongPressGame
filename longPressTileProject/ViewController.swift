//
//  ViewController.swift
//  longPressTileProject
//
//  Created by wang on 2018/05/21.
//  Copyright © 2018年 json. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //create game start button
    var gameStartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create game start button
        gameStartButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width/2-50, y: 250, width: 100, height: 50))
        gameStartButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        gameStartButton.setTitle("Game Start", for: .normal)
        gameStartButton.addTarget(nil, action: #selector(ViewController.startGame), for: .touchDown)
        self.view.addSubview(gameStartButton)
        
    }

    //screen transition to GameViewController
    @objc func startGame(sender: UIButton) {
        let gameVC = GameViewController()
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

