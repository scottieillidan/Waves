//
//  Model.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import Foundation
import RealmSwift

final class SongModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var artist: String?
    @Persisted var data: Data
    @Persisted var coverImage: Data?
    @Persisted var duration: TimeInterval?
    
    convenience init(name: String, artist: String? = nil, data: Data, coverImage: Data? = nil, duration: TimeInterval? = nil) {
        self.init()
        self._id = _id
        self.name = name
        self.artist = artist
        self.data = data
        self.coverImage = coverImage
        self.duration = duration
    }
}
