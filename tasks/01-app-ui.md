# 01 — App端UI与交互模块

> iOS (Objective-C) | 共 40 个任务

---

## 1. 短剧入口

### APP-001 创建底部TabBar，添加"短剧"Tab
- **优先级**: P0
- **预估工时**: 1天
- **依赖**: 无
- **描述**: 在App主框架中创建自定义TabBarController，添加"短剧"Tab作为核心入口。TabBar至少包含：首页、短剧、我的三个Tab，短剧Tab使用自定义图标（普通态+选中态）。
- **技术要点**: 
  - 继承UITabBarController，自定义RRVTabBarController
  - 每个Tab对应一个UINavigationController包裹的根VC
  - 支持角标（如未读/新剧提示）
  - TabBar样式：背景色、选中色、字体大小可配置
- **涉及文件**: 
  - `redredvideo/Main/RRVTabBarController.h/.m` (新建)
  - `redredvideo/Main/RRVNavigationController.h/.m` (新建)
  - `AppDelegate.m` (修改rootViewController)
  - `Assets.xcassets` (TabBar图标资源)
- **验收标准**:
  - [ ] App启动后展示底部TabBar，包含至少3个Tab
  - [ ] 点击"短剧"Tab能切换到短剧频道页
  - [ ] TabBar图标有普通态和选中态两种样式
  - [ ] 支持横竖屏TabBar正常显示
  - [ ] 各Tab切换流畅，无卡顿

---

### APP-002 短剧频道首页
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: APP-001
- **描述**: 短剧Tab的首页，包含顶部Banner轮播、分类导航栏（横滑标签）、推荐短剧列表（瀑布流/卡片列表）。支持下拉刷新和上拉加载更多。
- **技术要点**: 
  - 使用UICollectionView构建，通过不同Section实现不同布局
  - Banner使用UIScrollView+Timer实现自动轮播，支持手势暂停
  - 分类导航使用UICollectionView横滑，选中态动画
  - 推荐列表每行2列卡片，封面+标题+热度标签
  - 数据源对接API-003/API-011接口
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Home/RRVDramaHomeVC.h/.m` (新建)
  - `redredvideo/Modules/Drama/Home/Views/RRVBannerView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Home/Views/RRVCategoryNavView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Home/Views/RRVDramaCardCell.h/.m` (新建)
  - `redredvideo/Modules/Drama/Home/ViewModels/RRVDramaHomeVM.h/.m` (新建)
- **验收标准**:
  - [ ] Banner自动轮播，手动滑动时暂停自动轮播
  - [ ] 分类导航横滑流畅，点击切换对应列表数据
  - [ ] 推荐列表支持下拉刷新、上拉加载更多
  - [ ] 网络异常时展示空态/错误提示
  - [ ] 骨架屏/Loading态正常展示
  - [ ] 首屏加载时间 < 1.5秒（缓存命中时）

---

### APP-003 短剧专区卡片
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: APP-002
- **描述**: 可嵌入其他信息流（如首页、推荐流）中的短剧入口卡片组件。展示3-4部热门短剧缩略图 + "查看更多"入口，点击跳转短剧频道或具体剧集。
- **技术要点**: 
  - 封装为独立UIView组件，外部传入数据即可展示
  - 内部使用UICollectionView横滑展示
  - 点击卡片跳转剧集详情页，点击"更多"跳转短剧频道
  - 支持不同尺寸适配（大卡/小卡模式）
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Components/RRVDramaZoneCard.h/.m` (新建)
  - `redredvideo/Modules/Drama/Components/RRVDramaMiniCell.h/.m` (新建)
- **验收标准**:
  - [ ] 组件可在任意页面中嵌入使用
  - [ ] 横滑展示热门短剧，带封面和标题
  - [ ] 点击跳转正确
  - [ ] 无数据时自动隐藏

---

