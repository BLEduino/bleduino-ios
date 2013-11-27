//
//  ModuleCollectionViewCell.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModuleCollectionViewCell : UICollectionViewCell
@property (weak) IBOutlet UIButton *moduleIcon;
@property (weak) IBOutlet UILabel *moduleName;
@end
