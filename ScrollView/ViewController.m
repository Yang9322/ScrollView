//
//  ViewController.m
//  ScrollView
//
//  Created by He yang on 15/12/26.
//  Copyright © 2015年 He yang. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "Model.h"
#import "MJExtension.h"
#import "MJRefresh.h"
@interface HYImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@end

@implementation HYImageCell
@end

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray *data;
@property (nonatomic,strong)NSMutableArray *modelArray;
@property (strong, nonatomic) NSValue *targetRect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self fetchDataFromServer:0];
    _modelArray = [NSMutableArray array];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDatas)];
    [self.tableView.mj_header beginRefreshing];
}


-(void)loadData{
    [self getData:0];
}


-(void)loadMoreDatas{
    
    
    [self getData:1];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)getData:(int)type
{
    static NSString *url = @"http://image.baidu.com/search/acjson?tn=resultjson_com&ipn=rj&ie=utf-8&oe=utf-8&word=nature&queryWord=nature";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"111---%@---222",responseObject);
        
        
        NSMutableArray *modelAry = [Model objectArrayWithKeyValuesArray:responseObject[@"data"]];
        
        if (type == 0) {
            _modelArray = modelAry;
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
 
        }else{
            [_modelArray addObjectsFromArray:modelAry];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            
        }
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
     }];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ImageCell";
    HYImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Model *model = _modelArray[indexPath.row];
    
    
    NSInteger width = model.width;
    NSInteger height = model.height;
        if (width > 0 && height > 0) {
            return tableView.frame.size.width / (float)width * (float)height;
        }
    return 44.0;
}

- (void)configureCell:(HYImageCell *)cell withIndexPath:(NSIndexPath *)indexPath{
 
    
    Model *model = _modelArray[indexPath.row];
    NSURL *targetURL = [NSURL URLWithString:model.hoverURL];

    NSLog(@" 111---  %@ ---111",cell.photoView.sd_imageURL );
    
    if (![cell.photoView.sd_imageURL isEqual:targetURL]) {
        
        cell.photoView.alpha = 0.0;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        CGRect cellFrame = [self.tableView rectForRowAtIndexPath:indexPath];
        BOOL shouldLoadImage = YES;
        if (self.targetRect && !CGRectIntersectsRect([self.targetRect CGRectValue], cellFrame))
        {
            SDImageCache *cache = [manager imageCache];
            NSString *key = [manager cacheKeyForURL:targetURL];
            if (![cache imageFromMemoryCacheForKey:key])
            {
                shouldLoadImage = NO;
            
            }
        }
        
        if (shouldLoadImage) {
            [cell.photoView sd_setImageWithURL:targetURL placeholderImage:nil options:SDWebImageHandleCookies completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error && [imageURL isEqual:targetURL]) {
                    // fade in animation
                    [UIView animateWithDuration:0.25 animations:^{
                        cell.photoView.alpha = 1.0;
                    }];
                    
                }
            }];
        }
    }
}








- (void)loadVisibleCell
{
    NSArray *cells = [self.tableView visibleCells];
    for (HYImageCell *cell in cells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self configureCell:cell withIndexPath:indexPath];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.targetRect = nil;
    [self loadVisibleCell];
    NSLog(@"%s",__func__);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"%s",__func__);
    CGRect targetRect = CGRectMake(targetContentOffset->x, targetContentOffset->y, scrollView.frame.size.width, scrollView.frame.size.height);
    self.targetRect = [NSValue valueWithCGRect:targetRect];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"%s",__func__);
    
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSLog(@"%s",__func__);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%s",__func__);
    self.targetRect = nil;
    [self loadVisibleCell];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%s",__func__);
}












@end
