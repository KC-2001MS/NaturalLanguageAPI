//
//  InfoObject.swift
//  NaturalLanguageAPI
//
//  Created by 茅根啓介 on 2023/07/04.
//

import Foundation
import NaturalLanguage
import SwiftUI

final class InfoObject {
    var text: String
    
    var letters: Array<Character> {
        get {
            return Array(text)
        }
    }
    
    var words: Array<String> {
        get {
            return makeTextToken(token: .word)
        }
    }
    
    var sentences: Array<String> {
        get {
            return makeTextToken(token: .sentence)
        }
    }
    
    var paragraphs: Array<String> {
        get {
            return makeTextToken(token: .paragraph)
        }
    }
    
    var fileSize: String {
        get {
            let bitSize = text.utf8.count
            let result: String
            
            if bitSize > 99999999999 {
                result = "∞ B"
            } else if bitSize > 1000000000 {
                result = "\(bitSize/1000000000)GB"
            } else if bitSize > 1000000 {
                result = "\(bitSize/1000000)MB"
            } else if bitSize > 1000 {
                result = "\(bitSize/1000)KB"
            } else {
                result = "\(bitSize)Byte"
            }
            
            return result
        }
    }
    var language: (name: String, type: NLLanguage) { // 計算型プロパティ
        get {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            var languageName: String = "Unknown"
            var languageType: NLLanguage = .undetermined
            let languageList: Array<GreetingandLanguage> = Bundle.main.decodeJSON("GreetingandLanguage.json")
            if let Lang = recognizer.dominantLanguage {
                languageType = Lang
                for lang in languageList {
                    if Lang.rawValue == lang.code {
                        languageName = lang.language
                        break
                    }
                }
            }
            languageName = NSLocalizedString(languageName ,comment:"")
            return (name: languageName, type: languageType)
        }
    }
    
    var sentsentiment: (score: Double?,state: LocalizedStringKey) {
            var sentimentScore: Double? = nil
            var sentimentState: LocalizedStringKey = "Unsupported"
            if isAvailableSentsentiment {
                let tagger = NLTagger(tagSchemes: [.sentimentScore])
                tagger.string = text
                let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
                if let score = Double(sentiment?.rawValue ?? "0") {
                    sentimentScore = score
                    if score > 0 {
                        sentimentState = "Positive"
                    } else if score == 0 {
                        sentimentState = "Neutral"
                    } else {
                        sentimentState = "Negative"
                    }
                }
            }
            
            return (score: sentimentScore,state: sentimentState)
    }
    
    var partOfSpeech: Array<PartOfSpeechItem> {
        var partOfSpeechList: Dictionary<String, Int> = [:]
        var partOfSpeechArray: Array<PartOfSpeechItem> = []
        if isAvailablePartOfSpeech {
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = text
            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
                if let tag = tag {
                    if partOfSpeechList.keys.contains(tag.rawValue) {
                        partOfSpeechList[tag.rawValue] = partOfSpeechList[tag.rawValue]! + 1
                    } else {
                        partOfSpeechList["\(tag.rawValue)"] = 1
                    }
                }
                return true
            }
        }
        for elem in partOfSpeechList {
            partOfSpeechArray.append(PartOfSpeechItem(title: elem.key, num: elem.value))
        }
        partOfSpeechArray.sort {
            $0 > $1
        }
        return partOfSpeechArray
    }
    
    var properNouns: Array<ProperNounItem> {
        var properNounsList: Array<ProperNounItem> = []

        if isAvailableProperNouns {
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = text
            let options: NLTagger.Options = [.omitWhitespace, .joinNames]
            let tags: [NLTag] = [.personalName, .placeName, .organizationName]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
                // Get the most likely tag, and print it if it's a named entity.
                if let tag = tag, tags.contains(tag) {
                    if !properNounsList.contains(where: {$0.contents == text[tokenRange]}) {
                        properNounsList.append(ProperNounItem(contents: text[tokenRange],tag: tag))
                    }
                }

               return true
            }
        }
        return properNounsList
    }
    
    private var analysisPossibleList: Array<NLTagScheme> {
        let units: [NLTokenUnit] = [.word, .sentence, .paragraph, .document]

        let availableTagSchemes: Set<NLTagScheme> = Set(units.flatMap { unit in
            NLTagger.availableTagSchemes(for: unit, language: language.type)
        })
        
        return Array(availableTagSchemes)
    }
    
    var isAvailableSentsentiment: Bool {
        return analysisPossibleList.contains(.sentimentScore)
    }
    
    var isAvailableProperNouns: Bool {
        return analysisPossibleList.contains(.nameType)
    }
    
    var isAvailablePartOfSpeech: Bool {
        return analysisPossibleList.contains(.lexicalClass)
    }
    
    init(text: String) {
        self.text = text
    }
    
    func makeTextToken(token: NLTokenUnit) -> Array<String>  {
        let tokenizer = NLTokenizer(unit: token)
        tokenizer.string = text
        let tokens = tokenizer.tokens(for: text.startIndex ..< text.endIndex)
        var textTokens: [String] = []
        
        for token in tokens {
            let tokenStartI = token.lowerBound
            let tokenEndI = token.upperBound
            let text = text[tokenStartI ..< tokenEndI]
            textTokens.append(String(text))
        }
        
        return textTokens
    }
}

struct ProperNounItem: Identifiable {
    var id: UUID
    var contents: Substring
    var tag: NLTag
    
    init(contents: Substring, tag: NLTag) {
        self.id = UUID()
        self.contents = contents
        self.tag = tag
    }
}

struct PartOfSpeechItem: Identifiable,Comparable {
    static func < (lhs: PartOfSpeechItem, rhs: PartOfSpeechItem) -> Bool {
        if lhs.num < rhs.num {
            return true
        } else if lhs.num == rhs.num {
            return lhs.title < rhs.title
        } else {
            return lhs.num < rhs.num
        }
    }
    
    var id: UUID
    var title: String
    var num: Int
    
    init(title: String, num: Int) {
        self.id = UUID()
        self.title = title
        self.num = num
    }
}