### APP-004 搜索页面
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: APP-001, NET-001
- **描述**: 搜索页面，包含搜索输入框、热搜榜（运营配置+自动热度排序）、搜索历史（本地存储）、实时搜索建议（联想词）、搜索结果列表。
- **技术要点**: 
  - 搜索框使用UISearchBar或自定义输入框
  - 热搜榜数据从API-009接口获取
  - 搜索历史存储在NSUserDefaults或本地DB，最多保留20条
  - 输入时300ms防抖后请求联想词
  - 搜索结果使用UITableView展示，支持分页
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Search/RRVSearchVC.h/.m` (新建)
  - `redredvideo/Modules/Drama/Search/Views/RRVHotSearchView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Search/Views/RRVSearchHistoryView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Search/Views/RRVSearchSuggestView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Search/Views/RRVSearchResultCell.h/.m` (新建)
- **验收标准**:
  - [ ] 搜索框输入文字后展示联想建议
  - [ ] 热搜榜正确展示，点击热搜词触发搜索
  - [ ] 搜索历史本地持久化，支持清空
  - [ ] 搜索结果分页加载
  - [ ] 无结果时展示空态页面

---

### APP-005 分类筛选页
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: APP-002, API-003
- **描述**: 多维度筛选页面，支持按类型（言情/悬疑/都市/古装…）、地区（大陆/港台/韩国…）、年份（2024/2023…）、状态（连载中/已完结）进行组合筛选。
- **技术要点**: 
  - 顶部使用横滑Tab或下拉筛选面板
  - 筛选条件组合后请求API-003接口
  - 结果列表复用RRVDramaCardCell
  - 筛选状态URL化，支持深链跳入
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Filter/RRVDramaFilterVC.h/.m` (新建)
  - `redredvideo/Modules/Drama/Filter/Views/RRVFilterBarView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Filter/Views/RRVFilterDropdownView.h/.m` (新建)
- **验收标准**:
  - [ ] 各筛选维度独立或组合使用
  - [ ] 切换筛选条件时列表实时更新
  - [ ] 选中状态有视觉反馈
  - [ ] 支持"重置筛选"

---

## 2. 剧集详情

### APP-006 剧集详情页UI
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: APP-002, API-004
- **描述**: 展示单部短剧的完整信息，包含：顶部封面（模糊背景+海报）、标题、评分、热度值、标签（类型/地区/年份）、简介（展开/收起）、演员列表（头像横滑）、操作按钮（收藏/分享/追剧）。
- **技术要点**: 
  - 使用UIScrollView或UITableView构建，各区域为独立Section
  - 封面区使用UIVisualEffectView做模糊背景
  - 简介超过3行显示"展开"按钮
  - 评分使用自定义星级组件
  - 数据从API-004接口获取
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Detail/RRVDramaDetailVC.h/.m` (新建)
  - `redredvideo/Modules/Drama/Detail/Views/RRVDramaHeaderView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Detail/Views/RRVDramaInfoView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Detail/Views/RRVActorListView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Detail/ViewModels/RRVDramaDetailVM.h/.m` (新建)
  - `redredvideo/Models/RRVDramaModel.h/.m` (新建)
- **验收标准**:
  - [ ] 页面信息完整展示：封面、标题、评分、标签、简介、演员
  - [ ] 简介展开/收起动画流畅
  - [ ] 收藏/分享按钮响应正确
  - [ ] 页面下拉有视差效果（可选）
  - [ ] 加载中有骨架屏

---

### APP-007 集数选择列表
- **优先级**: P0
- **预估工时**: 1.5天
- **依赖**: APP-006, API-005
- **描述**: 在剧集详情页下方展示集数列表，支持正序/倒序切换。每集显示集号、标题、时长、付费状态标记（免费/付费/已购）。点击某集跳转播放器。
- **技术要点**: 
  - UICollectionView网格布局（一行4-5个）或列表布局
  - 正序/倒序通过数据源排序切换，不重新请求
  - 付费集显示锁图标，已购显示对勾
  - 当前播放集高亮显示
  - 集数多时分段展示（如1-30、31-60）
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Detail/Views/RRVEpisodeListView.h/.m` (新建)
  - `redredvideo/Modules/Drama/Detail/Views/RRVEpisodeCell.h/.m` (新建)
  - `redredvideo/Models/RRVEpisodeModel.h/.m` (新建)
- **验收标准**:
  - [ ] 集数列表正确展示，支持正序/倒序切换
  - [ ] 付费状态标记清晰（免费/付费/已购）
  - [ ] 当前播放集有高亮标识
  - [ ] 集数过多时支持分段快速跳转
  - [ ] 点击某集正确跳转播放

---

