//
//  ViewController.m
//  HaiLookGif
//
//  Created by Ios_Developer on 2018/1/11.
//  Copyright © 2018年 hai. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShowAllPhotosVC.h"
/*
 定义宽高、安全距离
 */

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SafeAreaTopHeight (SCREEN_HEIGHT == 812.0 ? 88 : 64)    //-----顶部安全距离
#define SafeAreaBottomHeight (SCREEN_HEIGHT == 812.0 ? 34 : 0)  //-----底部安全距离

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIWebViewDelegate>

@property (nonatomic ,strong)UIImageView *bgIV;
@property (nonatomic ,strong)UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"浏览相册中GIF";
    
    [self.view addSubview:self.bgIV];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [leftBtn setTitle:@"打开相册" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [leftBtn addTarget:self action:@selector(openPhotoShop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBbi = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftBbi;
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    [rightBtn setTitle:@"显示所有相片" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [rightBtn addTarget:self action:@selector(showAllPhotos:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBbi = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.navigationItem.rightBarButtonItem = rightBbi;
    
    //kvo
    [_bgIV addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}
#pragma mark ===== laizyLoad  =====
-(UIImageView *)bgIV
{
    if (!_bgIV)
    {
        _bgIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight + 20, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight - 40)];
        _bgIV.image = [UIImage imageNamed:@"openPhothShop"];
        _bgIV.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoShop)];
        [_bgIV addGestureRecognizer:tap];
        
    }
    return _bgIV;
}
-(UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight + 20, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight - 40)];
        _webView.delegate = self;
        
        //清楚背景色
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        
        //使web和图片大小适配
        [_webView setOpaque:NO];//边界不透明视图填充设为NO，否则[UIColor clearColor];无效
        _webView.scalesPageToFit = YES;
        _webView.scrollView.scrollEnabled = NO;
        
        [self.view addSubview:_webView];
        
        //隐藏背景图 bgIV和webView两者存一，webView没有bgIV宽，防止两图同时显示的尴尬
        _bgIV.hidden = YES;
    }
    return _webView;
}
#pragma mark  ===== action =====
-(void)showAllPhotos:(id)sender
{
    ShowAllPhotosVC *showAllPhotosVC = [ShowAllPhotosVC new];
    [self.navigationController pushViewController:showAllPhotosVC animated:YES];
}
-(void)openPhotoShop
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
#pragma mark =====  pickerDelegate  =====
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage * editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

     [self getGifData:info];//-----获取图片并写入文件中
    
    [self dismissViewControllerAnimated:YES completion:^() {
        
        NSData *imgData = [NSData dataWithContentsOfFile:[self getImgDataPath]];
        
        if (imgData)
        {
            if (@available(iOS 9.0, *)) {
                
                [self.webView loadData:imgData MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
            }
        }
        
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
#pragma mark ===== webDelegate =====
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //初始化缩放值
    webView.scrollView.minimumZoomScale = 1;
    webView.scrollView.maximumZoomScale = 1;
    webView.scrollView.zoomScale = 1;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //使web和图片大小适配
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize webSize = _webView.bounds.size;

    float w = webSize.width / contentSize.width , h = webSize.height / contentSize.height,zoom;
    
    zoom = contentSize.width < contentSize.height ? w : h;
    webView.scrollView.minimumZoomScale = zoom;
    webView.scrollView.maximumZoomScale = zoom;
    webView.scrollView.zoomScale = zoom;
}
#pragma mark ===== kvo 监听bgIV是否显示 =====
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"])
    {
        BOOL bgIsHidden = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        if (bgIsHidden)
        {
            _webView.hidden = NO;
        }
        else
        {
            _webView.hidden = YES;
        }
    }
}
#pragma mark ===== tool =====
-(void)getGifData:(NSDictionary *)info//获取图片并写入文件中
{
    NSURL *imageRefURL = [info valueForKey:UIImagePickerControllerReferenceURL];

    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    __block NSData *imgData = nil;
    void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
        
        if (asset != nil) {
            
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc(rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            
            imgData = imageData;
            [imgData writeToFile:[self getImgDataPath] atomically:YES];
        }
        else {
            
            //未获取到gif
            NSLog(@"未获取到gif");
        }
    };
    
    [assetsLibrary assetForURL:imageRefURL
                  resultBlock:ALAssetsLibraryAssetForURLResultBlock
                 failureBlock:^(NSError *error){
                 }];
}
-(NSString *)getImgDataPath//创建并获取图片data路径
{
    NSString *imgPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/imgData"];
    NSLog(@"imgPath== %@",imgPath);
    return imgPath;
}

-(void)dealloc
{
    [_bgIV removeObserver:self forKeyPath:@"hidden"];
}
@end
