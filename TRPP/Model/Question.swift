//
//  Question.swift
//  TRPP
//
//  Created by Герман Кунин on 26.03.2023.
//

import Foundation

struct Question: Decodable {
    public let level: Int
    public let ask: String
    public let correctAnswer: String
    public let wrongAnswers: [String]
    
    static func getQuestions() -> [Question] {
        if let url = Bundle.main.url(forResource: "questions",
                                     withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                var questions = try decoder.decode([Question].self,
                                                   from: data)
                questions.shuffle()
                var fifteen: [Question] = []
                for i in 1...15 {
                    if let question = questions.first(where: { $0.level == i }) {
                        fifteen.append(question)
                    }
                }
                return fifteen
            } catch {
                print("error:\(error)")
            }
        }
        return []
    }
}