### APP-008 备案号/许可证号展示区域
- **优先级**: P0
- **预估工时**: 0.5天
- **依赖**: APP-006
- **描述**: 在剧集详情页**醒目位置**展示广电备案号和网络视听许可证号。这是内容合规的硬性要求，必须在用户可见的显著区域展示，不能隐藏在折叠区域。
- **技术要点**: 
  - 在详情页封面区下方或标题区旁边，使用独立View展示
  - 文字颜色与背景形成对比，确保可读性
  - 备案号支持点击复制
  - 无备案号的剧集不应出现在App中（前端兜底校验）
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Detail/Views/RRVLicenseInfoView.h/.m` (新建)
- **验收标准**:
  - [ ] 备案号在详情页醒目位置展示
  - [ ] 许可证号清晰可读
  - [ ] 点击可复制备案号
  - [ ] 无备案号时显示"审核中"或不展示该剧

---

### APP-009 版权方信息展示
- **优先级**: P1
- **预估工时**: 0.5天
- **依赖**: APP-006
- **描述**: 在剧集详情页底部区域展示版权方/出品方信息，包括公司名称、授权类型等，符合版权展示要求。
- **技术要点**: 
  - 位于详情页底部，字体较小但清晰
  - 数据从API-004接口的copyright字段获取
  - 可点击查看版权方更多剧集（可选）
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Detail/Views/RRVCopyrightView.h/.m` (新建)
- **验收标准**:
  - [ ] 版权方信息正确展示
  - [ ] 包含公司名称和授权类型
  - [ ] 排版整齐，不影响主体内容阅读

---

### APP-010 相关推荐列表
- **优先级**: P2
- **预估工时**: 1天
- **依赖**: APP-006, API-010
- **描述**: 在剧集详情页底部展示"猜你喜欢"或"相关推荐"列表，推荐算法基于当前剧集的标签、分类、用户行为等。
- **技术要点**: 
  - 横滑卡片列表，复用RRVDramaCardCell
  - 数据从API-010推荐接口获取，传入当前drama_id
  - 推荐数据缓存60秒，避免频繁请求
- **涉及文件**: 
  - `redredvideo/Modules/Drama/Detail/Views/RRVRelatedDramaView.h/.m` (新建)
- **验收标准**:
  - [ ] 推荐列表展示6-10部相关短剧
  - [ ] 点击推荐剧集能跳转到对应详情页
  - [ ] 推荐内容与当前剧有一定相关性

---

## 3. 沉浸式播放器

### APP-011 竖屏全屏播放器基础框架
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: NET-001
- **描述**: 构建竖屏全屏播放器核心框架。短剧特色是竖屏沉浸式观看，播放器需全屏展示视频，支持基本的播放/暂停控制。采用AVPlayer作为底层播放引擎。
- **技术要点**: 
  - 基于AVPlayer + AVPlayerLayer构建RRVPlayerManager单例
  - 播放器VC为全屏竖屏，隐藏状态栏和导航栏
  - 使用AVPlayerItem管理当前播放资源
  - KVO监听playerItem的status、loadedTimeRanges、playbackBufferEmpty
  - 播放状态机：Idle → Loading → Playing → Paused → Ended → Error
  - 内存管理：VC dealloc时必须释放AVPlayer
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPlayerManager.h/.m` (新建)
  - `redredvideo/Modules/Player/RRVPlayerVC.h/.m` (新建)
  - `redredvideo/Modules/Player/RRVPlayerView.h/.m` (新建)
  - `redredvideo/Modules/Player/Models/RRVPlayerState.h` (新建，枚举定义)
- **验收标准**:
  - [ ] 传入视频URL后能正常播放
  - [ ] 竖屏全屏展示，视频填充屏幕
  - [ ] 点击屏幕切换播放/暂停
  - [ ] 播放状态正确流转（Loading/Playing/Paused/Ended/Error）
  - [ ] 内存无泄漏（Instruments验证）
  - [ ] 支持后台切前台恢复播放

---

### APP-012 上滑切换下一集手势
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: APP-011
- **描述**: 短剧核心交互——上滑切换下一集（类似抖音刷视频）。使用UIPageViewController或自定义滑动逻辑，预加载前后集实现无缝切换。
- **技术要点**: 
  - 方案A：UIPageViewController（dataSource提供前后VC）
  - 方案B：UICollectionView + pagingEnabled（更可控）
  - 推荐方案B：自定义UICollectionView + 竖向分页
  - 预加载：当前集播放时提前创建下一集的AVPlayerItem
  - 切换时：暂停当前集 → 开始下一集 → 释放远离的集
  - 保持内存中最多3个PlayerItem（前一集、当前、下一集）
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPlayerPageVC.h/.m` (新建)
  - `redredvideo/Modules/Player/Views/RRVPlayerPageCell.h/.m` (新建)
  - `redredvideo/Modules/Player/RRVPlayerManager.h/.m` (修改，添加预加载逻辑)
