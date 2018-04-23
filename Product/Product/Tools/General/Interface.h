//
//  Interface.h
//  Product
//
//  Created by vision on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#ifndef Interface_h
#define Interface_h


#endif /* Interface_h */


/********************** app环境 ****************************/
#pragma mark - app环境，0开发或1发布


#define isTrueEnvironment 1

#if isTrueEnvironment

#define kHostURL           @"http://api-h.360tj.com/%@"      //正式
#define kHostShopURL       @"http://www.360tj.com/%@"        //正式
#define kHostADiaryURL       @"http://wx.360tj.com/tianji/content/public/diary/index.html"        //营养日记正式
#else

//#define kHostURL           @"http://172.16.0.108:81/%@"      //程荣禄（测试）
//#define kHostURL           @"http://172.16.0.78/%@"          //叶剑武（测试）
#define kHostURL           @"http://api-h-t.360tj.com/%@"      //测试
#define kHostShopURL       @"http://m-t.360tj.com/%@"          //测试
//#define kHostShopURL       @"http://172.16.0.78/%@"          //叶剑武（测试）
#define kHostADiaryURL       @"http://wm-ts-t.360tj.com/wx/diary/index.html"        //营养日记测试

#endif



//数据统计
#define kShareEventCount     @"center/Index/share"
#define kClickEventCount     @"center/Index/click"
#define kPageEventCount      @"center/Index/action"

//用户模块
#define kLoginAPI            @"webapp/User/login"                           //用户登录
#define kRegisterAPI         @"webapp/User/register"                        //用户注册
#define kCheckCode           @"webapp/User/checkCode"                       //修改密码－－验证手机验证码
#define kForgetPassword      @"webapp/User/forget"                          //忘记密码－－验证手机验证码
#define kGetTokenAPI         @"webapp/User/getToken"                        //刷新用户凭证
#define kSendSign            @"webapp/User/sendSms"                         //发送手机验证码
#define kUpdatePassword      @"webapp/User/reset"                           //重设密码
#define kLoginOutAPI         @"webapp/User/loginOut"                        //用户登出
#define kChangePassWord      @"webapp/User/setPassword"                     //修改密码
#define kChangeNickName      @"webapp/User/setNickname"                     //修改昵称
#define kAddMineInformation  @"webapp/User/setUserinfo"                     //获取／添加／修改个人信息
#define kUserUploadPhoto     @"webapp/User/upPhoto"                         //上传图像
#define kGetUserInfo         @"webapp/User/getUserinfo"                     //获取用户信息
#define kGetCollectList      @"webapp/Collectionlikeindex/lists"            //获取我的收藏列表
#define kGetHealthTargetList @"webapp/health_target/lists"                  //健康目标列表

//健康
#define kHealthEveryday      @"webapp/Todaydataindex/read"                  //每日动态
#define kEveryRecommendMenu  @"webapp/record_index/recordIndex"             //每日推荐动态

//饮食记录
#define kFoodCategory        @"webapp/Foodmaterialindex/lists_ingredientcat"//食材分类列表
#define kFoodList            @"webapp/Foodmaterialindex/lists_ingredient"   //食材详细
#define kMenuDetailList      @"webapp/cook/add"                             //菜谱详情
#define kDietRecordAdd       @"webapp/Dietrecordindex/add"                  //添加饮食记录
#define kDietRecordUpdate    @"webapp/Dietrecordindex/update"               //跟新饮食记录
#define kDietRecordLists     @"webapp/Dietrecordindex/lists"                //饮食记录列表
#define kDietRecordDelete    @"webapp/Dietrecordindex/delete"               //删除饮食记录

//运动记录
#define kSportRecordAdd      @"webapp/Motionrecordindex/add"                //添加运动记录
#define kSportRecordUpdate   @"webapp/Motionrecordindex/update"             //更新运动记录
#define kSportRecordLists    @"webapp/Motionrecordindex/lists"              //运动记录列表
#define kSportRecordDelete   @"webapp/Motionrecordindex/delete"             //删除运动记录
#define kSportRecordMenu     @"webapp/motionrecordindex/motionType"         //运动分类
#define kSportRecordTable    @"webapp/motionrecordindex/motionLists"        //运动库

//体脂记录
#define kWeightRecordAdd     @"webapp/Constitutionanalyzerindex/add"        //添加体脂记录
#define kWeightRecordList    @"webapp/Constitutionanalyzerindex/lists"      //智能体质分析仪记录查询

//血压记录
#define kBloodRecordAdd      @"webapp/blood_pressure/pressureRecord"        //添加血压记录
#define kBloodRecordList     @"webapp/blood_pressure/lists"                 //血压记录列表

