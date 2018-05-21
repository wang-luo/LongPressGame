//
//  GameViewController.swift
//  longPressTileProject
//
//  Created by wang on 2018/05/21.
//  Copyright © 2018年 json. All rights reserved.
//

import Foundation
import UIKit

class GameViewController: ViewController {
    
    /// MARK: Properties
    // this VC's view
    var gameView: GameView!
    
    /// the time to start touching tiles
    var startTime: Date!
    
    /// the finger's location when you touch a tile
    var startLocation: [CGFloat] = [0, 0, 0, 0]
    
    /// information of tile, the position where you touch
    var touchedArray: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        
        //make game view
        gameView = GameView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 568))
        self.view.addSubview(gameView)
        
        gameView.gameViewController = self
        
    }
    
    /// when you touch on screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchEvent = touches.first!
        let location = touchEvent.location(in: gameView.tileBGView)
        
        //save the time you started touching
        startTime = Date()
        
        //if you use 1 or 2 fingers and touched view is game tile
        if touchEvent.view is GameTile && touchedArray.count <= 2{
            
            // save tile
            touchedArray.append(touchEvent.view!)
            startLocation[0] = location.x
            startLocation[1] = location.y
            
            //if you touch long press timer, timer for it will start
            if touchEvent.view is GameTileLong {

                //whether the tile is already added in gameView.longTileTimerAndTileArray
                if gameView.longTileTimerAndTileArray[0].isEmpty {
                    
                    //start long press timer 1
                    gameView.startLongPressTimer(timerNum: 1, tile: touchEvent.view as! GameTile)
                    
                    //where you touch in the tile
                    let locationInLongTile = touchEvent.location(in: touchEvent.view)
                    gameView.longTileTimerAndTileArray[0].append(locationInLongTile.y)
                    //save the y positions where you touch in the tile and where the tile is on screen
                    gameView.longTileTimerAndTileArray[0].append((touchEvent.view?.frame.origin.y)!)
                    
                }else if gameView.longTileTimerAndTileArray.count == 1 {
                    //when you already touched a tile
                    //check whether Timer1 or Timer2 is invalid now
                    //if Timer1 isn't nil
                    if gameView.longPressScoreTimer1 != nil {
                        //start Timer2
                        gameView.startLongPressTimer(timerNum: 2, tile: touchEvent.view as! GameTile)
                        //save the tile information
                        gameView.longTileTimerAndTileArray[1].append(location.y)
                        gameView.longTileTimerAndTileArray[1].append((touchEvent.view?.frame.origin.y)!)
                        
                    }else if gameView.longPressScoreTimer2 != nil {
                        //if Timer2 isn't nil
                        //start Timer1
                        gameView.startLongPressTimer(timerNum: 1, tile: touchEvent.view as! GameTile)
                        //save the tile information
                        gameView.longTileTimerAndTileArray[1].append(location.y)
                        gameView.longTileTimerAndTileArray[1].append((touchEvent.view?.frame.origin.y)!)
                    }
                    
                }
            }
        }
    }
    
    /// during pressing
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        
        //the now position of your finger
        let newLocation = touch.location(in: gameView.tileBGView)
        
        // interval time since the first tap
        let passedTime = NSDate().timeIntervalSince(startTime)
        
        //if it is passed 0.5 sec and moves finger over 20px, cancel stop the Timer which is connected with the tile you touch now
        if passedTime > 0.5 &&
            (newLocation.x - startLocation[0] < -20 || newLocation.x - startLocation[0] > 20) ||
            (newLocation.y - startLocation[1] < -20 || newLocation.y - startLocation[1] > 20) {
            
            if touchedArray.count > 0 {
                if touch.view == touchedArray[0] &&
                    gameView.longPressScoreTimer1 != nil &&
                    gameView.longTileTimerAndTileArray.count == 1 && gameView.longTileTimerAndTileArray[0].isEmpty == false{

                    //stop Timer1
                    gameView.longPressScoreTimer1.invalidate()
                    gameView.longPressScoreTimer1 = nil
                    
                    let targetTimer = gameView.longTileTimerAndTileArray[0][0]
                    if  targetTimer is Timer {
                        (targetTimer as AnyObject).invalidate()
                        gameView.longTileTimerAndTileArray.remove(at: 0)

                        //to use "isEmpty", make the array index empty
                        if gameView.longTileTimerAndTileArray.count == 0 {
                            gameView.longTileTimerAndTileArray = [[]]
                        }
                    }
                }
            }else if touchedArray.count > 1 {
                if touch.view == touchedArray[1] && gameView.longPressScoreTimer2 != nil {
                    
                    //stop Timer2
                    gameView.longPressScoreTimer2.invalidate()
                    gameView.longPressScoreTimer2 = nil
                    
                    if gameView.longTileTimerAndTileArray.count > 1 {
                        let targetTimer = gameView.longTileTimerAndTileArray[1][0] as! Timer
                        targetTimer.invalidate()
                        gameView.longTileTimerAndTileArray.remove(at: 1)
                        
                        //to use "isEmpty", make the array index empty
                        if gameView.longTileTimerAndTileArray.count == 0 {
                            gameView.longTileTimerAndTileArray = [[]]
                        }
                    }
                }
            }
        }
    }
    
    /// when you released your finger from screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first! as UITouch

        // if you touch 1 or 2 tiles
        if touchedArray.count > 0 {
            
            //handle delete function
            for tile in touchedArray {
                
                switch tile {

                case is GameTileLong:
                    //if timerIndex is 2, there is no Timer which is used now in longTileTimerAndTileArray
                    var timerIndex:Int = 2
                    
                    //check where the Timer is connected with the tile now touching
                    if touch.view is GameTileLong {
                        if gameView.longTileTimerAndTileArray[0].count > 1 && gameView.longTileTimerAndTileArray[0][1] as? GameTile == touch.view {
                            timerIndex = 0
                        }
                        
                        if gameView.longTileTimerAndTileArray.count > 1 {
                            if gameView.longTileTimerAndTileArray[1][1] as? GameTile == touch.view {
                                timerIndex = 1
                            }
                        }
                    }
              
                    if timerIndex != 2 {
                        //handle the function for long press tile
                        touchedLongTile(tile: tile as! GameTileLong, timerNum: timerIndex)
                    }
                    
                    break
                default:
                    break
                }
            }
        }
  
        //reset the array which has touched tiles
        touchedArray.removeAll()
    }
    
    //delete long press tile
    func touchedLongTile(tile: GameTileLong, timerNum: Int){
        
        //delete timer and these information
        switch timerNum {
        case 0, 3:
            
            let targetTimer = gameView.longTileTimerAndTileArray[timerNum][0]
            if  targetTimer is Timer {
                (targetTimer as AnyObject).invalidate()
                gameView.longTileTimerAndTileArray.remove(at: timerNum)
                
                //to use "isEmpty", make the array index empty
                if gameView.longTileTimerAndTileArray.count == 0 {
                    gameView.longTileTimerAndTileArray = [[]]
                }
            }
            
            break
        case 1:
            let targetTimer = gameView.longTileTimerAndTileArray[timerNum][0]
            if  targetTimer is Timer {

                let targetTimer = gameView.longTileTimerAndTileArray[timerNum][0] as! Timer
                targetTimer.invalidate()
                gameView.longTileTimerAndTileArray.removeLast()
                
                //to use "isEmpty", make the array index empty
                if gameView.longTileTimerAndTileArray.count == 0 {
                    gameView.longTileTimerAndTileArray = [[]]
                }
            }
            
            break
        default:
            break
        }
        
        //delete tile from longTileTimerAndTileArray
        self.gameView.deleteTile(target: tile)
        //disable to touch on the tile
        tile.isUserInteractionEnabled = false
        //change alpha
        tile.alpha = 0.5
    }
    
  
    /// back to top
    @objc func backToTop(){
        
        //stop all timer
        gameView.allTimerInvalidate()

        //back to start viewcontroller
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
