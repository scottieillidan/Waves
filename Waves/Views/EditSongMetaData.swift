//
//  EditSongMetaData.swift
//  Waves
//
//  Created by Adam Miziev on 29/11/2024.
//

import SwiftUI
import PhotosUI

struct EditSongMetaData: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss

    let editMetaData: (SongModel, SongModel) -> Void

    @State var song: SongModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var coverImage: Data?
    @State private var title: String = ""
    @State private var album: String = ""
    @State private var artist: String = ""

    // MARK: - Body
    var body: some View {
        VStack(spacing: 30) {
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                SongCoverView(coverData: coverImage, size: 200)
            }
            TextField("Title", text: $title)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quinary))
            TextField("Album", text: $album)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quinary))
            TextField("Artist", text: $artist)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quinary))
            Button {
                Task {
                    let newSong = SongModel(name: title, album: album, artist: artist,
                                            url: song.url, path: song.path,
                                            coverImage: coverImage, duration: song.duration)
                    editMetaData(song, newSong)
                    dismiss()
                }
            } label: {
                Text("Save")
                    .nameFont()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .padding(40)
        .onChange(of: photosPickerItem) { _ in
            Task {
                if let photosPickerItem,
                   let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                    coverImage = data
                }

                photosPickerItem = nil
            }
        }
        .onAppear {
            self.title = song.name
            self.album = song.album ?? self.album
            self.artist = song.artist ?? self.artist
            self.coverImage = song.coverImage ?? nil
        }
    }
}
