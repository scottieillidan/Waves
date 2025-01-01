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
    @Persisted var title: String
    @Persisted var album: String?
    @Persisted var artist: String?
    @Persisted var duration: TimeInterval?
    @Persisted var coverImage: Data?
    @Persisted var fileName: String
    @Persisted var fileExtension: String?
    @Persisted var size: Int64?
    @Persisted var creationDate: Date?

    convenience init(title: String, album: String? = nil, artist: String? = nil, duration: TimeInterval? = nil, coverImage: Data? = nil, fileName: String, fileExtension: String? = nil, size: Int64? = nil, creationDate: Date? = nil) {
        self.init()
        self.title = title
        self.album = album
        self.artist = artist
        self.duration = duration
        self.coverImage = coverImage
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.size = size
        self.creationDate = creationDate
    }
}
