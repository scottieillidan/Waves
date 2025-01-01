//
//  EditSongMetadata.swift
//  Waves
//
//  Created by Adam Miziev on 29/11/2024.
//

import SwiftUI
import PhotosUI

struct EditSongMetadata: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var vm: ViewModel

    @State var song: SongModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var coverImage: Data?
    @State private var title: String = ""
    @State private var album: String = ""
    @State private var artist: String = ""

    // MARK: - Body
    var body: some View {
        var bitrate: Int {
            let kbit = UInt64(song.size!) / 128
            let kbps = ceil(round(Double(kbit)/Double(song.duration!))/16)*16
            return Int(kbps)
        }
        let labels: [String] = ["Format", "Duration", "Bitrate", "Size", "Created"]
        let values: [String] = [
            "\(song.fileExtension!)",
            "\(vm.durationFormatted(song.duration!))",
            "\(bitrate) Kbps",
            "\(ByteCountFormatter.string(fromByteCount: song.size!, countStyle: .file))",
            "\(vm.creationDateFormatted(song.creationDate!))"
        ]

        VStack(spacing: 20) {
            /// Cover
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                SongCoverView(coverData: coverImage, size: SizeConstant.fullPlayer * 0.8)
            }
            /// Metadata
            VStack(spacing: 0) {
                CustomTextField("Title", text: $title)
                Divider()
                CustomTextField("Artist", text: $artist)
                Divider()
                CustomTextField("Album", text: $album)
            }
            .background(.quinary)
            .clipShape(.rect(cornerRadius: SizeConstant.cornerRadius))

            Button {
                Task {
                    let newSong = SongModel(
                        title: title,
                        album: album,
                        artist: artist,
                        duration: song.duration,
                        coverImage: coverImage,
                        fileName: song.fileName,
                        fileExtension: song.fileExtension,
                        size: song.size,
                        creationDate: song.creationDate
                    )
                    vm.editMetaData(from: newSong, to: song)
                    dismiss()
                }
            } label: {
                Text("Save")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .background(.quinary)
            .clipShape(.rect(cornerRadius: SizeConstant.cornerRadius))

            /// Additional Audio Information.
            VStack(spacing: 0) {
                ForEach(labels.indices, id: \.self) { i in
                    HStack {
                        Text(labels[i])
                            .bodyFont()
                        Spacer()
                        Text(values[i])
                            .titleFont()
                    }
                    .padding(10)
                    if i != labels.count - 1 {
                        Divider()
                    }
                }
            }
            .opacity(0.8)
            Spacer()
        }
        // MARK: - Navigation Bar
        .navigationTitle(song.title)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Background
        .padding()
        .background(.darkBG)
        // MARK: - Methods
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
            self.title = song.title
            self.album = song.album ?? self.album
            self.artist = song.artist ?? self.artist
            self.coverImage = song.coverImage ?? nil
        }

    }

    func CustomTextField(_ label: String, text: Binding<String>) -> some View {
        TextField(label, text: text)
            .padding(.vertical, 12)
            .padding(.horizontal)
    }
}
