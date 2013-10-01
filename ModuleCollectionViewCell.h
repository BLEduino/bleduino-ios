//
//  ModuleCollectionViewCell.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModuleCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *moduleImage;
@property (strong, nonatomic) IBOutlet UILabel *moduleName;

@end
