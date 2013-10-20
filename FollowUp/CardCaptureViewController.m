//
//  CardCaptureViewController.m
//  FollowUp
//
//  Created by Brian Soule on 10/19/13.
//  Copyright (c) 2013 Soule Mobile. All rights reserved.
//

#import "CardCaptureViewController.h"
#import "AFNetworking.h"
#import "MasterViewController.h"
#import "TemplateChooserViewController.h"

@interface CardCaptureViewController ()

@end

@implementation CardCaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera Presentation


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        self.savedImage = imageToSave;
        
    }
    
    // Handle a movie capture
    if ([mediaType isEqualToString:@"public.movie"]) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    
    [self dismissModalViewControllerAnimated: YES];
}

- (IBAction)templateChooser:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    TemplateChooserViewController *templateChooserViewController = (TemplateChooserViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TemplateChooserViewIdentifier"];
    
    templateChooserViewController.delegate = self;
    [self.navigationController pushViewController:templateChooserViewController animated:YES];
}

- (IBAction)sendButtonTapped:(id)sender {
    [self uploadImage];
}

- (void)uploadImage {
    NSData *imageData = UIImageJPEGRepresentation(self.savedImage, 0.9);
    [imageData writeToURL:[NSURL fileURLWithPath:@"file://documents/image.jpeg"] atomically:YES];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://cardfox.herokuapp.com/image"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURL *filePath = [NSURL fileURLWithPath:@"file://documents/image.jpeg"];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.delegate insertNewObject:nil];
        }
    }];
    [uploadTask resume];
    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    MasterViewController *rootViewController = (MasterViewController *)window.rootViewController;
//    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate insertNewObject:nil];
}
@end
