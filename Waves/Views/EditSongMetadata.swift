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

    let unsuppportedFileExtensions = ["WAV"]

    // MARK: - Body
    var body: some View {
        let extensionCondition = unsuppportedFileExtensions.contains(song.fileExtension)
        let labels: [String] = ["Format", "Duration", "Size", "Created"]
        let values: [String] = [
            "\(song.fileExtension)",
            "\(vm.durationFormatted(song.duration!))",
            "\(ByteCountFormatter.string(fromByteCount: song.size!, countStyle: .file))",
            "\(vm.creationDateFormatted(song.creationDate!))"
        ]

        ScrollView(.vertical) {
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
                    let newSong = SongModel(
                        title: title.isEmpty ? song.title : title,
                        album: album.isEmpty ? "Unknown Album" : album,
                        artist: artist.isEmpty ? "Unknown Artist" : artist,
                        duration: song.duration,
                        coverImage: coverImage,
                        fileName: song.fileName,
                        fileExtension: song.fileExtension,
                        size: song.size,
                        creationDate: song.creationDate
                    )
                    if extensionCondition {
                        Task {
                            await vm.updateSongMetadata(from: newSong, to: song)
                        }
                    } else {
                        vm.editMetaData(from: newSong, to: song)
                    }
                    dismiss()
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
            }
            // MARK: - Background
            .padding()
        }
        .background(.darkBG)
        .safeAreaInset(edge: .bottom, alignment: .leading, content: {
            if extensionCondition {
                VStack {
                    Text("Unsuppported Extension: \(song.fileExtension).")
                        .titleFont(isSelected: true)
                    Text("The file metadata will not be edited.")
                        .bodyFont(isSelected: true)
                }
                .padding(.vertical, 20)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
            }
        })
        .scrollIndicators(.hidden)
        // MARK: - Navigation Bar
        .navigationTitle("Edit Metadata")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                }
            }
        }
        .toolbarBackground(.darkBG, for: .navigationBar)
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
            self.coverImage = song.coverImage ?? UIImage(named: "Waves")?.jpegData(compressionQuality: 1.0)
        }

    }

    func CustomTextField(_ label: String, text: Binding<String>) -> some View {
        TextField(label, text: text)
            .padding(.vertical, 12)
            .padding(.horizontal)
    }
}