- **验收标准**:
  - [ ] 上滑切换到下一集，下滑切换到上一集
  - [ ] 切换动画流畅（60fps）
  - [ ] 切换后新集自动开始播放
  - [ ] 预加载下一集，切换时无Loading等待
  - [ ] 第一集不能再上滑，最后一集上滑提示"已是最新"
  - [ ] 内存稳定，不因连续滑动持续增长

---

### APP-013 左右滑动快进快退
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: APP-011
- **描述**: 在播放器中实现左右滑动手势控制快进/快退，左滑快退、右滑快进，滑动时显示时间预览和进度反馈。
- **技术要点**: 
  - UIPanGestureRecognizer检测水平滑动（需与上下滑动手势区分）
  - 滑动距离映射为时间偏移（如滑动屏幕宽度1/3 = 前进/后退15秒）
  - 滑动过程中显示时间浮层（当前时间 / 总时长）
  - 松手后seek到目标时间
  - 与上下切集手势做互斥判定（主轴判断）
- **涉及文件**: 
  - `redredvideo/Modules/Player/Gestures/RRVPlayerGestureHandler.h/.m` (新建)
  - `redredvideo/Modules/Player/Views/RRVSeekPreviewView.h/.m` (新建)
- **验收标准**:
  - [ ] 左滑快退，右滑快进
  - [ ] 滑动过程中显示时间预览
  - [ ] 松手后准确seek到目标时间
  - [ ] 与上下滑动手势不冲突
  - [ ] seek过程中有loading反馈

---

### APP-014 HLS/DASH自适应码率播放
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: APP-011
- **描述**: 支持HLS (m3u8) 和 DASH 自适应码率播放，根据网络状况自动切换清晰度。支持手动切换清晰度选项。
- **技术要点**: 
  - AVPlayer原生支持HLS自适应码率
  - 通过AVPlayerItem的preferredPeakBitRate控制最大码率
  - 监听accessLog获取当前码率信息
  - 手动切换清晰度：设置preferredPeakBitRate为对应档位值
  - 清晰度档位：流畅(480p) / 标清(720p) / 高清(1080p) / 超清(4K可选)
  - WiFi默认高清，蜂窝默认标清，可配置
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPlayerManager.h/.m` (修改，添加码率控制)
  - `redredvideo/Modules/Player/Models/RRVVideoQuality.h/.m` (新建)
  - `redredvideo/Modules/Player/Views/RRVQualitySelectorView.h/.m` (新建)
- **验收标准**:
  - [ ] m3u8地址能正常播放
  - [ ] 网络变化时自动切换码率
  - [ ] 手动切换清晰度时播放不中断
  - [ ] WiFi/蜂窝环境默认码率策略正确
  - [ ] 码率切换过程中无明显卡顿

---

### APP-015 断点续播
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: APP-011, NET-006, API-007
- **描述**: 记录用户播放进度，下次打开同一集时从上次位置继续播放。进度同时存储到本地和服务端，实现跨设备续播。
- **技术要点**: 
  - 本地存储：每5秒将当前播放时间写入本地DB（drama_id + episode_id + progress + timestamp）
  - 服务端同步：每30秒上报一次到API-007接口
  - 打开剧集时：先取本地进度，再异步取服务端进度，取较新的
  - 进度恢复：播放器加载完成后seek到记录位置
  - 播放结束（≥95%）标记为已看完
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPlayProgressManager.h/.m` (新建)
  - `redredvideo/Services/Storage/RRVPlayHistoryDAO.h/.m` (新建)
- **验收标准**:
  - [ ] 退出播放器后再进入，从上次位置继续
  - [ ] 杀掉App后重新打开，进度仍在
  - [ ] 服务端进度与本地同步
  - [ ] 播放到95%以上标记为"已看完"
  - [ ] 进度记录不影响播放性能

---

