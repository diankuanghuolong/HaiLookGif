//
//  ShowAllPhotos.m
//  HaiLookGif
//
//  Created by Ios_Developer on 2018/1/18.
//  Copyright © 2018年 hai. All rights reserved.
//

#import "ShowAllPhotosVC.h"
#import <WebKit/WebKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

/*
 定义宽高、安全距离
 */

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SafeAreaTopHeight (SCREEN_HEIGHT == 812.0 ? 88 : 64)    //-----顶部安全距离
#define SafeAreaBottomHeight (SCREEN_HEIGHT == 812.0 ? 34 : 0)  //-----底部安全距离

@interface ShowAllPhotosVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIWebViewDelegate,UIScrollViewDelegate>
{
    ALAssetsLibrary *_assetsLibrary;
    NSMutableArray *_albumsArray;//相册组数组
    NSMutableArray *_imagesAssetArray;//相片数组
    
    UIWebView *_webView;
}
@property (nonatomic ,strong)UIScrollView *sv;
@property (nonatomic ,strong)UIPageControl *pageC;
@end

@implementation ShowAllPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"查看所有图片";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getGroupArray];//获取所有图片
    [self.view addSubview:self.sv];
}

#pragma mark ===== laizyLoad  =====
-(UIScrollView *)sv
{
    if (!_sv)
    {
        _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight + 20, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - SafeAreaBottomHeight - 40)];
        _sv.delegate = self;
        _sv.pagingEnabled = YES;
        _sv.showsHorizontalScrollIndicator = NO;
    }
    return _sv;
}
-(void)updateSV
{
    _sv.contentSize = CGSizeMake(SCREEN_WIDTH * _imagesAssetArray.count, 0);
    CGFloat x = 0;
    for (int i = 0; i < _imagesAssetArray.count; i ++)
    {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(x, 0, _sv.frame.size.width, _sv.frame.size.height)];
        webView.delegate = self;
        
        //清楚背景色
        webView.backgroundColor = [UIColor clearColor];
        webView.scrollView.backgroundColor = [UIColor clearColor];
        
        //使web和图片大小适配
        [webView setOpaque:NO];//边界不透明视图填充设为NO，否则[UIColor clearColor];无效
        webView.scalesPageToFit = YES;
        webView.scrollView.scrollEnabled = NO;
        
        [_sv addSubview:webView];
        _webView = webView;
        
        NSURL *url = [[_imagesAssetArray[i] defaultRepresentation] url];
//        NSLog(@"url == %@",url);
        [self getGifData:url forWeb:webView];//获取图片并加载到web上，然后将web加到_sv上
        
        x += SCREEN_WIDTH;
    }
}
#pragma mark ===== getDatas  =====
-(void)getGroupArray
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _albumsArray = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{

        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                if (group.numberOfAssets > 0) {
                    // 把相册储存到数组中，方便后面展示相册时使用
                    [_albumsArray addObject:group];
//                    NSLog(@"_albumsArray == %@",_albumsArray);
                    
                    [self getImgArr];
                }
            } else {
                if ([_albumsArray count] > 0) {
                    // 把所有的相册储存完毕，可以展示相册列表
                } else {
                    // 没有任何有资源的相册，输出提示
                    NSLog(@"没有相册内容");
                }
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Asset group not found!\n");
        }];
        
    });

}
-(void)getImgArr
{
    _imagesAssetArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _albumsArray.count; i ++)
    {
        ALAssetsGroup *group = _albumsArray[i];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [_imagesAssetArray addObject:result];
//                NSLog(@"_imagesAssetArray == %@",_imagesAssetArray);
            } else {
                // result 为 nil，即遍历相片或视频完毕，可以展示资源列表
            }
        }];
    }
    
    [self updateSV];
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
#pragma mark ===== tool =====
-(void)getGifData:(NSURL *)url forWeb:(UIWebView *)webView//获取图片并写入文件中
{
    NSURL *imageRefURL = url;
    
    void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
        
        if (asset != nil) {
            
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc(rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            
            if (imageData)
            {
                if (@available(iOS 9.0, *)) {
                    
                    [webView loadData:imageData MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
                }
            }
        }
        else {
            
            //未获取到gif
            NSLog(@"未获取到gif");
        }
    };
    
    [_assetsLibrary assetForURL:imageRefURL
                   resultBlock:ALAssetsLibraryAssetForURLResultBlock
                  failureBlock:^(NSError *error){
                  }];
}
@end
