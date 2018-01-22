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
    
    NSInteger _leftCurIndex;//左边webView当前的序号
    NSInteger _centerCurIndex;//中间webView当前的序号
    NSInteger _rightCurIndex;//右边webView当前的序号
    
    UIView *tempView;//web截图
}
@property (nonatomic ,strong)UIScrollView *sv;
@property (nonatomic ,strong)UIPageControl *pageC;

@property (nonatomic ,strong)UIWebView *leftWebView;
@property (nonatomic ,strong)UIWebView *centerWebView;
@property (nonatomic ,strong)UIWebView *rightWebView;
@end

@implementation ShowAllPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"查看所有图片";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(@available(iOS 11.0, *))
    {
        _sv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    /*
        追求完美的用户体验，是我们的职业素养。每一个功能都可以通过不同的方法实现，但是，程序员的职责是寻找最优雅的一种。
        如果说，教育的目的，当是传递生命的气息。
        那么，编程的目的，当是灌注心灵的诗句。
     
        [self getGroupArray];//获取所有图片------这里只为效果，实际中，获取图片当在进入此页面前就完成，避免用户进入当前页面的等待时间。
     */
    [self getGroupArray];//获取所有图片
    [self.view addSubview:self.sv];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
#pragma mark ===== laizyLoad  =====
-(UIScrollView *)sv
{
    if (!_sv)
    {
        _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight)];
        _sv.delegate = self;
        _sv.pagingEnabled = YES;
        _sv.showsHorizontalScrollIndicator = NO;
        _sv.contentSize = CGSizeMake(SCREEN_WIDTH * 3, 0);
        _sv.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    }
    return _sv;
}
-(UIWebView *)leftWebView
{
    if (!_leftWebView)
    {
        _leftWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, _sv.frame.size.width, _sv.frame.size.height)];
        _leftWebView.delegate = self;
        
        //清除背景色
        _leftWebView.backgroundColor = [UIColor clearColor];
        _leftWebView.scrollView.backgroundColor = [UIColor clearColor];
        
        //使web和图片大小适配
        [_leftWebView setOpaque:NO];//边界不透明视图填充设为NO，否则[UIColor clearColor];无效
        _leftWebView.scalesPageToFit = YES;
        _leftWebView.scrollView.scrollEnabled = NO;
        _leftWebView.scrollView.userInteractionEnabled = NO;
    }
    return  _leftWebView;
}
-(UIWebView *)centerWebView
{
    if (!_centerWebView)
    {
        _centerWebView = [[UIWebView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, _sv.frame.size.width, _sv.frame.size.height)];
        _centerWebView.delegate = self;
        
        //清除背景色
        _centerWebView.backgroundColor = [UIColor clearColor];
        _centerWebView.scrollView.backgroundColor = [UIColor clearColor];
        
        //使web和图片大小适配
        [_centerWebView setOpaque:NO];//边界不透明视图填充设为NO，否则[UIColor clearColor];无效
        _centerWebView.scalesPageToFit = YES;
        _centerWebView.scrollView.scrollEnabled = NO;
        
        UIView * browserView = _centerWebView.scrollView.subviews[0];
        browserView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickAction:)];
        [browserView addGestureRecognizer:tap];
        
    }
    return _centerWebView;
}
-(UIWebView *)rightWebView
{
    if (!_rightWebView)
    {
        _rightWebView = [[UIWebView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, _sv.frame.size.width, _sv.frame.size.height)];
        _rightWebView.delegate = self;
        
        //清除背景色
        _rightWebView.backgroundColor = [UIColor clearColor];
        _rightWebView.scrollView.backgroundColor = [UIColor clearColor];
        
        //使web和图片大小适配
        [_rightWebView setOpaque:NO];//边界不透明视图填充设为NO，否则[UIColor clearColor];无效
        _rightWebView.scalesPageToFit = YES;
        _rightWebView.scrollView.scrollEnabled = NO;
        _rightWebView.scrollView.userInteractionEnabled = NO;
    }
    return _rightWebView;
}
#pragma mark ===== action  =====
-(void)updateSV
{
    //默认第_imagesAssetArray.count-1个
    _leftCurIndex = _imagesAssetArray.count - 1;
    //默认第0个
    _centerCurIndex=0;
    //默认第1个
    _rightCurIndex=1;
    
    //左边的webView
    [_sv addSubview:self.leftWebView];
    
    //中间的webView
    [_sv addSubview:self.centerWebView];
    
    //右边的webView
    [_sv addSubview:self.rightWebView];
    
    ALAssetRepresentation *representation = [_imagesAssetArray[_centerCurIndex] defaultRepresentation];
    NSURL *photoUrl = [representation url];
    //        NSLog(@"url == %@",url);
    [self getGifData:photoUrl forWeb:_centerWebView];//获取图片并加载到web上
}
-(void)didClickAction:(id)sender
{
    NSLog(@"click");
}
#pragma mark ===== getDatas  =====
-(void)getGroupArray
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _albumsArray = [[NSMutableArray alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            //只读图片
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
                NSLog(@"_imagesAssetArray == %@",_imagesAssetArray);
            } else {
                // result 为 nil，即遍历相片或视频完毕，可以展示资源列表
            }
        }];
    }
    
    [self updateSV];
}
#pragma mark ===== scrollviewDelegate  =====
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    //图片向左滑动，展示下一张图片
    if (offsetX>SCREEN_WIDTH) {
        _leftCurIndex++;
        _centerCurIndex++;
        _rightCurIndex++;
        if (_leftCurIndex>_imagesAssetArray.count-1) {
            _leftCurIndex=0;
        }
        if (_centerCurIndex>_imagesAssetArray.count-1) {
            _centerCurIndex=0;
        }
        if (_rightCurIndex>_imagesAssetArray.count-1) {
            _rightCurIndex=0;
        }
        
        //切换左，中，右三个位置上面的图片
        NSURL *url_left = [[_imagesAssetArray[_leftCurIndex] defaultRepresentation] url];
        [self getGifData:url_left forWeb:_leftWebView];//获取图片并加载到web上
        
        NSURL *url_center = [[_imagesAssetArray[_centerCurIndex] defaultRepresentation] url];
        [self getGifData:url_center forWeb:_centerWebView];//获取图片并加载到web上
        
        NSURL *url_right = [[_imagesAssetArray[_rightCurIndex] defaultRepresentation] url];
        [self getGifData:url_right forWeb:_rightWebView];//获取图片并加载到web上
        
        //图片向右滑动，展示上一张图片
    }else if (offsetX<SCREEN_WIDTH){
        _leftCurIndex--;
        _centerCurIndex--;
        _rightCurIndex--;
        if (_leftCurIndex<0) {
            _leftCurIndex=_imagesAssetArray.count-1;
        }
        if (_centerCurIndex<0) {
            _centerCurIndex=_imagesAssetArray.count-1;
        }
        if (_rightCurIndex<0) {
            _rightCurIndex=_imagesAssetArray.count-1;
        }
        
        //切换左，中，右三个位置上面的图片
        NSURL *url_left = [[_imagesAssetArray[_leftCurIndex] defaultRepresentation] url];
        [self getGifData:url_left forWeb:_leftWebView];//获取图片并加载到web上

        NSURL *url_center = [[_imagesAssetArray[_centerCurIndex] defaultRepresentation] url];
        [self getGifData:url_center forWeb:_centerWebView];//获取图片并加载到web上

        NSURL *url_right = [[_imagesAssetArray[_rightCurIndex] defaultRepresentation] url];
        [self getGifData:url_right forWeb:_rightWebView];//获取图片并加载到web上
    }

    //scrollView滑动之后始终保持_centerWebView在正中间
    scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
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
    CGSize webSize = webView.bounds.size;

    float w = webSize.width / contentSize.width , h = webSize.height / contentSize.height,zoom;

    zoom = contentSize.width < contentSize.height ? w : h;
    webView.scrollView.minimumZoomScale = zoom;
    webView.scrollView.maximumZoomScale = zoom;
    webView.scrollView.zoomScale = zoom;
}
#pragma mark ===== tool =====
-(void)getGifData:(NSURL *)url forWeb:(UIWebView *)webView//获取图片
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
                      NSLog(@"error == %@",error);
                  }];
}

@end