### APP-016 倍速播放
- **优先级**: P2
- **预估工时**: 0.5天
- **依赖**: APP-011
- **描述**: 支持多档倍速播放：0.5x / 1.0x / 1.25x / 1.5x / 2.0x。用户可在播放器设置中切换，记住用户最后选择的倍速。
- **技术要点**: 
  - 通过AVPlayer.rate设置播放速度
  - 倍速选择UI：底部弹出面板或播放器右侧菜单
  - 用户倍速偏好存储在NSUserDefaults
  - 注意：倍速播放影响反作弊判定（FRD-003），需上报倍速值
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPlayerManager.h/.m` (修改)
  - `redredvideo/Modules/Player/Views/RRVSpeedSelectorView.h/.m` (新建)
- **验收标准**:
  - [ ] 支持5档倍速切换
  - [ ] 切换后播放速度立即生效
  - [ ] 记住用户倍速偏好
  - [ ] 2x倍速下音画同步
  - [ ] 倍速值通过埋点上报

---

### APP-017 播放器投屏功能（对接乐播SDK）
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: APP-011
- **描述**: 对接乐播投屏SDK，支持DLNA/AirPlay投屏到电视等设备。播放器中显示投屏按钮，点击后扫描局域网设备并展示列表，选择设备后将当前视频投屏。
- **技术要点**: 
  - 集成乐播投屏SDK（LBLelinkKit）
  - 投屏按钮放在播放器控件区右上角
  - 设备发现：调用SDK扫描局域网内的投屏设备
  - 投屏时本地播放器暂停，显示"正在投屏到XXX"
  - 支持投屏中的控制：播放/暂停/进度/音量
  - 断开投屏后恢复本地播放
- **涉及文件**: 
  - `Podfile` (添加乐播SDK依赖)
  - `redredvideo/Modules/Player/Cast/RRVCastManager.h/.m` (新建)
  - `redredvideo/Modules/Player/Cast/RRVCastDeviceListVC.h/.m` (新建)
  - `redredvideo/Modules/Player/Cast/RRVCastControlView.h/.m` (新建)
- **验收标准**:
  - [ ] 播放器中投屏按钮可见
  - [ ] 点击后显示附近可用设备列表
  - [ ] 选择设备后成功投屏
  - [ ] 投屏中可控制播放/暂停/进度
  - [ ] 断开投屏后本地恢复播放
  - [ ] 无投屏设备时提示"未发现设备"

---

### APP-018 播放器UI控件
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: APP-011
- **描述**: 播放器覆盖层UI控件，包含：底部进度条（可拖拽）、当前时间/总时长、音量调节（左侧滑动）、亮度调节（右侧滑动）、锁屏按钮、返回按钮、标题栏。
- **技术要点**: 
  - 覆盖层View，点击屏幕中央显示/隐藏，5秒无操作自动隐藏
  - 进度条UISlider自定义样式，拖动时显示缩略图预览（可选）
  - 音量调节：MPVolumeView隐藏，左侧上下滑动控制
  - 亮度调节：UIScreen.mainScreen.brightness，右侧上下滑动控制
  - 锁屏：锁定后所有手势失效，仅显示解锁按钮
  - 自动隐藏定时器，有操作时重置
- **涉及文件**: 
  - `redredvideo/Modules/Player/Views/RRVPlayerControlView.h/.m` (新建)
  - `redredvideo/Modules/Player/Views/RRVPlayerProgressBar.h/.m` (新建)
  - `redredvideo/Modules/Player/Views/RRVPlayerTopBar.h/.m` (新建)
  - `redredvideo/Modules/Player/Gestures/RRVPlayerGestureHandler.h/.m` (修改)
- **验收标准**:
  - [ ] 点击屏幕显示/隐藏控件
  - [ ] 进度条拖拽准确对应播放位置
  - [ ] 左侧上下滑动调节音量
  - [ ] 右侧上下滑动调节亮度
  - [ ] 锁屏后手势全部失效
  - [ ] 5秒无操作自动隐藏控件
  - [ ] 返回按钮正确退出播放器

---

### APP-019 画中画支持
- **优先级**: P2
- **预估工时**: 1.5天
- **依赖**: APP-011
- **描述**: 支持iOS原生画中画（Picture in Picture），用户退出播放器或切到后台时视频以小窗形式继续播放。
- **技术要点**: 
  - 使用AVPictureInPictureController
  - 需要在Info.plist配置Audio Background Mode
  - 需要设置AVAudioSession为playback类别
  - 画中画启动时机：用户主动点击PiP按钮 或 App进入后台自动启动
  - 点击画中画恢复按钮时回到播放器页面
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPiPManager.h/.m` (新建)
  - `redredvideo/Modules/Player/RRVPlayerVC.h/.m` (修改)
  - `Info.plist` (修改，添加Background Mode)
