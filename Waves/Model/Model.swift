//
//  Model.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import Foundation

struct SongModel: Identifiable {
    var id = UUID()
    var name: String
    var artist: String?
    var data: Data
    var coverImage: Data?
    var duration: TimeInterval?
}
