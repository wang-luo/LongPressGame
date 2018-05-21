//
//  GameView.swift
//  longPressTileProject
//
//  Created by wang on 2018/05/21.
//  Copyright © 2018年 json. All rights reserved.
//

import Foundation
import UIKit

class GameView: UIView {
    
    /// MARK: Properties
    
    /// parent view controller
    weak var gameViewController: GameViewController!
    
    /// the view has tiles
    var tileBGView: UIView!
    
    /// tiles which are moving now (if touched these alpha will be 0.5)
    var tiles: [UIImageView] = []
    
    /// tiles already touched
    var touchedTiles: [UIImageView] = []
    
    /// speed of dropping tiles
    var tileDurations: [Float] = [1.5, 5.0]
    
    /// random stay time to drop tiles
    var stayDurations: [Float] = [0.5, 1.0]
    
    /// tile speeds
    var tileSpeed: CGFloat = 1.5
    
    /// タイルの長さの最小・最大値
    var tileHeight: CGFloat = 290/2
    
    /// timer for drop tiles
    var makeTileTimerLane1: Timer!
    var makeTileTimerLane2: Timer!
    var makeTileTimerLane3: Timer!
    var makeTileTimerLane4: Timer!
    
    /// time for longPressTiles (you can get 1 point per 0.3 msec)
    var longPressScoreTimer1: Timer!
    var longPressScoreTimer2: Timer!
    
    /// [Timer, LongPressTile, the position where you touched in the tile, the position where the tile was in the screen when you touched the tile]
    var longTileTimerAndTileArray: [[Any]] = [[]]
    
    /// timer now using
    var tileTimerArray: Array<Timer> = []
    
    /// array for deciding which lane will be used
    var shuffleArray: [CGFloat] = [0.0, 1.0, 2.0, 3.0]
    
    /// if it isn't passed for 0.2 sec since the last tile was dropped, the tile won't be dropped
    var preTime:Date = Date()
    
    /// show your score
    var scoreLabel: UILabel!
    
    // MARK: init&reset
    
    /// initializer
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        //background color
        self.backgroundColor = UIColor.white
        
        //enable user touch
        self.isUserInteractionEnabled = true
        
        //screen size
        self.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        //the view tiles are in
        tileBGView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        tileBGView.isUserInteractionEnabled = true
        self.addSubview(tileBGView)
        
        //if it isn't passed for 0.2 sec since the last tile was dropped, the tile won't be dropped
        preTime = Date()
        
        //score label
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        scoreLabel.text = "0"
        scoreLabel.font = UIFont(name: "Helvetica", size: 20)
        scoreLabel.textColor = UIColor.black
        scoreLabel.textAlignment = NSTextAlignment.right
        self.addSubview(scoreLabel)
        