- **验收标准**:
  - [ ] 播放器中显示画中画按钮
  - [ ] 点击后进入画中画模式
  - [ ] 退出App后画中画继续播放
  - [ ] 点击恢复按钮回到App播放器
  - [ ] iPad分屏模式下画中画正常

---

### APP-020 后台播放
- **优先级**: P3
- **预估工时**: 0.5天
- **依赖**: APP-011, APP-019
- **描述**: 支持App进入后台后继续播放音频（短剧场景较少用，但部分用户有需求）。在控制中心显示播放控制。
- **技术要点**: 
  - AVAudioSession设为playback类别
  - Info.plist添加audio background mode
  - 使用MPNowPlayingInfoCenter设置锁屏信息（标题、封面、进度）
  - 使用MPRemoteCommandCenter响应控制中心的播放/暂停/上下集
- **涉及文件**: 
  - `redredvideo/Modules/Player/RRVPlayerManager.h/.m` (修改)
  - `redredvideo/Modules/Player/RRVRemoteCommandHandler.h/.m` (新建)
  - `Info.plist` (修改)
- **验收标准**:
  - [ ] App进入后台后音频继续播放
  - [ ] 锁屏界面显示剧名和封面
  - [ ] 控制中心可控制播放/暂停
  - [ ] 控制中心可切换上下集

---

## 4. 广告系统

### APP-021 前贴片广告播放器
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: APP-011, API-012
- **描述**: 在正片播放前插入前贴片广告（Pre-roll）。广告来源从API-012接口获取，支持视频广告和图片广告。广告播放完毕或用户跳过后开始正片。
- **技术要点**: 
  - 广告播放器独立于正片播放器，使用单独的AVPlayer实例
  - 广告播放时隐藏正片控件，显示广告UI（倒计时+跳过按钮+广告标识）
  - 视频广告使用独立AVPlayerItem播放
  - 图片广告使用UIImageView + 定时器（展示N秒）
  - 广告展示事件上报API-013
  - 广告素材预加载（在加载正片时并行下载广告素材）
- **涉及文件**: 
  - `redredvideo/Modules/Player/Ads/RRVAdPlayerView.h/.m` (新建)
  - `redredvideo/Modules/Player/Ads/RRVAdManager.h/.m` (新建)
  - `redredvideo/Modules/Player/Ads/Models/RRVAdModel.h/.m` (新建)
- **验收标准**:
  - [ ] 正片播放前展示广告
  - [ ] 广告播放完毕自动进入正片
  - [ ] 显示"广告"标识和倒计时
  - [ ] 广告展示/点击事件正确上报
  - [ ] 无广告配置时直接播放正片

---

### APP-022 中插广告
- **优先级**: P1
- **预估工时**: 1.5天
- **依赖**: APP-021, API-012
- **描述**: 在正片播放过程中，根据服务端配置在指定时间点插入中插广告（Mid-roll）。如配置"第30秒插入广告"，则播放到30秒时暂停正片，播放广告。
- **技术要点**: 
  - 从API-012获取中插广告时间点数组（如[30, 60, 120]）
  - 使用AVPlayer addBoundaryTimeObserver在指定时间点触发
  - 触发后暂停正片 → 播放广告 → 广告结束恢复正片
  - 已触发过的广告不重复触发（seek回去不触发）
  - 复用RRVAdPlayerView组件
- **涉及文件**: 
  - `redredvideo/Modules/Player/Ads/RRVMidrollAdController.h/.m` (新建)
  - `redredvideo/Modules/Player/Ads/RRVAdManager.h/.m` (修改)
- **验收标准**:
  - [ ] 在配置时间点准确插入广告
  - [ ] 广告结束后从暂停位置继续正片
  - [ ] seek跳过广告点不会触发广告
  - [ ] 已触发的广告不重复
  - [ ] 进度条上标记广告点位

---

