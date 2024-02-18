//
//  SystemDefaults.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/18/24.
//

import Foundation
import SwiftUI

// For scaling with screen size

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

// Custom Color Definitions

let woodBrown = Color(hex:"BC8F5E")
let lightWoodBrown = Color(hex:"E2AB74")
let woodAccent = Color(hex:"9E7852")

let recordBlack = Color(hex:"0C0C0C")
let decorBlack = Color(hex:"1A1A1A")
let iconWhite = Color(hex:"FBFFFE")
let decorWhite = Color(hex:"EAE7E4")

let mintGreen = Color(hex: "BFC8AD")
let seaweedGreen = Color(hex: "475841")
let blueGreen = Color(hex: "2B4141")
let grayBlue = Color(hex: "7D869C")
let deepBlue = Color(hex: "2E294E")

let yellowOrange = Color(hex: "CC8229")
let paleRed = Color(hex: "A97C73")
let pinkRed = Color(hex:"A63A50")
let redBrown = Color(hex:"3F0D12")
let darkRedBrown = Color(hex:"1E000E")

let smallDisplayColors: [Color] = [seaweedGreen,blueGreen,deepBlue,redBrown,pinkRed,yellowOrange]

let fullDisplayColors: [Color] = [seaweedGreen, blueGreen,deepBlue,darkRedBrown,redBrown,pinkRed,yellowOrange,lightWoodBrown,paleRed,grayBlue,mintGreen]
let totalDisplayColors = fullDisplayColors.count


// For filling instances where user library isn't large enough for logic
let defaultRecordItems: [RecordItem] = [
    RecordItem(
        id:"Default1",
        name:"Hunky Dory",
        artist:"David Bowie",
        coverPhoto: UIImage(named:"DavidBowie")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1971,
        dateAdded: "01-01-2020",
        isBand: false
        ),
    RecordItem(
        id:"Default2",
        name:"Talking Heads '77",
        artist:"Talking Heads",
        coverPhoto: UIImage(named:"TalkingHeads")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1977,
        dateAdded: "01-01-2020",
        isBand: true
        ),
    RecordItem(
        id:"Default3",
        name:"The Dark Side of the Moon",
        artist:"Pink Floyd",
        coverPhoto: UIImage(named:"PinkFloyd")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1973,
        dateAdded: "01-01-2020",
        isBand: true
        ),
    RecordItem(
        id:"Default4",
        name:"The Bends",
        artist:"Radiohead",
        coverPhoto: UIImage(named:"Radiohead")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1995,
        dateAdded: "01-01-2020",
        isBand: true
        ),
    RecordItem(
        id:"Default5",
        name:"Bridge Over Troubled Water",
        artist:"Simon & Garfunkel",
        coverPhoto: UIImage(named:"S&G")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1970,
        dateAdded: "01-01-2020",
        isBand: true
        ),
    RecordItem(
        id:"Default6",
        name:"Led Zeppelin IV",
        artist:"Led Zeppelin",
        coverPhoto: UIImage(named:"LedZeppelin")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1971,
        dateAdded: "01-01-2020",
        isBand: true
        ),
    RecordItem(
        id:"Default7",
        name:"The Smiths",
        artist:"The Smiths",
        coverPhoto: UIImage(named:"TheSmiths")!,
        discPhoto: UIImage(named:"TakePhoto")!,
        releaseYear: 1984,
        dateAdded: "01-01-2020",
        isBand: true
        )
]

