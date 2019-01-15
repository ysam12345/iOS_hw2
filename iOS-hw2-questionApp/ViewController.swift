//
//  ViewController.swift
//  iOS-hw2-questionApp
//
//  Created by yochien on 2018/12/5.
//  Copyright © 2018 yochien. All rights reserved.
//

import UIKit

struct Question: Codable {
    var question: String
    var correct_answer: String
    var incorrect_answers: [String]
}

struct QuestionResults: Codable {
    var results: [Question]
}

class ViewController: UIViewController {
    
    private var questions : Array<Question>?
    private var point : Int?
    private var questionNum : Int?
    private var choiceArray : Array<String>?

    @IBOutlet weak var ans1: UIButton!
    @IBOutlet weak var ans2: UIButton!
    @IBOutlet weak var ans3: UIButton!
    @IBOutlet weak var ans4: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var questionNumber: UITextView!
    @IBOutlet weak var pointNumbers: UITextView!
    
    @IBAction func a1(_ sender: Any) {
        answerQuestion(ans:1)
    }
    
    @IBAction func a2(_ sender: Any) {
        answerQuestion(ans:2)
    }
    
    @IBAction func a3(_ sender: Any) {
        answerQuestion(ans:3)
    }

    
    @IBAction func a4(_ sender: Any) {
        answerQuestion(ans:4)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.questionNum = 1
        self.point = 0
        self.questionNumber.text = "Q."+String(self.questionNum!)
        self.pointNumbers.text = "Point:0"
        let url = URL(string: "https://opentdb.com/api.php?amount=20&type=multiple")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let data = data, let questionResults = try?
                decoder.decode(QuestionResults.self, from: data)
            {
                self.questions = questionResults.results
                for question in questionResults.results {
                    print(question)
                }
                
                let questionResults = self.questions
                self.choiceArray = []
                
                DispatchQueue.main.async {
                    self.questionNumber.text = "Q."+String(self.questionNum!)
                    self.questionLabel.text = (questionResults?[0].question)!
                }
                
                self.choiceArray = (questionResults?[0].incorrect_answers)!
                self.choiceArray!.append((questionResults?[0].correct_answer)!)
                self.choiceArray!.shuffle()
                
                DispatchQueue.main.async {
                    self.ans1.setTitle(self.choiceArray![0], for: .normal)
                    self.ans2.setTitle(self.choiceArray![1], for: .normal)
                    self.ans3.setTitle(self.choiceArray![2], for: .normal)
                    self.ans4.setTitle(self.choiceArray![3], for: .normal)
                }

            } else {
                print("error")
            }
        }
        task.resume()
        


    }
    
    
    func answerQuestion(ans: Int) {
        print(ans)
        print(self.questionNum!)
        if self.choiceArray![ans-1] == self.questions![self.questionNum!-1].correct_answer {
            print("correct")
            print(self.choiceArray![ans-1])
            print(self.questions![self.questionNum!-1].correct_answer)
            self.point = self.point! + 10
            DispatchQueue.main.async {
                self.pointNumbers.text = "Point:" + String(self.point!)
            }
            
        }
        else {
            print("incorrect")
            print(self.choiceArray![ans-1])
            print(self.questions![self.questionNum!].correct_answer)
        }
        print(self.choiceArray!)
        loadQuestion()
    }
    
    func loadQuestion() {
        let questionResults = self.questions

        self.choiceArray = []

        self.questionNum = self.questionNum! + 1
        
        DispatchQueue.main.async {
            self.questionNumber.text = "Q."+String(self.questionNum!)
            self.questionLabel.text = (questionResults?[self.questionNum!-1].question)!
        }
        

        
        self.choiceArray = (questionResults?[self.questionNum!-1].incorrect_answers)!
        self.choiceArray!.append((questionResults?[self.questionNum!-1].correct_answer)!)
        self.choiceArray!.shuffle()
        
        print(self.choiceArray!)
        
        if self.questionNum! < 20 {
            DispatchQueue.main.async {
                self.ans1.setTitle(self.choiceArray![0], for: .normal)
                self.ans2.setTitle(self.choiceArray![1], for: .normal)
                self.ans3.setTitle(self.choiceArray![2], for: .normal)
                self.ans4.setTitle(self.choiceArray![3], for: .normal)
            }

        } else {
            DispatchQueue.main.async(){
               
                let alertController = UIAlertController(title: "遊戲已結束", message: "這次共獲得：" + String(self.point!) + "分", preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "重玩一遍", style: .default, handler: {(
                    alert: UIAlertAction!) in
                    print("Retry")
                    self.questionNum = 0
                    self.point = 0
                    self.pointNumbers.text = "Point:" + String(self.point!)
                    self.loadQuestion()
                })
                
                let changeAction = UIAlertAction(title: "更換題目",style: .cancel, handler: {(
                    alert: UIAlertAction!) in
                    print("Change")
                    self.questionNum = 0
                    self.point = 0
                    self.pointNumbers.text = "Point:" + String(self.point!)
                    let url = URL(string: "https://opentdb.com/api.php?amount=20&type=multiple")!
                    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        if let data = data, let questionResults = try?
                            decoder.decode(QuestionResults.self, from: data)
                        {
                            self.questions = questionResults.results
                            
                        } else {
                            print("error")
                        }
                    }
                    task.resume()
                    self.loadQuestion()
                })
                alertController.addAction(changeAction)
                alertController.addAction(retryAction)
                self.present(alertController, animated: true, completion: nil)
            }//DispatchQueue
        }
        
    }
}

