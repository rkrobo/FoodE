//
//  MyPhotoCollectionViewController.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-28.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class MyPhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate{
    
    
    var searchTerm : String = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    var error: NSError?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var itemsPerRow: CGFloat = 3
    var sectionInsets = UIEdgeInsets(top: 6.0, left: 5.3, bottom: 6.0, right: 5.3)
    var selectedIndexes   = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths : [IndexPath]!
    var updatedIndexPaths : [IndexPath]!
    
    @IBOutlet weak var searchTextHeader: UILabel!
    
    @IBOutlet weak var noPhotos: UILabel!
    
    var fetchRequest = NSFetchedResultsController<NSFetchRequestResult>()
   

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        self.downloadIndicator.isHidden = true
        
        loadCollection()
        
    }
    
    
    func fetchRestuarants() -> NSFetchedResultsController<NSFetchRequestResult>{
        
        downloadIndicator.isHidden = false
        
        downloadIndicator.startAnimating()
        
        let fetchedRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserPhotos")
        
        let sortDescriptor = NSSortDescriptor(key: "restaurantName", ascending: true)
        fetchedRequest.sortDescriptors = [sortDescriptor]
       if(searchTerm != ""){
            fetchedRequest.predicate = NSPredicate(format: "restaurantName == %@", searchTerm)
        }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }
    
    
    func loadCollection() {
        
        
        fetchRequest = fetchRestuarants()
        
        
        do {
            
            try fetchRequest.performFetch()
            
            if(error == nil || fetchRequest.fetchedObjects?.count != 0) {
                
                noPhotos.isHidden = true
            }
            
        }
            
        catch let error1 as NSError {
            error = error1
            
            let alert = UIAlertController(title: "Error Message", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
         
            print(error ?? 0)
        }
        
        downloadIndicator.stopAnimating()
        
        self.downloadIndicator.isHidden = true
        
        collectionView.reloadData()
        
    }
    
    
    @IBAction func doneAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchRequest.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionCell", for: indexPath) as! MyPhotoCollectionViewCell
        
        cell.imageCell.backgroundColor = UIColor.black
        
        let photo = fetchRequest.object(at: indexPath) as! UserPhotos
        
        DispatchQueue.main.async(execute: {
            if(photo.imageData != nil ){
                cell.imageCell.image = UIImage(data: photo.imageData! as Data)
            }
        })
        
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchRequest.sections {
            return sections.count
            
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = fetchRequest.object(at: indexPath) as! UserPhotos
        let alert = UIAlertController(title: "Delete Photo", message: "Do you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
            self.sharedContext.delete(photo)
            CoreDataStack.sharedInstance().save()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths  = [IndexPath]()
        updatedIndexPaths  = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //print("searchText \(searchText)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchTerm = searchBar.text!
        
        searchTextHeader.text = searchTerm
        
        loadCollection()
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    
    @IBAction func clearAction(_ sender: Any) {
        
        searchTextHeader.text = ""
        
        searchTerm = ""
        
        searchBar.text = ""
        
        loadCollection()
    }
    
    @IBAction func performSegueToReturnBack()  {
        
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
        
    }
}
    extension MyPhotoCollectionViewController : UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat{
            return sectionInsets.left
        }

}