### APP-023 后贴片广告
- **优先级**: P2
- **预估工时**: 1天
- **依赖**: APP-021
- **描述**: 在正片播放结束后、自动切下一集前插入后贴片广告（Post-roll）。
- **技术要点**: 
  - 监听AVPlayerItemDidPlayToEndTime通知
  - 正片结束 → 播放后贴片 → 自动切下一集
  - 后贴片通常较短（5-15秒）
  - 用户在后贴片期间可选择跳过直接进下一集
  - 复用RRVAdPlayerView
- **涉及文件**: 
  - `redredvideo/Modules/Player/Ads/RRVPostrollAdController.h/.m` (新建)
- **验收标准**:
  - [ ] 正片结束后展示后贴片广告
  - [ ] 广告结束后自动进入下一集
  - [ ] 用户可跳过后贴片
  - [ ] 最后一集结束后正常处理（无下一集）

---

### APP-024 广告频控逻辑
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: APP-021, APP-022, APP-023
- **描述**: 实现广告频率控制，避免过度广告影响用户体验。例如：每3集展示一次前贴片、中插广告每集最多1次、会员减半展示等。
- **技术要点**: 
  - 频控规则从服务端API-012配置
  - 本地维护广告展示计数器（session级别 + 持久化级别）
  - 规则示例：preroll_interval=3（每3集一次）、midroll_max_per_episode=1
  - 新用户首N集不展示广告（冷启动保护）
  - 频控状态每次播放集时检查
- **涉及文件**: 
  - `redredvideo/Modules/Player/Ads/RRVAdFrequencyController.h/.m` (新建)
- **验收标准**:
  - [ ] 广告展示频率符合服务端配置
  - [ ] 新用户冷启动保护生效
  - [ ] 频控计数器在session结束后正确重置/持久化
  - [ ] 会员频控策略与普通用户不同

---

### APP-025 广告跳过按钮
- **优先级**: P1
- **预估工时**: 0.5天
- **依赖**: APP-021
- **描述**: 广告播放时右下角显示跳过按钮，倒计时N秒（如5秒）后按钮变为可点击，点击后跳过广告进入正片。
- **技术要点**: 
  - 倒计时N秒由广告配置决定（skipAfterSeconds字段）
  - 倒计时中显示"N秒后可跳过"（不可点击态）
  - 倒计时结束显示"跳过广告"（可点击态）
  - 部分广告不可跳过（skipAfterSeconds = -1）
  - 跳过事件需上报（用于广告收益计算）
- **涉及文件**: 
  - `redredvideo/Modules/Player/Ads/Views/RRVAdSkipButton.h/.m` (新建)
  - `redredvideo/Modules/Player/Ads/RRVAdPlayerView.h/.m` (修改)
- **验收标准**:
  - [ ] 倒计时正确显示
  - [ ] 倒计时结束后按钮可点击
  - [ ] 点击跳过后正确进入正片
  - [ ] 不可跳过的广告隐藏跳过按钮
  - [ ] 跳过事件正确上报

---

### APP-026 广告与付费/会员互斥逻辑
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: APP-021, APP-027, APP-030
- **描述**: 实现广告与付费/会员状态的互斥：VIP会员免广告或减少广告、已购集不展示广告、付费前可通过"看广告解锁"免费观看等。
- **技术要点**: 
  - 播放前检查用户VIP状态（API-016）和购买状态
  - VIP用户：完全跳过广告 或 仅展示品牌广告
  - 已购集：跳过该集所有广告
  - "看广告解锁"模式：展示激励视频广告后免费解锁该集（时效性）
  - 激励视频广告对接第三方SDK（穿山甲/优量汇等）
- **涉及文件**: 
  - `redredvideo/Modules/Player/Ads/RRVAdPolicyManager.h/.m` (新建)
  - `redredvideo/Modules/Player/Ads/RRVRewardAdManager.h/.m` (新建)
- **验收标准**:
  - [ ] VIP用户不展示广告
  - [ ] 已购集不展示广告
  - [ ] "看广告解锁"功能正常
  - [ ] 激励视频看完后正确解锁
  - [ ] 各种边界情况（VIP过期、购买退款）正确处理

---

## 5. 付费系统

### APP-027 付费墙UI
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: APP-007, APP-011
- **描述**: 当用户点击付费集时弹出付费墙，展示购买选项：单集购买（X金币）、全集购买（Y金币，标注优惠）、会员解锁（开通VIP免费看）。
- **技术要点**: 
  - 底部弹出面板（UIView + 动画），半透明背景
  - 三种购买选项卡片式排列
  - 价格信息从API-004集数信息中获取
  - 全集购买标注"省XX%"
  - 已购单集时全集购买显示"补差价"
  - 购买按钮点击后调起支付流程