#define kSetUserInfo         @"webapp/User/setUserinfo"                     //获取／添加／修改个人信息
#define kUserUploadPhoto     @"webapp/User/upPhoto"                         //上传图像

// 首页
#define kUploadDeviceInfo    @"webapp/Common/add"                           //上传设备信息
#define kHomeIndex           @"webapp/index_v3_4/index"                          // 首页数据
#define kAdIndexUrl          @"v2_2/Ad/index"                               // 运营位
#define kBannarStatistics    @"webapp/Statisticsclickcountindex/add"        //统计bannar


/// 食材相关
#define kFoodCategory        @"webapp/Foodmaterialindex/lists_ingredientcat"//食材库
#define kFoodList            @"webapp/Foodmaterialindex/lists_ingredient"   //食材分类列表
#define kFoodDetail          @"webapp/Foodmaterialindex/read"               //食材详情
#define KRecommendMenu       @"webapp/recommend_diet/recommendMenu"         /// 食疗推荐
//菜谱相关
#define KEquipment           @"webapp/cook/getEquipment"                    //菜谱（设备列表）
#define KEffect              @"webapp/cook/effect_list"                     //菜谱（功效列表）
#define kMenuList            @"webapp/Cook/index"                           //菜谱列表
#define KMenuDetail          @"webapp/cook/detail"                          // 菜谱详情
#define KCollection          @"webapp/Collectionlikeindex/adddel_collection"//收藏，食材，菜谱，文章）
#define KEditlike            @"webapp/cook/editlike"                        //菜谱点赞/取消点赞
#define KCollection          @"webapp/Collectionlikeindex/adddel_collection"/// 收藏
#define kHotKeyword          @"webapp/Hotkeywordindex/read"                 //搜索热门关键词
/// 百科
#define kArticleCategory     @"webapp/Articleclassificationindex/lists"     //文章分类
#define kArticleList         @"webapp/Articlemanagementindex/lists"         //文章列表
//健康评估
#define kHealthList          @"webapp/Assessindex/lists"                    //健康评估列表
#define kHealthRecord        @"webapp/Assessindex/add_record"               //健康评估纪录
#define kHealthContent       @"webapp/Assessindex/read"                     //健康评估数据

// 运动模块
#define KRecommendMotion     @"webapp/recommend_motion/recommendMotion"     /// 运动推荐
#define kSportHistoryList    @"webapp/sport_scheme/historyRecord"           /// 运动记录
#define KSportScheme         @"webapp/sport_scheme/lists"                   /// 运动累计记录
#define KMotionRecord        @"webapp/sport_scheme/motionRecord"            /// 实时运动记录 （添加）
#define KSportCount          @"webapp/sport_scheme/sportCount"              /// 运动统计（查询）
#define KSportTypeList       @"webapp/motion_cat/lists"                     /// 运动类型
#define kSportHistoryDelete  @"webapp/sport_scheme/delete"                  /// 运动删除

//步数
#define kAddDailyStep        @"webapp/Step/add"                             //记录用户步数
#define kStepRank            @"webapp/Step/index"                           //获取用户排行榜

//其他
#define kFeedbackAdd         @"webapp/Feedbackindex/add"                    //意见反馈

//智能厨物柜
#define kGetStorageFoodList     @"webapp/Lockeringredientindex/lists"          //获取厨物柜食材列表
#define kAddStorageFood         @"webapp/Lockeringredientindex/add"            //添加厨物柜食材
#define kUpdateStorageFood      @"webapp/Lockeringredientindex/update"         //更新厨物柜食材
#define kDeleteStorageFood      @"webapp/Lockeringredientindex/delete"          //删除厨物柜食材
#define kFoodstatistics         @"webapp/Lockeringredientindex/count"          //储物柜食材统计
#define kSaveOfflineRiceRecord  @"webapp/Lockerrecordindex/add"                //保存离线出米记录
#define kGetOfflineRiceRecord   @"webapp/Lockerrecordindex/lists"              //获取离线出米记录


// 积分商城
#define KGoodsList          @"webapp/Goodsindex/lists"                  // 积分商品列表
#define KGoodDetail         @"webapp/Goodsindex/read"                   // 商品详情
#define KIntegralList       @"webapp/task/lists"                        // 积分列表
#define kIntegralDetail     @"webapp/task/read"                         // 积分详情
#define KTaskList           @"webapp/task/taskList"                     // 积分任务列表
#define kExchangeRecordsList       @"webapp/Orderindex/lists"           // 兑换记录列表
#define KExchangeRecordsDetail         @"webapp/Orderindex/read"        // 兑换记录详情
#define kAddConsignee       @"webapp/Consigneeindex/add_consignee"      // 用户收货地址信息
#define KGoodsAdd           @"webapp/Orderindex/add"                    // 兑换积分商品
#define KTask               @"webapp/task/task"                         // 每日任务

