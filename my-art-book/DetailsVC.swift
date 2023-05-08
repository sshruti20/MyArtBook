//
//  DetailsVC.swift
//  my-art-book
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage)))
        
        // Core Data
        if chosenPainting != "" {
            //print("chosen painting ID is " + (chosenPaintingId?.uuidString ?? ""))
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = chosenPaintingId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id=%@", idString)
            
            do {
                let results = try context.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String {
                        nameText.text = name
                    }
                    if let artist = result.value(forKey: "artist") as? String {
                        artistText.text = artist
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearText.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        imageView.image = UIImage(data: imageData)
                    }
                }

            } catch {
                print("Error")
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    

}