- **涉及文件**: 
  - `redredvideo/Modules/Pay/RRVPaywallView.h/.m` (新建)
  - `redredvideo/Modules/Pay/RRVPaywallVC.h/.m` (新建)
  - `redredvideo/Modules/Pay/Models/RRVPayOption.h/.m` (新建)
- **验收标准**:
  - [ ] 点击付费集正确弹出付费墙
  - [ ] 展示单集/全集/会员三种选项
  - [ ] 价格信息正确
  - [ ] 全集购买显示优惠信息
  - [ ] 点击购买按钮触发对应支付流程
  - [ ] 关闭付费墙返回播放器

---

### APP-028 IAP支付流程（Apple Pay集成）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: APP-027, API-014, API-015
- **描述**: 实现Apple In-App Purchase支付全流程。虚拟货币充值和会员订阅必须走IAP，符合Apple审核要求。
- **技术要点**: 
  - StoreKit框架集成
  - 支付流程：创建订单(API-014) → 调起IAP → 支付成功拿到receipt → 服务端验证(API-015) → 发货
  - 处理各种异常：支付取消、支付失败、网络断开、receipt验证失败
  - 未完成交易恢复（App启动时检查pendingTransactions）
  - 沙盒测试环境配置
  - SKPaymentQueue观察者必须在App启动时注册
- **涉及文件**: 
  - `redredvideo/Modules/Pay/RRVIAPManager.h/.m` (新建)
  - `redredvideo/Modules/Pay/RRVIAPProductManager.h/.m` (新建)
  - `redredvideo/Modules/Pay/Models/RRVOrderModel.h/.m` (新建)
  - `AppDelegate.m` (修改，注册SKPaymentQueue observer)
- **验收标准**:
  - [ ] IAP商品正确展示（价格从App Store Connect获取）
  - [ ] 支付流程完整走通（沙盒环境）
  - [ ] 支付成功后服务端验证通过并发货
  - [ ] 支付失败/取消有明确提示
  - [ ] 未完成交易能够恢复
  - [ ] 掉单率 < 1%（异常情况补单机制）

---

### APP-029 充值中心
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: APP-028
- **描述**: 虚拟货币（金币/乐币）充值页面。展示多个充值档位（如6元=60金币、30元=330金币赠30等），首充双倍等促销信息。
- **技术要点**: 
  - 充值档位从服务端获取（支持运营动态配置）
  - 每个档位显示：价格、金币数、赠送数、标签（如"最热"、"首充翻倍"）
  - 选择档位后调IAP支付
  - 充值记录展示
  - 金币余额实时刷新
- **涉及文件**: 
  - `redredvideo/Modules/Pay/Recharge/RRVRechargeVC.h/.m` (新建)
  - `redredvideo/Modules/Pay/Recharge/Views/RRVRechargeOptionCell.h/.m` (新建)
  - `redredvideo/Modules/Pay/Recharge/RRVCoinManager.h/.m` (新建)
- **验收标准**:
  - [ ] 充值档位正确展示
  - [ ] 赠送和促销信息清晰
  - [ ] 充值成功后金币余额即时更新
  - [ ] 充值记录可查看
  - [ ] 首充双倍仅首次生效

---

### APP-030 会员订阅页面
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: APP-028
- **描述**: VIP会员订阅页面，展示会员权益说明、订阅方案（月/季/年）、价格、自动续费协议等。使用IAP的自动续费订阅类型。
- **技术要点**: 
  - IAP Subscription类型商品
  - 展示：权益列表（免广告/全剧免费/专属标识等）
  - 订阅方案：月卡/季卡/年卡，推荐年卡（标注"最划算"）
  - 自动续费提示和协议链接（合规必须）
  - 恢复购买按钮
  - 管理订阅跳转系统设置
- **涉及文件**: 
  - `redredvideo/Modules/Pay/VIP/RRVVIPSubscribeVC.h/.m` (新建)
  - `redredvideo/Modules/Pay/VIP/Views/RRVVIPBenefitView.h/.m` (新建)
  - `redredvideo/Modules/Pay/VIP/Views/RRVVIPPlanCell.h/.m` (新建)
- **验收标准**:
  - [ ] 会员权益清晰展