// 智能场景
#define KAddScene           @"webapp/scene/addScene"                    // 添加场景
#define KSceneList          @"webapp/scene/lists"                       // 场景列表
#define KSceneDetail        @"webapp/scene/read"                        // 场景详情
#define KSceneEdit          @"webapp/scene/update"                      // 编辑场景
#define KSceneDelete        @"webapp/scene/delete"                      // 场景删除
#define kRecordList         @"webapp/scene/recordList"                  // 执行记录列表
#define kRecordDetail       @"webapp/scene/recordDetail"                // 执行场景记录详情
#define KRecordStatus       @"webapp/scene/getStatus"                   // 获取场景中设备状态
#define KStartRecorScene    @"webapp/scene/exeScene"                    // 执行场景
#define KStopRecorScene     @"webapp/scene/stopScene"                   // 停止执行场景

//商城
#define KShopGoods          @"index.php/openapi/shop_goods/get_cat_list"               // 商品一级分类
#define KShopGoodsList      @"index.php/openapi/shop_goods/search_properties_goods"    // 商品分类列表
#define KShopDetail         @"index.php/openapi/shop_goods/get_goods_detail"           // 商品详情
#define KShopAddCart        @"index.php/openapi/shop_goods/add_cart"                   // 加入购物车
#define KShopCartNum        @"index.php/openapi/shop_goods/cart_num"                   // 购物车数
#define KShopCollection     @"index.php/openapi/shop_goods/addDel_fav"                 // 商品收藏
#define KShopFavoriteList   @"index.php/openapi/shop_user/favorite"                    // 商品收藏列表
#define KShopDelFavorite    @"index.php/openapi/shop_user/del_favorite"                // 商品删除收藏
#define kShopCartGoodsList  @"index.php/openapi/shop_cart/get_cart_info"               //购物车列表
#define kShopCartUpdate     @"openapi/shop_cart/update_cart"                           //更新购物车
#define kShopCartChangeNum  @"index.php/openapi/shop_cart/change_num"                  //修改购物车商品数量
#define kShopAddToFavorites @"index.php/openapi/shop_goods/add_fav"                    //移入收藏夹
#define kShopDeleteGoods    @"index.php/openapi/shop_cart/remove_cart"                 //删除商品
#define kShopOrderCreate    @"openapi/shop_cart/create"                                //提交订单
#define kGetShopOrderInfo   @"openapi/shop_pay/payment"                                //获取支付信息
#define kOrderWxPayCallBack @"openapi/ectools_payment/parse/ectools/ectools_payment_plugin_wxpayApp/callback/"        //微信支付回调
#define kOrderAliPayBack    @"openapi/ectools_payment/parse/ectools/ectools_payment_plugin_alipayApp/callback/"       //支付宝支付回调
#define KShopOrderList      @"index.php/openapi/shop_user/get_order_list"              // 订单列表
#define KShopOrderDetail    @"index.php/openapi/shop_order/get_order_detail"           // 订单详情
#define kDeleaterOrder      @"index.php/openapi/shop_user/del_order"                   // 订单删除
#define KSaveAddress        @"index.php/openapi/shop_user/save_address"                // 添加和编辑收货地址
#define kShippingAddress    @"index.php/openapi/shop_user/get_address"                 // 收货地址列表
#define KGetAllRegions      @"index.php/openapi/shop_user/get_all_regions"             // 收货地址省市地区
#define KDeleateAddress     @"index.php/openapi/shop_user/del_address"                 // 收货地址删除
#define kShopCartSelected   @"index.php/openapi/shop_cart/option"                      // 购物车商品单/多选
#define kShopOrderNum       @"index.php/openapi/shop_order/get_order_count"            // 我的订单总数
#define KStatusUpdate       @"index.php/openapi/shop_order/status_update"              // 更新订单状态取消/确认收货
#define KBuyAgain           @"index.php/openapi/shop_user/re_add_cart"                 // 再次购买
#define kOrderReceive       @"index.php/openapi/shop_order/receive"                    // 确认收货
#define KShopHotKeyWords    @"index.php/openapi/shop_goods/get_keyword"                // 商城热门关键词
#define KOrderCount         @"index.php/openapi/shop_order/get_order_count"            // 订单数量
#define KShopQuickBuy       @"openapi/shop_cart/quickBuy"                              // 立即购买
#define KLogisticsInfo      @"index.php/openapi/shop_order/get_kdniao_logistics"       // 订单物流
