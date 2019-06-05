//
//  DownloadCollectionViewController.swift
//  Viburnum
//
//  Created by Maksim Sugak on 14/04/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import UIKit

class DownloadCollectionViewController: UIViewController {
  // Variables:
  let itemsPerRow = 3 // for collection layout
  let collectionViewSpace: CGFloat = 10 //for collection layout: space btwn cells
  let perPage = 9 // loading per page
  var page = 1 // starting page
  var loadURL = "" // loading url var
  let appKey = "12166192-4c9c421077c6998eccbae7630" // app token
  private var profileImages = [ProfileImage]()  // model array
  
  // Outlets:
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  // Actions:
  @IBAction func backButton(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }

    override func viewDidLoad() {
        super.viewDidLoad()
      // Calling for initial images fetching for page 1:
      fetchLatestImages(for: page)
    }
  
  func fetchLatestImages(for page: Int) {
    // Spinner starting:
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
    
    // URL preparation:
    loadURL = "https://pixabay.com/api/?key=\(appKey)&q=portrait&image_type=photo&pretty=true&per_page=\(perPage)&page=\(page)"
    guard let url = URL(string: loadURL) else { return }
    
    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      
      // Catching error:
      if let error = error {
        print(response ?? "Null response")
        print(error)
        return
      }
      
      // Parse JSON data:
      if let data = data {
        let newElements = self.parseJsonData(data: data)
        self.profileImages += newElements
        
        DispatchQueue.main.async {
          self.collectionView.reloadData()
          // Spinner stopping:
          self.activityIndicator.isHidden = true
          self.activityIndicator.stopAnimating()
        }
      }
    })
    task.resume()
  }
  
  func parseJsonData(data: Data) -> [ProfileImage] {
    var profileImages = [ProfileImage]()
    do {
      let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
      
      // Getting 
      let jsonImages = jsonResult?["hits"] as? [AnyObject]
      for json in jsonImages! {
        var profileImage = ProfileImage()
        profileImage.webformatURL = (json["webformatURL"] as? String)!
        profileImage.previewURL = (json["previewURL"] as? String)!
        profileImages.append(profileImage)
      }
    } catch {
      print(error)
      }
      return profileImages
  }
}

// Extention for Collection data source:
extension DownloadCollectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return profileImages.count
  }
  
  // Making cell:
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell",
                                                        for: indexPath) as?
      DownloadCollectionCellCollectionViewCell else { return UICollectionViewCell() }
    
    // Loading image by URL:
    DispatchQueue.main.async {
      cell.downloadedImageView.load(url: URL(string: self.profileImages[indexPath.row].previewURL)!)
      cell.wasLoaded = true
    }
    
    // Loading the next page when previous loading was finished:
    if indexPath.row == profileImages.count - 1 {
      self.page += 1
      print("New page ------------\(page)")
      fetchLatestImages(for: page)
    }
    return cell
  }
  
  // Call segue by cell tap:
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? DownloadCollectionCellCollectionViewCell else { return }
    
    // Making segue only if image was loaded:
    if cell.wasLoaded {
            performSegue(withIdentifier: "backToProfile", sender: cell)
    }
  }

  // Segue to Profile:
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "backToProfile" {
      guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
        let profileViewController = segue.destination as? ProfileViewController else { return }
      DispatchQueue.main.async {
        profileViewController.photoImageView.load(url: URL(string: self.profileImages[indexPath.row].webformatURL)!)
      }
      profileViewController.saveButton.isEnabled = true
      profileViewController.saveButton.setTitleColor(UIColor.black, for: .normal)
    }
  }
}

// Extention for collection view layout:
extension DownloadCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let paddingSpace = collectionViewSpace * CGFloat(itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / CGFloat(itemsPerRow)
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: collectionViewSpace, left: collectionViewSpace, bottom: collectionViewSpace, right: collectionViewSpace)
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return collectionViewSpace
  }
}

// Extention to load image from URL:
extension UIImageView {
  func load(url: URL) {
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url) {
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self?.image = image
          }
        }
      }
    }
  }
}