        //game start
        gameStart()
        
    }

    //reset tiles
    func resetTiles(){
        
        //delete all tiles
        tiles.removeAll()
        tileBGView.subviews.forEach({ $0.removeFromSuperview() })
        tileBGView.isHidden = false
        
    }
    
    // MARK: make & move tiles
    
    //start make tiles
    func moveTilesLane(lane: Int, after: TimeInterval){
        
        self.makeTiles(lane: lane)
        let staySeconds = TimeInterval(getRandomNumber(Min: Double(tileDurations[0]), Max: Double(self.tileDurations[1])))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + staySeconds) {
            
            self.moveTilesLane(lane: lane, after: TimeInterval(staySeconds))
            
        }
    }
    
    //make tiles
    func makeTiles(lane: Int){
        
        //now time
        let nowTime:Date = Date()
        if  nowTime.timeIntervalSince(preTime) > 0.2 {
            
            preTime = nowTime
            
            //stay for a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(getRandomNumber(Min: Double(stayDurations[0]), Max: Double(stayDurations[1])))) {
                
                // decide the lane will use
                let randomNum: Int = Int(arc4random_uniform(100))
                let laneNumber: CGFloat = CGFloat(randomNum%4)
                
                //if there is no tile will overlaps with next tile, make and drop tile
                if self.checkTilePosition(lane: Int(laneNumber)) == true {
                    let tileLong = GameTileLong(frame: CGRect(x: laneNumber*(CGFloat(UIScreen.main.bounds.size.width/4)), y: -(864/2), width: UIScreen.main.bounds.size.width/4, height: 864/2),
                                                isHidden: false,
                                                isUserInteractionEnabled: true,
                                                lane: Int(laneNumber))
                    self.tileBGView.addSubview(tileLong)
                    self.tiles.append(tileLong)
                    
                    //drop tile
                    self.moveTile(tile: tileLong, lane: lane)
                    
                }else{
                    //do nothing
                }
            }
        }
    }
    
    /// check whether next tile will be
    func checkTilePosition(lane: Int) -> Bool{
        
        // the array for checking if there is a tile which overlaps with next tile
        var checkTilePositionArray = [] as [Any]
        
        //whether the tile now checking is dropped on the lane
        if tiles.count != 0 {
            //check all tiles now dropping on screen
            for i in 0...tiles.count-1 {
                // if there is a tile which overlaps with next tile
                if tiles[i].frame.origin.y <= 864/2+1+1 &&
                    tiles[i].frame.origin.x/(UIScreen.main.bounds.size.width/4) == CGFloat(lane){
                    checkTilePositionArray.append(i)
                }
            }
        }
        
        //if there is tiles you already touched on screen
        if touchedTiles.count != 0 {
            //whether the tile now checking is dropped on the lane
            for i in 0...touchedTiles.count-1 {
                // if there is a tile which overlaps with next tile
                if touchedTiles[i].frame.origin.y <= 864/2+1+1 &&
                    touchedTiles[i].frame.origin.x/(UIScreen.main.bounds.size.width/4) == CGFloat(lane){
                    checkTilePositionArray.append(i)
                }
            }
        }
        
        // if there is a tile which overlaps with next tile
        if checkTilePositionArray.count > 0 {
            //don't drop new tile
            return false
        }else{
            //allow to drop new tile
            return true
        }
    }
    
    /// update tiles y position by timer
    @objc func updateTilesPositionY(timer: Timer){
        
        //change the tiles y position which are on screen and not touched
        self.tiles.forEach {
            $0.frame.origin.y += tileSpeed
        }
        //change the tiles y position which are on screen and already touched
        self.touchedTiles.forEach {
            $0.frame.origin.y += tileSpeed
        }
        
        //check whether the tile is dropped to the bottom
        self.touchedTiles.forEach {
            deleteTile(target: $0 as! GameTileLong)
        }
        
        //if tile is dropped to the bottom, delete the tile
        if let i = touchedTiles.index(where: { $0.frame.origin.y >= UIScreen.main.bounds.size.height}) {
            touchedTiles[i].removeFromSuperview()
        }
    }
    
    /// drop tiles
    func moveTile(tile: GameTile, lane: Int) {
        
        //the array including tile and lane information
        let sendArray: NSMutableArray = [tile, lane]

        //if timer is nil, start the timer and dropping tiles
        if makeTileTimerLane1 == nil{
            makeTileTimerLane1 = Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(updateTilesPositionY(timer:)), userInfo: sendArray, repeats: true)
        }else{
            //do nothing
        }
    }
    
    /// start LongPressTimer
    func startLongPressTimer(timerNum: Int, tile: GameTile){
        
        //change tile alpha
        tile.alpha = 0.5
        
        if timerNum == 1 {
            //start Timer1
            longPressScoreTimer1 = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(duringLongPress), userInfo: nil, repeats: true)
            //save tile and timer information
            longTileTimerAndTileArray[0].append(longPressScoreTimer1)
            longTileTimerAndTileArray[0].append(tile)
        }else if timerNum == 2 {
            //start Timer2
            longPressScoreTimer2 = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(duringLongPress2), userInfo: nil, repeats: true)
            //save information of tile and Timer
            longTileTimerAndTileArray.append([longPressScoreTimer2 as Any])
            longTileTimerAndTileArray[1].append(tile)
        }else{
            //don't allow to make over 3 Timer
        }
    }
    
    /// during pressing tile which is using longPressScoreTimer1
    @objc func duringLongPress(timer: Timer){
        
        // if you touch 1 or 2 tiles
        if longTileTimerAndTileArray.count >= 1 {
            
            //search where longPressScoreTimer1 is in longTileTimerAndTileArray
            let timerIndex:Int = searchTimerIndex(timer: longPressScoreTimer1)
            
            //if timer == 0 or 1, the timer is valid now
            if timerIndex <= 1 {
                //instance of tile
                let targetTile1:GameTileLong = longTileTimerAndTileArray[timerIndex][1] as! GameTileLong
                //y position of the finger when you touched in the tile
                let targetTileTouchedY1:CGFloat = longTileTimerAndTileArray[timerIndex][2] as! CGFloat
                //y position of the tile on screen when you touched in the tile
                let targetTileOriginY1:CGFloat = longTileTimerAndTileArray[timerIndex][3] as! CGFloat
                
                //check whether you touch the tile or not
                if targetTile1.frame.size.height - (targetTile1.frame.size.height - targetTileTouchedY1) <= targetTile1.frame.origin.y - targetTileOriginY1{
                    
                    //if the tile is in longTileTimerAndTileArray and the timer is valid
                    if longTileTimerAndTileArray[timerIndex][1] as! GameTileLong == targetTile1
                        && longTileTimerAndTileArray[timerIndex][0] is Timer{
                        //delete tile
                        gameViewController.touchedLongTile(tile: longTileTimerAndTileArray[timerIndex][1] as! GameTileLong, timerNum: timerIndex)
                        
                    } else {
                        //timer is missing
                    }
                }else{
                    //get 1 point
                    scoreLabel.text = String(Int(scoreLabel.text!)!+1)
                }
            }
        }else{
            //already you touch 1 or 2 tiles so do nothing
        }
    }
    
    /// during pressing tile which is using longPressScoreTimer2
    @objc func duringLongPress2(timer: Timer){
        
        //if longPressScoreTimer2 is not nil
        if longPressScoreTimer2 != nil {
            //search where longPressScoreTimer2 is in longTileTimerAndTileArray
            let timerIndex:Int = searchTimerIndex(timer: longPressScoreTimer2)
            
            //if timer == 0 or 1, the timer is valid now
            if timerIndex != 2 {
                if longTileTimerAndTileArray[timerIndex][1] as? GameTileLong != nil && longPressScoreTimer2.isValid == true{
                    
                    //call and make object the information of tile which using Timer is valid now
                    let targetTile2:UIImageView = longTileTimerAndTileArray[timerIndex][1] as! UIImageView
                    let targetTileTouchedY2:CGFloat = longTileTimerAndTileArray[timerIndex][2] as! CGFloat
                    let targetTileOriginY2:CGFloat = longTileTimerAndTileArray[timerIndex][3] as! CGFloat
                    
                    if targetTile2.frame.size.height - (targetTile2.frame.size.height - targetTileTouchedY2) <= targetTile2.frame.origin.y - targetTileOriginY2 {
                        
                        // delete a tile and a timer for the tile
                        if longTileTimerAndTileArray[timerIndex][1] as! GameTileLong == targetTile2 as! GameTileLong
                            && longTileTimerAndTileArray[timerIndex][0] is Timer {
                            
                            //delete tile
                            gameViewController.touchedLongTile(tile: longTileTimerAndTileArray[timerIndex][1] as! GameTileLong, timerNum: timerIndex)
                            
                        } else {
                            //missing tile or timer
                        }
                    }else{
                        //get 1 point
                        scoreLabel.text = String(Int(scoreLabel.text!)!+1)
                    }
                }
            }
        }else{
            //do nothing because you use over 3 fingers
        }
    }
    
    /// delete tiles that is touched
    func deleteTile(target: GameTile){
        
        if let i = tiles.index(where: { $0 == target }) {
            target.alpha = 0.5
            touchedTiles.append(target)
            tiles.remove(at: i)
        }
    }
    
    // MARK: other functions
    
    /// stop all timer
    func allTimerInvalidate(){
        
        if makeTileTimerLane1 != nil {
            makeTileTimerLane1.invalidate()
            makeTileTimerLane1 = nil
        }
        if longPressScoreTimer1 != nil {
            longPressScoreTimer1.invalidate()
            longPressScoreTimer1 = nil
        }
        if longPressScoreTimer2 != nil {
            longPressScoreTimer2.invalidate()
            longPressScoreTimer2 = nil
        }
        self.tileTimerArray.forEach {
            $0.invalidate()
        }
    }
    
    /// start game
    func gameStart(){
        
        self.isUserInteractionEnabled = true
        tileBGView.isUserInteractionEnabled = true
        
        //timer for dropping tiles start
        makeTileTimerLane1 = Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(updateTilesPositionY(timer:)), userInfo: nil, repeats: true)
        
        //make tiles each lanes
        moveTilesLane(lane: 1, after: TimeInterval(getRandomNumber(Min: Double(tileDurations[0]), Max: Double(tileDurations[1]))))
        moveTilesLane(lane: 1, after: TimeInterval(getRandomNumber(Min: Double(tileDurations[0]), Max: Double(tileDurations[1]))))
        moveTilesLane(lane: 1, after: TimeInterval(getRandomNumber(Min: Double(tileDurations[0]), Max: Double(tileDurations[1]))))
        moveTilesLane(lane: 1, after: TimeInterval(getRandomNumber(Min: Double(tileDurations[0]), Max: Double(tileDurations[1]))))
    }
    
    /// search Timer Index in longTileTimerAndTileArray
    func searchTimerIndex(timer: Timer) -> Int {
        
        // if the result will be 2, there is no timer
        var timerIndex:Int = 2
        
        if longTileTimerAndTileArray[0][0] as? Timer == timer {
            timerIndex = 0
        }
        
        if longTileTimerAndTileArray.count >= 2 {
            if longTileTimerAndTileArray[1][0] as? Timer == timer {
                timerIndex = 1
            }
        }
        
        return timerIndex
        
    }
    //make random numbers
    func getRandomNumber(Min _Min : Double, Max _Max : Double) -> Double {
        
        return ( Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX) ) * (_Max - _Min) + _Min
    }
    
    deinit {
        
    }
    
    /// - Parameter aDecoder: <#aDecoder description#>
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}

