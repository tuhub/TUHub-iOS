//
//  AddListingTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/1/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

private let textFieldCellID = "textFieldCell"
private let textViewCellID = "textViewCell"
private let addImageCellID = "addImageCell"
private let categoryCellID = "categoryCell"
private let rightDetailCellID = "rightDetailCell"
private let pickerCellID = "pickerCell"

class AddListingTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var categoryPicker: UIPickerView!
    var dummyTextField: UITextField!
    
    var selectedKind: Listing.Kind?
    var displayingPicker = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow table view to automatically determine cell height based on contents
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        debugPrint()
        
//        dummyTextField = UITextField()
//        dummyTextField.isHidden = true
//        view.addSubview(dummyTextField)
        
//        setUpCategoryPicker()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case 0:
            return "Contact Information"
        case 1:
            return "Listing Information"
        case 2:
            return "Add Image"
            
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return 2
        case 1:
            return displayingPicker ? 5 : 4
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellID, for: indexPath)
                (cell as! TextFieldTableViewCell).textField.placeholder = "Email"
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellID, for: indexPath)
                (cell as! TextFieldTableViewCell).textField.placeholder = "Phone Number (Optional)"
            default:
                log.error("Invalid row")
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellID, for: indexPath)
                (cell as! TextFieldTableViewCell).textField.placeholder = "Title"
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellID, for: indexPath)
                (cell as! TextFieldTableViewCell).textField.placeholder = "Price"
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: rightDetailCellID, for: indexPath)
                cell.textLabel?.text = "Category"
                cell.detailTextLabel?.text =  selectedKind?.rawValue ?? "Select"
//                cell = tableView.dequeueReusableCell(withIdentifier: categoryCellID, for: indexPath)
//                let categoryButtonCell = cell as! CategoryTableViewCell
//                categoryButtonCell.categoryButton.addTarget(self, action: #selector(didPressCategory), for: .touchUpInside)
                
            case 3:
                if displayingPicker {
                    cell = tableView.dequeueReusableCell(withIdentifier: pickerCellID, for: indexPath)
                    let picker = (cell as? PickerTableViewCell)?.picker
                    picker?.dataSource = self
                    picker?.delegate = self
                } else {
                    fallthrough
                }
            case 4:
                cell = tableView.dequeueReusableCell(withIdentifier: textViewCellID, for: indexPath)
                (cell as! TextViewTableViewCell).textView.text = "Add a description"
            default:
                log.error("Invalid row")
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: addImageCellID, for: indexPath)
            let imageCell = cell as! ImageTableViewCell
            imageCell.takePicture.addTarget(self, action: #selector(didPressTakePicture), for: .touchUpInside)
            imageCell.importPicture.addTarget(self, action: #selector(didPressImportPicture), for: .touchUpInside)
        default:
            log.error("Invalid section")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 2 {
            displayingPicker = !displayingPicker
            let pickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if displayingPicker {
                tableView.insertRows(at: [pickerIndexPath], with: .fade)
            } else {
                tableView.deleteRows(at: [pickerIndexPath], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    // MARK: Camera
    
    func didPressTakePicture() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            debugPrint("Error: Can not access camera")
        }
        
    }
    
    func didPressImportPicture() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            debugPrint("Error: Can not load pictures")
        }
        
    }
    
    // TODO: Add image view to display selected picture in image view or get the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // TODO:
//            myImageView.image = image
//            myImageView.contentMode = .scaleAspectFit
//            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Category picker
//    func setUpCategoryPicker() {
//        
//        if categoryPicker == nil {
//            // Set up date picker as input view
//            let categoryPicker = UIPickerView()
//            categoryPicker.dataSource = self
//            categoryPicker.delegate = self
//            self.categoryPicker = categoryPicker
//        }
//        dummyTextField.inputView = categoryPicker
//        
//        // Set up toolbar with today button and done button as accessory view
//        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressCategoryPickerDoneButton(_:)))
//        doneButton.tintColor = UIColor.cherry
//        toolbar.setItems([flexSpace, doneButton], animated: false)
//        toolbar.sizeToFit()
//        dummyTextField.inputAccessoryView = toolbar
//    }
//    
//    func didPressCategory(){
//        dummyTextField.becomeFirstResponder()
//    }
    
//    func didPressCategoryPickerDoneButton(_ sender: UIBarButtonItem) {
//        dummyTextField.resignFirstResponder()
//        
//        let row = categoryPicker.selectedRow(inComponent: 0)
//        let categoryButtonTitle = Categories.allValues[row].name
//        debugPrint(categoryButtonTitle)
//
//    }
//    
//    
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UIPickerViewDataSource
extension AddListingTableViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Listing.Kind.all.count
    }
    
}

// MARK: - UIPickerViewDelegate
extension AddListingTableViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Listing.Kind.all[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedKind = Listing.Kind.all[row]
        tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
    }
    
}
