//
//  ViewController.swift
//  Dife
//
//  Created by Difeng Chen on 3/12/18.
//  Copyright © 2018 Difeng Chen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import Firebase
import GoogleMobileAds
class homeViewController: UIViewController,GADBannerViewDelegate {
    @IBOutlet weak var myBanner: GADBannerView!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var ChoiceA: UIButton!
    @IBOutlet weak var ChoiceB: UIButton!
    @IBOutlet weak var ChoiceC: UIButton!
    @IBOutlet weak var ChoiceD: UIButton!
    @IBOutlet weak var expand: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    var ref: DatabaseReference!
    
    //value
    var titleValue = String()
    var choiceAValue = String()
    var choiceBValue = String()
    var choiceCValue = String()
    var choiceDValue = String()
    var categoryValue = String()
    var expandValue = String()
    var correctAnswerValue = String()
    var questionNumValue = Int()
    var correctBotton = UIButton()
    var userBotton = UIButton()
    
    //strings
    let questionsString = "Questions"
    let categoriesString = "Categories"
    let categoriesArray = ["Common Sense"]
    let questionOfCategoriesArray = [2]
    let titleString = "Title"
    let choiceAString = "ChoiceA"
    let choiceBString = "ChoiceB"
    let choiceCString = "ChoiceC"
    let choiceDString = "ChoiceD"
    let correctAnswerString = "Correct Answer"
    let expandString = "Expand"
    let pPLRightString = "PPLRight"
    let pPLWrongString = "PPLWrong"
    
    var questionArray = [Question]()
    let dateFormatter = DateFormatter()
    let todayDate = Date()
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        ref = Database.database().reference()
        
        //loadingview
        loadingView.isHidden = false
        loadingView.startAnimating()
        
        // botton corner
        ChoiceA.layer.cornerRadius = 15
        ChoiceB.layer.cornerRadius = 15
        ChoiceC.layer.cornerRadius = 15
        ChoiceD.layer.cornerRadius = 15
        
        //fetch data
        let questionRequest:NSFetchRequest<Question> = Question.fetchRequest()
        do{
            questionArray = try DatabaseController.getContext().fetch(questionRequest)
        }catch{
            print("ERROR")
        }
        
        //unsubscribe
        if(questionArray.count > 0){
            var hasQueToday = false
            for que in questionArray{
                if(compareDate(date1: que.questionDate!, date2: todayDate)){
                    hasQueToday = true
                }
            }
            if(hasQueToday){
                getTodaysData(date: todayDate)
                updateBottons(uBotton: userBotton, cBotton: correctBotton)
                
                self.loadingView.stopAnimating()
                self.loadingView.isHidden = true
            }else{
                updateViewAfterFetchingData()
            }
        }else {
            updateViewAfterFetchingData()
        }
        
