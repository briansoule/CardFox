//
//  CardCaptureViewController.h
//  FollowUp
//
//  Created by Brian Soule on 10/19/13.
//  Copyright (c) 2013 Soule Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCaptureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    id __unsafe_unretained delegate;
}

@property (unsafe_unretained) id delegate;

@property (nonatomic, retain) UIImage * savedImage;



- (IBAction)sendButtonTapped:(id)sender;

@end
