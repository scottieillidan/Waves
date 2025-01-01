//
//  ImportFileManager.swift
//  Waves
//
//  Created by Adam Miziev on 19/11/24.
//

import Foundation
import SwiftUI
import AVFoundation
import RealmSwift

/// ImportFileManager позволяет выбирать аудиофайлы и импортировать их в приложение.
struct ImportFileManager: UIViewControllerRepresentable {

    /// Coordinator управляет между задачами SwiftUI и UIKit.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    /// Метод который создает и настраивает UIDocumentPickerViewController, который используется для выбора аудиофайлов.
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        /// Разрешение открытия файлов с типом .mp3 и .wav.
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])

        picker.allowsMultipleSelection = true
        picker.shouldShowFileExtensions = true

        /// Установка координатора в качестве делегата.
        picker.delegate = context.coordinator

        return picker
    }

    /// Метод предназначен для обновления котроллера с новыми данными.
    /// В данном случае он пуст, так как все необходимые настройки выполнены при создании.
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    /// Coordinator служит связующим звеном между UIDocumentPicker и ImportFileManager.
    class Coordinator: NSObject, UIDocumentPickerDelegate {

        // MARK: - Properties
        /// Ссылка на родительский компонент ImportFileManager, чтобы можно было с ним взаимодействовать.
        var parent: ImportFileManager

        @ObservedResults(SongModel.self) var songs

        // MARK: - Initializer
        init(parent: ImportFileManager) {
            self.parent = parent
        }

        // MARK: - Methods
        /// Метод вызывается когда пользователь выбирает файл.
        /// Метод обрабатывает выбраный URL, создает файл типом SongModel и после добавляет песню в массив songs.
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            Task {
                for url in urls {
                    /// После извлечения url, метод startAccessingSecurityScopedResource  вызывается для начала доступа к защищеному ресурсу.
                    if url.startAccessingSecurityScopedResource() {
                        /// Гарантирует что метод stopAccessingSecurityScopedResource будет вызван когда выполнение documentPicker завершится, независимо от результата.
                        /// Ресурс безопастности будет закрыт и корректно освобожден.
                        defer { url.stopAccessingSecurityScopedResource() }

                        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory,
                                                                            in: .userDomainMask).first

                        let destinationURL = documentDirectoryURL?.appendingPathComponent(url.lastPathComponent)

                        /// Перемещение файла в каталог, доступный приложению.
                        /// Таким образом, нам не придеться спрашивать разрешения на воспроизведение.
                        if !FileManager.default.fileExists(atPath: destinationURL!.path) {
                            URLSession.shared.downloadTask(with: url) { location, _, error in
                                guard let location = location, error == nil else { return }
                                do {
                                    try FileManager.default.moveItem(at: location, to: destinationURL!)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }.resume()
                        }

                        let fileName = destinationURL!.lastPathComponent

                        /// Инициализируем объект SongModel.
                        let song = SongModel(title: fileName, fileName: fileName)

                        loadFileInfo(song: song, path: url.path)

                        /// Создание AVURLAsset для извлечения метаданных.
                        let asset = AVURLAsset(url: url)

                        await loadSongMetaData(from: asset, to: song)

                        /// Добавление песни в массив songs.
                        let isDuplicate = songs.contains(where: {$0.fileName == song.fileName})
                        if !isDuplicate {
                            $songs.append(song)
                        }
                    }
                }
            }
        }

        /// Метод извлекает метаданные из asset и сохраняет их в song.
        func loadSongMetaData(from asset: AVAsset, to song: SongModel) async {
            do {
                let metadata = try await asset.load(.metadata)

                /// Цикл для итерации по метаданным аудиофайла, чтобы извлечь (испольнитель, обложка, название).
                for item in metadata {

                    /// Проверяем есть ли метаданные у файла через ключ / значение.
                    guard let key = item.commonKey?.rawValue, let value = try await item.load(.value) else { continue }

                    switch key {
                    case AVMetadataKey.commonKeyArtist.rawValue:
                        song.artist = value as? String
                    case AVMetadataKey.commonKeyTitle.rawValue:
                        song.title = value as? String ?? song.title
                    case AVMetadataKey.commonKeyAlbumName.rawValue:
                        song.album = value as? String
                    case AVMetadataKey.commonKeyArtwork.rawValue:
                        song.coverImage = value as? Data
                    default:
                        break
                    }
                }

                /// Получения продолжительности аудио.
                song.duration = try await CMTimeGetSeconds(asset.load(.duration))
            } catch {
                print(error.localizedDescription)
            }
        }

        func loadFileInfo(song: SongModel, path: String) {
            do {
                /// Создание attr для извлечения информации о файле.
                let attr = try FileManager.default.attributesOfItem(atPath: path)
                let size = attr[.size] as? Int64 ?? 0
                let creationDate = attr[.creationDate] as? Date ?? Date()
                let filename: NSString = path as NSString
                song.fileExtension = filename.pathExtension.uppercased()
                song.size = size
                song.creationDate = creationDate
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
