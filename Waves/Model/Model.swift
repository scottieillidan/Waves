//
//  Model.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import Foundation
import RealmSwift

final class SongModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var album: String?
    @Persisted var artist: String?
    @Persisted var url: String
    @Persisted var path: String
    @Persisted var coverImage: Data?
    @Persisted var duration: TimeInterval?

convenience init(name: String, album: String? = nil, artist: String? = nil,
                 url: String, path: String, coverImage: Data? = nil,
                 duration: TimeInterval? = nil) {
        self.init()
        self.id = id
        self.name = name
        self.album = album
        self.artist = artist
        self.url = url
        self.path = path
        self.coverImage = coverImage
        self.duration = duration
    }
}
