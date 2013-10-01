//
//  ModulesCollectionViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardModuleTableViewController.h"

@interface ModulesCollectionViewController : UICollectionViewController
<
UICollectionViewDataSource,
UICollectionViewDelegate,
KeyboardModuleTableViewControllerDelegate
>
@property (nonatomic, strong) NSArray *modules;
@property (nonatomic, strong) NSArray *modulesImages;
@end
