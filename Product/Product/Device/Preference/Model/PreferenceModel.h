//
//  PreferenceModel.h
//  Product
//
//  Created by Xlink on 16/2/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    TYPE_CLOUD_MENU=0,
    TYPE_WORKTYPE=1,
}TYPE_PERFERENCE;

///偏好
@interface PreferenceModel : NSObject

@property int preferenceType;

@property (nonatomic,strong)NSString *preferenceName;

@property (nonatomic,strong)NSString  *preferenceHour;

@property (nonatomic,strong)NSString  *preferenceMin;

@property (nonatomic,strong)NSString  *preferenceDetail;

@property (nonatomic,strong)NSString  *preferenceImgURL;

@property (nonatomic,strong)NSString  *preferenceId;

@end
