//
//  VideoModel.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 28/06/25.
//

import Foundation

struct VideoModel {
    let id : UUID
    let title : String
    let description : String
    let fileName: String
    let date : Date
    let time : Int32
    let thumbnail : Data
}