        //banner ad
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID]
        myBanner.adUnitID = "ca-app-pub-6779325502552778/8034693229"
        myBanner.rootViewController = self
        myBanner.delegate = self
        myBanner.load(adRequest)
        
    }

    func updateViewAfterFetchingData(){
        fetchNumOfQuestionInCategory()
        fetchData {
            self.todayLabel.text = self.dateFormatter.string(from: Date())
            self.questionTitle.text = self.titleValue
            self.ChoiceA.setTitle(self.choiceAValue, for: .normal)
            self.ChoiceB.setTitle(self.choiceBValue, for: .normal)
            self.ChoiceC.setTitle(self.choiceCValue, for: .normal)
            self.ChoiceD.setTitle(self.choiceDValue, for: .normal)
            self.category.text = "(\(self.categoryValue))"
            self.expand.text = self.expandValue
            self.expand.frame.size.height = CGFloat(self.expand.numberOfLines * 17)
            self.loadingView.stopAnimating()
            self.loadingView.isHidden = true
            self.expand.isHidden = true
        }
    }
    
    func fetchData(_ completion: @escaping () -> Void) {
        ref.child(questionsString).child(categoriesString).child(categoryValue).child(String(questionNumValue)).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.titleValue = value?[self.titleString] as? String ?? ""
            self.choiceAValue = value?[self.choiceAString] as? String ?? ""
            self.choiceBValue = value?[self.choiceBString] as? String ?? ""
            self.choiceCValue = value?[self.choiceCString] as? String ?? ""
            self.choiceDValue = value?[self.choiceDString] as? String ?? ""
            self.expandValue = value?[self.expandString] as? String ?? ""
            self.correctAnswerValue = value?[self.correctAnswerString] as? String ?? ""
            completion()
        }
    }

    //get num of question in category
    var questionsInCategory = Int()
    func fetchNumOfQuestionInCategory(){
        var isCategoryFull = Bool()
        repeat{
            var countCategory = Int()
            var rand = Int(arc4random_uniform(UInt32(categoriesArray.count)))
            categoryValue = categoriesArray[rand]
            questionsInCategory = questionOfCategoriesArray[rand]
            for que in questionArray{
                if(que.category == categoryValue){
                    countCategory += 1
                }
            }
            if(countCategory == questionsInCategory){
                isCategoryFull = true
            }else{
                isCategoryFull = false
                var hasQuestion = false
                repeat{
                    hasQuestion = false
                    questionNumValue = Int(arc4random_uniform(UInt32(questionsInCategory)))
                    for que in questionArray{
                        if(que.questionNum == questionNumValue){
                            hasQuestion = true
                        }
                    }
                }while hasQuestion
            }
        }while isCategoryFull
    }
    
    @IBAction func ChoiceA(_ sender: Any) {
        saveCoreData(button: ChoiceA)
    }
    
    @IBAction func ChoiceB(_ sender: Any) {
        saveCoreData(button: ChoiceB)
    }
    
    @IBAction func ChoiceC(_ sender: Any) {
        saveCoreData(button: ChoiceC)
    }
    
    @IBAction func ChoiceD(_ sender: Any) {
        saveCoreData(button: ChoiceD)
    }
    
    //save data
    func saveCoreData(button:UIButton){
        let question:Question = NSEntityDescription.insertNewObject(forEntityName: "Question", into: DatabaseController.getContext()) as! Question
        if(questionArray.count == 0){
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(homeViewController.counterReview), userInfo: nil, repeats: false)
        }
        question.category = categoryValue
        question.choiceA = choiceAValue
        question.choiceB = choiceBValue
        question.choiceC = choiceCValue
        question.choiceD = choiceDValue
        question.correctAnswer = correctAnswerValue
        question.expand = expandValue
        question.questionDate = todayDate
        question.questionNum = Int16(questionNumValue)
        question.questionTitle = titleValue
        question.userAnswer = button.titleLabel?.text
        DatabaseController.saveContext()
        
        correctBotton = getUserBotton(UA: correctAnswerValue)
        updateBottons(uBotton: button, cBotton: correctBotton)
    }
 
    //counter for review
    @objc func counterReview(){
        let appDelegate = AppDelegate()
        appDelegate.requestReview()
    }
    //update Bottons
    func updateBottons(uBotton:UIButton,cBotton:UIButton){
        ChoiceA.backgroundColor = UIColor.gray
        ChoiceA.isEnabled = false
        ChoiceB.backgroundColor = UIColor.gray
        ChoiceB.isEnabled = false
        ChoiceC.backgroundColor = UIColor.gray
        ChoiceC.isEnabled = false
        ChoiceD.backgroundColor = UIColor.gray
        ChoiceD.isEnabled = false
        
        uBotton.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.5)
        cBotton.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 0.5)
        expand.isHidden = false
    }
    
    //get today's data
    func getTodaysData(date: Date) {
        for result in questionArray{
            if((compareDate(date1: result.questionDate!, date2: date))){
                questionTitle.text = result.questionTitle!
                ChoiceA.setTitle(result.choiceA!, for: .normal)
                ChoiceB.setTitle(result.choiceB!, for: .normal)
                ChoiceC.setTitle(result.choiceC!, for: .normal)
                ChoiceD.setTitle(result.choiceD!, for: .normal)
                expand.text = result.expand!
                category.text = "(" + result.category! + ")"
                todayLabel.text = dateFormatter.string(from: result.questionDate!)
                
                correctBotton = getCorBotton(CA: result.correctAnswer!)
                userBotton = getUserBotton(UA: result.userAnswer!)
            }
            
        }
    }
    
    //get correct button parameter CA(Correct Answer)
    func getCorBotton(CA:String)-> UIButton{
        if(CA == ChoiceA.titleLabel?.text){
            return ChoiceA
        }else if(CA == ChoiceB.titleLabel?.text){
            return ChoiceB
        }else if(CA == ChoiceC.titleLabel?.text){
            return ChoiceC
        }else{
            return ChoiceD
        }
    }
    
    //get User button parameter CA(User Answer)
    func getUserBotton(UA:String)-> UIButton{
        if(UA == ChoiceA.titleLabel?.text){
            return ChoiceA
        }else if(UA == ChoiceB.titleLabel?.text){
            return ChoiceB
        }else if(UA == ChoiceC.titleLabel?.text){
            return ChoiceC
        }else{
            return ChoiceD
        }
    }
    //compare dates
    func compareDate(date1:Date, date2:Date) -> Bool {
        let order = NSCalendar.current.compare(date1, to: date2,toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    @IBOutlet weak var countdownLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var counterView: UIView!
    @IBAction func counterViewBotton(_ sender: Any) {
        counterView.isHidden = true
        timer.invalidate()
        countdownLabel.text = ""
    }
    
    var timer = Timer()
    var seconds = Int()
    var secondesPerDay = 86400
    var differenceSeconds = Int()
    @IBAction func countViewDisplay(_ sender: Any) {
        counterView.isHidden = false
        countdownLoadingView.isHidden = false
        countdownLoadingView.startAnimating()
        seconds = Calendar.current.component(Calendar.Component.hour, from: Date())*3600+Calendar.current.component(Calendar.Component.minute, from: Date())*60+Calendar.current.component(Calendar.Component.second, from: Date())
        differenceSeconds = secondesPerDay - seconds - 1
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(homeViewController.counter), userInfo: nil, repeats: true)
        
    }
    @objc func counter(){
        countdownLabel.text = secondsToString(sec: differenceSeconds)
        countdownLoadingView.isHidden = true
        countdownLoadingView.stopAnimating()
        differenceSeconds -= 1
        if(differenceSeconds < 0 ){
            differenceSeconds += 86400
        }
    }
    
    func secondsToString(sec:Int) -> String {
        let hour = sec/3600
        let minute = (sec-hour*3600)/60
        let second = sec-hour*3600 - minute*60
        var hstr = String()
        var mstr = String()
        var sstr = String()
        if(hour<10){
            hstr = "0"+String(hour)
        }else{
            hstr = String(hour)
        }
        if(minute<10){
            mstr = "0"+String(minute)
        }else{
            mstr = String(minute)
        }
        if(second<10){
            sstr = "0"+String(second)
        }else{
            sstr = String(second)
        }
        return hstr+":"+mstr+":"+sstr
    }
    
}

