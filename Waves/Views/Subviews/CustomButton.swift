//
//  CustomButtonView.swift
//  Waves
//
//  Created by Adam Miziev on 26/12/2024.
//

import SwiftUI

func CustomButtom(image: String, size: Font, color: Color = Color.white, action: @escaping () -> Void) -> some View {
    Button {
        action()
    } label: {
        ZStack {
            if image.contains("play") || image.contains("pause") {
                Circle()
                    .stroke(lineWidth: 4)
                    .frame(height: SizeConstant.miniPlayer)
            }
            Image(systemName: image)
                .foregroundStyle(color)
                .font(size)
        }
    }
}
