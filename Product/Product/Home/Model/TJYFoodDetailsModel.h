//
//  TJYFoodDetailsModel.h
//  Product
//
//  Created by zhuqinlu on 2017/4/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//-----   食物详情模型数据
/*
result": {
"id": 1,
"name": "海参",
"cat_id": "7",
"brief": null,
"display": 1,
"adaptive_disorder_id": [ ],
"effect_id": [ ],
"efficacy_description": [ ],
"food_suggestion": null,
"orther_name": "辽参、海男子、刺参、海鼠、海瓜",
"flavor": "味甘咸、性微寒",
"channel_tropism": "归心、肝、肾经",
"nutrient_component": null,
"department": 100,
"protein": 17,
"cholesterol": 51,
"retinol": 0,
"vitaminC": 0,
"vitaminEOE": 0,
"sodium": 503,
"selenium": 64,
"moisture": 77,
"fat": 0,
"ash": 4,
"thiamine": 0,
"vitaminE": 3,
"calcium": 285,
"magnesium": 149,
"copper": 0,
"energykcal": 78,
"carbohydrate": 3,
"totalvitamin": 0,
"riboflavin": 0,
"vitaminEAE": 2,
"phosphorus": 28,
"iron": 13,
"manganese": 1,
"energykj": 326,
"insolublefiber": 0,
"carotene": 0,
"niacin": 0,
"vitaminEBYE": 1,
"potassium": 43,
"zinc": 1,
"remark": null,
"dietotherapy": "益精填髓、滋阴助阳、补血润燥、养血止血、通利二便",
"select_skills": "体形肥满，肉质较厚、刺挺直、无残缺、嘴部石灰质露出少、切口较整齐者为佳",
"storage_environment": "鲜海参0～4℃储藏90天，冷冻储藏储藏12个月；干海参密封，放在通风、干燥处",
"supplier_id": [ ],
"add_time": "2017-03-06 09:39:57",
"edit_time": "2017-03-06 09:39:57",
"classic_source": "",
"ingredient_code": "129001",
"cat_name": "水产类",
"effect_name": [ ],
"adaptive_disorder_name": [ ],
"supplier_name": [ ],
"images": [ ],
"is_collection": "1"
}
*/

#import <Foundation/Foundation.h>

@interface TJYFoodDetailsModel : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *storage_environment;

@property (nonatomic, assign) NSInteger niacin;

@property (nonatomic, assign) NSInteger phosphorus;

@property (nonatomic, assign) NSInteger insolublefiber;

@property (nonatomic, copy) NSString *cat_name;

@property (nonatomic, assign) NSInteger thiamine;

@property (nonatomic, assign) NSInteger riboflavin;

@property (nonatomic, assign) NSInteger calcium;

@property (nonatomic, strong) NSArray *supplier_id;

@property (nonatomic, assign) NSInteger department;

@property (nonatomic, assign) NSInteger carotene;

@property (nonatomic, assign) NSInteger totalvitamin;

@property (nonatomic, strong) NSArray *effect_name;

@property (nonatomic, copy) NSString *flavor;

@property (nonatomic, strong) NSArray *supplier_name;

@property (nonatomic, assign) NSInteger manganese;

@property (nonatomic, strong) NSArray *effect_id;

@property (nonatomic, assign) NSInteger vitaminEOE;

@property (nonatomic, assign) NSInteger vitaminEAE;

@property (nonatomic, assign) NSInteger energykj;

@property (nonatomic, copy) NSString *cat_id;

@property (nonatomic, strong) NSArray *adaptive_disorder_id;

@property (nonatomic, assign) NSInteger display;

@property (nonatomic, assign) NSInteger ash;

@property (nonatomic, assign) NSInteger protein;

@property (nonatomic, copy) NSString *orther_name;

@property (nonatomic, copy) NSString *add_time;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger selenium;

@property (nonatomic, assign) NSInteger energykcal;

@property (nonatomic, copy) NSString *select_skills;

@property (nonatomic, copy) NSString *brief;

@property (nonatomic, assign) NSInteger vitaminEBYE;

@property (nonatomic, copy) NSString *nutrient_component;

@property (nonatomic, copy) NSString *channel_tropism;

@property (nonatomic, assign) NSInteger moisture;

@property (nonatomic, assign) NSInteger fat;

@property (nonatomic, copy) NSString *remark;

@property (nonatomic, assign) NSInteger zinc;
/// 功效名
@property (nonatomic, copy) NSArray *efficacy_description;
/// 功效详情
@property (nonatomic, copy) NSArray *effect_nameArray;

@property (nonatomic, assign) NSInteger sodium;

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, copy) NSString *classic_source;

@property (nonatomic, assign) NSInteger cholesterol;

@property (nonatomic, assign) NSInteger vitaminC;

@property (nonatomic, strong) NSArray *adaptive_disorder_name;

@property (nonatomic, assign) NSInteger vitaminE;

@property (nonatomic, assign) NSInteger copper;

@property (nonatomic, assign) NSInteger retinol;

@property (nonatomic, assign) NSInteger magnesium;

@property (nonatomic, assign) NSInteger iodine;

@property (nonatomic, assign) NSInteger carbohydrate;

@property (nonatomic, assign) NSInteger potassium;
///点评
@property (nonatomic, copy) NSString *dietotherapy;

@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) NSInteger iron;

@property (nonatomic, copy) NSString *food_suggestion;

@property (nonatomic, copy) NSString *gi;


@property (nonatomic, copy) NSString *gl;
/// 是否收藏
@property (nonatomic, assign) BOOL is_collection;

@property (nonatomic,assign) CGFloat weight;

@end
