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
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3, .wav])
        
        // picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        
        /// Установка координатора в качестве делегата.
        picker.delegate = context.coordinator
        
        return picker
    }
    
    /// Метод предназначен для обновления котроллера с новыми данными. В данном случае он пуст, так как все необходимые настройки выполнены при создании.
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
            //            for item in urls {
            //                let url = item
            //                url.startAccessingSecurityScopedResource()
            //            }
            
            /// guard let, безопастно извлекает первый элемент из массива urls. Если массив пуст, то urls.first вернет nil и условие не пропустит, что приведет к выходу из метода documentPicker.
            /// После извлечения url, метод startAccessingSecurityScopedResource вызывается для начала доступа к защищеному ресурсу.
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            
            /// Гарантирует что метод stopAccessingSecurityScopedResource будет вызван когда выполнение documentPicker завершится, независимо от результата.
            /// Ресурс безопастности будет закрыт и корректно освобожден.
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                
                /// Получение данных файла.
                let document = try Data(contentsOf: url)
                
                /// Создание AVURLAsset для извлечения метаданных.
                let asset = AVURLAsset(url: url)
                
                /// Инициализируем объект SongModel.
                let song = SongModel(name: url.lastPathComponent, data: document)
                
                /// Цикл для итерации по метаданным аудиофайла, чтобы извлечь (испольнитель, обложка, название).
                let metadata = asset.metadata
                
                for item in metadata {
                    
                    /// Проверяем есть ли метаданные у файла через ключ / значение.
                    guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
                    
                    switch key {
                    case AVMetadataKey.commonKeyArtist.rawValue:
                        song.artist = value as? String
                    case AVMetadataKey.commonKeyArtwork.rawValue:
                        song.coverImage = value as? Data
                    case AVMetadataKey.commonKeyTitle.rawValue:
                        song.name = value as? String ?? song.name
                    default:
                        break
                    }
                }
                
                /// Получения продолжительности песни.
                song.duration = CMTimeGetSeconds(asset.duration)
                
                /// Добавление песни в массив songs.
                let isDuplicate = songs.contains(where: {$0.data == song.data && $0.name == song.name})
                if !isDuplicate {
                    $songs.append(song)
                }
                
            } catch {
                print("Error processing the file: \(error)")
            }
        }
    }
}
