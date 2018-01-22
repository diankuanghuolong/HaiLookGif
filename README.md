# HaiLookGif
浏览iphone相册中gif图片

[简书](https://www.jianshu.com/p/e28f803f2888)

>概述：
    iphone相册不支持gif浏览，虽然gif是静止图但是保存的是gif格式。
    这里大概讲下我的思路：
    
- 1.先通过assetslibrary取得gif图片的data格式，然后保存到本地文件夹中（因为在 ALAssetsLibraryAssetForURLResultBlock外取的值为空，我用_ _block也不行，有其他方案的欢迎指教），然后当从相册取到图片并返回到你的控制器的时候（相册代理中的[self dismissViewControllerAnimated:YES completion:^() { }中），取得你保存在本地的imgData。
- 2.加载gif的思路有两种，一种是通过帧动画加载，另一种通过webView加载。本文是通过webView加载。将刚取得的imgData通过webView加载并显示出来。
- 3.webView中图片过大问题处理。设置web属性页面自适应，禁止滚动；并在web加载完成代理中，控制web的contentSize；
                _webView.scalesPageToFit = YES;
                _webView.scrollView.scrollEnabled = NO;
- 4.最后，在appDelegate中，设置程序打开及退出时，删除本地保存的图片。

## 通过assetslibrary 框架获取相册中gif图片(注意获取gif图片需要将其转换为data，直接获取图片是第一帧的静止图片。)
    
```
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
            //此处讲图片转为 data格式并保存到本地文件夹中，因为在这个block块结束时，ALAsset对象销毁，imageData所指向的是他对应的指针，也会销毁，在block外取值为空。
            }
            else {

            //未获取到gif
            }
            };

            [assetsLibrary assetForURL:imageRefURL
            resultBlock:ALAssetsLibraryAssetForURLResultBlock
            failureBlock:^(NSError *error){
            }];
        }

```

# 结语：通过本demo只能实现一张图一换，如果要实现滚动播放相册所有图片，可通过assetsLibrary的group方法实现，具体的我也没做（为啥？我笨、我懒、我还要写bug呢。），有兴趣的可以自己去做。

·

·

·

·

·

·

·

·
等等，请放下您手中的砖头，什么事情是不可以商量的呢？求您别再砸了，再砸，我都快变成释迦摩尼了，我这满头的包啊。😭请看看我这晶莹、清澈的眼睛，请看看我这阳光、爽朗的面庞，我这不是正在写呢吗。您看，写好了的，下面就是。

## ShowAllPhotosVC 部分：（查看所有图片）


        追求完美的用户体验，是我们的职业素养。每一个功能都可以通过不同的方法实现，但是，程序员的职责是寻找最优雅的一种。
        如果说，教育的目的，当是传递生命的气息。
        那么，编程的目的，当是书写心灵的诗句。
     
        [self getGroupArray];//获取所有图片------这里只为效果，实际中，获取图片当在进入此页面前就完成，避免用户进入当前页面的等待时间。
        

1.通过 -(void)getGroupArray; 方法和 -(void)getImgArr;方法，获取相册中各组相册和相册中所有图片;

2.-(void)getGifData:(NSURL *)url forWeb:(UIWebView *)webView;//获取图片并加载;

3.创建三个webview，加载到scrollview上，并通过三图实现无限轮播（模拟器可以不这样做，但是手机的话，相册中图片数量可能很大，会导致内存问题。）

4.但是还有个问题，就是滑动切换图片的时候，会有闪烁。（可能是在tup适配web大小的方法中的问题：|-(void)webViewDidStartLoad:(UIWebView *)webView;中和方法：-(void)webViewDidFinishLoad:(UIWebView *)webView中|未解决。欢迎指教。）


![展示图片](https://github.com/diankuanghuolong/HaiLookGif/blob/master/HaiLookGif/showImages/gifLook.gif)
