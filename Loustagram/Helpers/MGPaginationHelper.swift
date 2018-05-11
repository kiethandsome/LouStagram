//
//  MGPaginationHelper.swift
//  Loustagram
//
//  Created by Kiet on 12/18/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit

protocol MGKeyed {
    var key: String? { get set }
}

class MGPaginationHelper<T: MGKeyed> {
    

    enum MGPaginationState {
        case initial
        case ready
        case loading
        case end
    }
    
    // MARK: - Properties
    
    let pageSize: UInt
    let serviceMethod: (UInt, String?, @escaping (([T]) -> Void)) -> Void
    var state: MGPaginationState = .initial
    var lastObjectKey: String?
    
    // MARK: - Init
    
    init(pageSize: UInt = 3, serviceMethod: @escaping (UInt, String?, @escaping (([T]) -> Void)) -> Void) {
        self.pageSize = pageSize
        self.serviceMethod = serviceMethod
    }
    
    // 1. Notice our completion parameter type. We use our generic type to enforce that we return type T
    
    func paginate(completion: @escaping ([T]) -> Void) {
        
        // 2. We switch on our helper's state to determine the behavior of our helper when paginate(completion:) is called.
        switch state {
            
        // 3. For our initial state, we make sure that the lastObjectKey is nil use the fallthrough keyword to execute the ready case below.
        case .initial:
            lastObjectKey = nil
            fallthrough
            
        // 4. For our ready state, we make sure to change the state to loading and execute our service method to return the paginated data.
        case .ready:
            state = .loading
            serviceMethod(pageSize, lastObjectKey) { [unowned self] (objects: [T]) in
                
                // 5. We use the defer keyword to make sure the following code is executed whenever the closure returns. This is helpful for removing duplicate code.
                defer {
                    
                    // 6. If the returned last returned object has a key value, we store that in lastObjectKey to use as a future offset for paginating.
                    if let lastObjectKey = objects.last?.key {
                        self.lastObjectKey = lastObjectKey
                    }
                    
                    // 7. We determine if we've paginated through all content because if the number of objects returned is less than the page size, we know that we're only the last page of objects.
                    self.state = objects.count < Int(self.pageSize) ? .end : .ready
                }
                
                // 8. If lastObjectKey of the helper doesn't exist, we know that it's the first page of data so we return the data as is.
                guard let _ = self.lastObjectKey else {
                    return completion(objects)
                }
                
                // 9. Due to implementation details of Firebase, whenever we page with the lastObjectKey, the previous object from the last page is returned. Here we need to drop the first object which will be a duplicate post in our timeline. This happens whenever we're no longer on the first page.
                let newObjects = Array(objects.dropFirst())
                completion(newObjects)
            }
            
        // 10.
        case .loading, .end:
            return
        }
    }
    
    func reloadData(completion: @escaping ([T]) -> Void) {
        state = .initial
        
        paginate(completion: completion)
    }
}







