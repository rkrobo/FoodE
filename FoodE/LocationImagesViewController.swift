//
//  LocationImagesViewController.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-03-27.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class LocationImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{

    var pin: LocationFood!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var notAvaliable: UILabel!
    
    var edit = false
    
    var itemsPerRow: CGFloat = 3
    var sectionInsets = UIEdgeInsets(top: 6.0, left: 5.3, bottom: 6.0, right: 5.3)
    var isDownloading = false
    var selectedIndexes   = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths : [IndexPath]!
    var updatedIndexPaths : [IndexPath]!

    
    override func viewDidLoad() {
        
        self.notAvaliable.isHidden = true
        
        self.downloadIndicator.isHidden = true
  
        let span = MKCoordinateSpanMake(0.5, 0.5)
        
        let region =  MKCoordinateRegion(center: pin.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print(error ?? 0)
        }
        
        if error != nil  || fetchedResultsController.fetchedObjects?.count == 0 {
            loadCollection()
            CoreDataStack.sharedInstance().save()
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        fetchRequest.predicate = NSPredicate(format: "locationFood == %@", self.pin)
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    
    func getPhotosForPin(_ pin: LocationFood, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        downloadIndicator.isHidden = false
        
        downloadIndicator.startAnimating()
            
        FlickrClient.sharedInstance.getPhotosForPin(pin) { (success, errorString) in
            
            CoreDataStack.sharedInstance().save()
            
            completionHandler(success, errorString)
            
        }
    }
    
    
    func loadCollection(){
        
        
        for photo in fetchedResultsController.fetchedObjects as! [Photos] {
            sharedContext.delete(photo)
        }
        
        getPhotosForPin(pin) { (success, errorString) in

           self.pinFinishedDownload()
            
            if success == false {
                print("An error occurred, success is false")
                return
            }
        }
    }
    
  func pinFinishedDownload() {
        
        self.newCollectionButton.isEnabled = true
        
        downloadIndicator.stopAnimating()
        
        self.downloadIndicator.isHidden = true
        
        if(self.fetchedResultsController.fetchedObjects!.count == 0 ){
            self.collectionView.isHidden = true
            self.newCollectionButton.isEnabled = false
            self.notAvaliable.isHidden = false
        }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.cellImage.backgroundColor = UIColor.black
        
        let photo = fetchedResultsController.object(at: indexPath) as! Photos
   
        DispatchQueue.main.async(execute: {
            
            if(photo.imageData != nil ){
               
                cell.cellImage.image = UIImage(data: photo.imageData! as Data)
            }
        })
        
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
      if(edit == true) {
        
            let photo = fetchedResultsController.object(at: indexPath) as! Photos
            let alert = UIAlertController(title: "Delete Photo", message: "Do you want to delete this photo?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
            }))
        
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
            self.sharedContext.delete(photo)
            CoreDataStack.sharedInstance().save()
            self.edit = false
            self.editButton.isEnabled = true
            }))
            present(alert, animated: true, completion: nil)
        
            }

        else {
            let foodPhoto = fetchedResultsController.object(at: indexPath) as! Photos
            let imageController = self.storyboard!.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
            imageController.foodPhoto = foodPhoto
            self.navigationController!.pushViewController(imageController, animated: true)
        }
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
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    
    
    @IBAction func editPressed(_ sender: Any) {
        
        edit = true
        self.editButton.isEnabled = false
    }
    
    
    @IBAction func reloadCollection(_ sender: Any) {
        
        DispatchQueue.main.async{
            
            self.loadCollection()
            
        }
            self.downloadIndicator.stopAnimating()
        
            self.downloadIndicator.isHidden = true
    }
    
}

extension LocationImagesViewController{
    
  @IBAction func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension LocationImagesViewController : UICollectionViewDelegateFlowLayout {
    
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

