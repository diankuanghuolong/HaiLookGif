# HaiLookGif
浏览iphone相册中gif图片

>概述：
    由于iphone相册不支持gif浏览，虽然gif是静止图但是保存的是gif格式。
    这里大概讲下我的思路：
    
- 1.先通过assetslibrary取得gif图片的data格式，然后保存到本地文件夹中（因为在 ALAssetsLibraryAssetForURLResultBlock外取的值为空，我用_ _block也不行，有其他方案的欢迎指教），然后当从相册取到图片并返回到你的控制器的时候（相册代理中的[self dismissViewControllerAnimated:YES completion:^() { }中），取得你保存在本地的imgData。
- 2.加载gif的思路有两种，一种是通过帧动画加载，另一种通过webView加载。本文是通过webView加载。讲刚取得的imgData通过webView加载并显示出来。
- 3.webView中图片过大问题处理。设置web属性页面自适应，禁止滚动；并在web加载完成代理中，控制web的contentSize；
                _webView.scalesPageToFit = YES;
                _webView.scrollView.scrollEnabled = NO;
- 4.最后，在appDelegate中，设置程序打开及退出时，删除本地保存的图片。
    
#  通过assetslibrary 框架获取相册中gif图片(注意获取gif图片需要将其转换为data，直接获取图片是第一帧的静止图片。)
    
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

![展示图片](https://github.com/diankuanghuolong/HaiLookGif/blob/master/HaiLookGif/showImages/gifLook.gif)
