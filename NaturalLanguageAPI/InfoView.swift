//
//  InfoView.swift
//  NaturalLanguageAPI
//
//  Created by 茅根啓介 on 2023/07/04.
//

import SwiftUI

struct InfoView: View {
    //変数
    var info: InfoObject
    
    var characterCountIndication: LocalizedStringKey {
        return "\(info.letters.count) letters"
    }
    
    var wordCountIndication: LocalizedStringKey {
        return "\(info.words.count) words"
    }
    
    var sentenceCountIndication: LocalizedStringKey {
        return "\(info.sentences.count) sentences"
    }
    
    var paragraphCountIndication: LocalizedStringKey {
        return "\(info.paragraphs.count) paragraphs"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading) {
                        Text("Character")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text(characterCountIndication)
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .accessibilityValue(Text(characterCountIndication))
                            .accessibilityLabel(Text("Word"))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Word")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text(wordCountIndication)
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .accessibilityValue(Text(wordCountIndication))
                            .accessibilityLabel(Text("Word"))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Sentence")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text(sentenceCountIndication)
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .accessibilityValue(Text(sentenceCountIndication))
                            .accessibilityLabel(Text("Sentence"))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Paragraph")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text(paragraphCountIndication)
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .accessibilityValue(Text(paragraphCountIndication))
                            .accessibilityLabel(Text("Paragraph"))
                    }
                    
                    HStack {
                        Text("Text Size")
                            .font(.title3)
                            .accessibilityHidden(true)
                        
                        Spacer()
                        
                        Text(info.fileSize)
                            .accessibilityValue(Text(info.fileSize))
                            .accessibilityLabel(Text("Text Size"))
                    }
                    
                    HStack {
                        Text("Language")
                            .font(.title3)
                            .accessibilityHidden(true)
                        
                        Spacer()
                        
                        Text(info.language.name)
                            .accessibilityValue(Text(info.language.name))
                            .accessibilityLabel(Text("Language"))
                    }
                    
                    if info.isAvailableSentsentiment {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Emotion")
                                    .font(.title3)
                                    .accessibilityHidden(true)
                                Spacer()
                                
                                Text(info.sentsentiment.state)
                            }
                            Gauge(value: info.sentsentiment.score ?? 0,in: -1.0...1.0) {
                                
                            } currentValueLabel: {
                                Text(String(format: "%.1f", info.sentsentiment.score ?? 0.0))
                            } minimumValueLabel: {
                                Text("\(String(format:"%.1f",-1.0))")
                            } maximumValueLabel: {
                                Text(" \(String(format:"%.1f",-1.0))")
                            }
                            .padding(.horizontal)
                            .gaugeStyle(.linearCapacity)
                            .tint(Gradient(colors: [.blue, .yellow, .red]))
                        }
                    }
                }
                
                if info.isAvailablePartOfSpeech {
                    Section {
                        ForEach(info.partOfSpeech) { elem in
                            Text("\(elem.num):\(elem.title)")
                        }
//                        Chart(info.partOfSpeech) { elem in
//                            SectorMark(
//                                angle: .value("Ratio", elem.num),
//                                angularInset: 1
//                            )
//                            .foregroundStyle(by: .value("Part of speech", elem.title))
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical)
                    } header: {
                        Text("Part of speech")
                    }
                }
                
                if info.isAvailableProperNouns {
                    Section {
                        ForEach(info.properNouns) { item in
                            Link(destination: makeURL(keyword: String(item.contents))) {
                                switch item.tag {
                                case .personalName:
                                    Label(item.contents, systemImage: "person")
                                case .placeName:
                                    Label(item.contents, systemImage: "map")
                                case .organizationName:
                                    Label(item.contents, systemImage: "person.3")
                                default:
                                    EmptyView()
                                }
                            }
                            .contextMenu {
                                Button {
#if os(iOS)
                                    UIPasteboard.general.string = String(item.contents)
#elseif os(macOS)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(String(item.contents), forType: .string)
#endif
                                } label: {
                                    Label("Copy", systemImage: "doc.on.clipboard")
                                }
                            }
                        }
                    } header: {
                        Text("Detection")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Info")
#if os(iOS)
            .toolbarRole(.navigationStack)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
    }
    
    func makeURL(keyword: String) -> URL {
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let string = "https://www.google.com/search?q=\(encodedKeyword!)"
        return URL(string: string)!
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(info: InfoObject(text: "text"))
    }
}
