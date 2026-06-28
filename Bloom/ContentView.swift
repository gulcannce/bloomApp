//
//  ContentView.swift
//  Bloom
//
//  Created by Gülcan  on 28.06.2026.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedEmoji: String? = nil
    @State private var carouselIndex: Int = 0

    private let photoItems = ["🌸", "✨", "☁️", "🌱", "🤍"]
    @State private var gestures: [Int: PhotoGestureState] = {
        var initial: [Int: PhotoGestureState] = [:]
        for i in 0..<5 {
            initial[i] = PhotoGestureState()
        }
        return initial
    }()

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.93)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Bloom")
                    .font(.system(size: 28, weight: .light, design: .default))
                    .tracking(0.8)
                    .foregroundColor(.black.opacity(0.7))

                PolaroidCard(
                    carouselIndex: $carouselIndex,
                    photoItems: photoItems,
                    gestures: $gestures
                )

                EmojiPicker(selectedEmoji: $selectedEmoji)

                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

struct PolaroidCard: View {
    @Binding var carouselIndex: Int
    let photoItems: [String]
    @Binding var gestures: [Int: PhotoGestureState]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.995, green: 0.992, blue: 0.988))
                .frame(width: 320, height: 420)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)

            VStack(spacing: 0) {
                TabView(selection: $carouselIndex) {
                    ForEach(photoItems.indices, id: \.self) { index in
                        PhotoWindow(
                            item: photoItems[index],
                            gestureState: gestures[index] ?? PhotoGestureState()
                        )
                        .tag(index)
                    }
                }
                .frame(width: 280, height: 340)
                .clipped()
                .zIndex(1)
                .overlay(alignment: .bottom) {
                    Color(red: 0.995, green: 0.992, blue: 0.988)
                        .frame(height: 40)
                }

                VStack(spacing: 8) {
                    Text("Anı")
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(.black.opacity(0.6))

                    Text("28 Haziran 2026")
                        .font(.system(size: 11, weight: .light, design: .default))
                        .foregroundColor(.black.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .zIndex(0)
            }
            .frame(width: 320, height: 420)
            .padding(.top, 20)
        }
        .frame(width: 320, height: 420)
        .clipped()
    }
}

struct PhotoWindow: View {
    let item: String
    let gestureState: PhotoGestureState

    var body: some View {
        ZStack {
            Color.gray.opacity(0.12)

            Text(item)
                .font(.system(size: 64))
        }
        .scaleEffect(gestureState.scale)
        .offset(gestureState.offset)
        .rotationEffect(gestureState.rotation)
        .cornerRadius(8)
        .clipped()
        .highPriorityGesture(
            SimultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = CGSize(
                            width: value.translation.width,
                            height: value.translation.height
                        )
                        gestureState.offset = newOffset
                        print("QA_LOG: Photo Offset Updated -> \(newOffset)")
                    },
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            gestureState.scale = value
                            print("QA_LOG: Photo Scale Updated -> \(value)")
                        },
                    RotationGesture()
                        .onChanged { value in
                            gestureState.rotation = value
                            print("QA_LOG: Rotation Angle Updated -> \(value.degrees)")
                        }
                )
            )
        )
    }
}

struct EmojiPicker: View {
    @Binding var selectedEmoji: String?
    private let emojis = ["🌸", "✨", "☁️", "🌱", "🤍"]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(emojis, id: \.self) { emoji in
                Button(action: {
                    selectedEmoji = emoji
                    print("QA_LOG: Native Emoji Selected -> \(emoji)")
                }) {
                    Text(emoji)
                        .font(.system(size: 28))
                        .frame(width: 48, height: 48)
                        .background(
                            Capsule()
                                .fill(
                                    selectedEmoji == emoji
                                        ? Color(red: 0.95, green: 0.93, blue: 0.90)
                                        : Color.clear
                                )
                        )
                        .scaleEffect(selectedEmoji == emoji ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: selectedEmoji)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

class PhotoGestureState: ObservableObject {
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var rotation: Angle = .zero
}

#Preview {
    ContentView()
}
