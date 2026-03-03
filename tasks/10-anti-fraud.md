# 10 — 反作弊与风控

> 后端服务 (Node.js/Python + Redis + Kafka) | 共 10 个任务

---

## 1. 设备与播放识别

### FRD-001 设备指纹生成算法（IDFA/IDFV+硬件特征+IP组合哈希）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: EVT-001
- **描述**: 设计并实现设备唯一标识算法。综合IDFA（广告标识符，用户可能关闭）、IDFV（供应商标识符）、硬件特征（屏幕分辨率、设备型号、系统版本、存储容量）和IP地址，生成稳定的设备指纹哈希值。即使用户重装App或关闭IDFA，仍能以高概率识别同一设备。
- **技术要点**: 
  - iOS端采集维度：
    - IDFA（ATT授权后获取）、IDFV（始终可用）
    - 设备型号（iPhone15,2）、系统版本（iOS 17.2）
    - 屏幕分辨率、屏幕亮度范围
    - 总存储容量（精确到GB级别）
    - 系统启动时间（kern.boottime）
    - 已安装字体列表哈希
    - 网络接口MAC地址哈希（受限但可尝试）
  - 指纹生成：多维度特征向量 → 归一化 → SHA-256哈希
  - 模糊匹配：允许1-2个维度变化（如IP变更、系统升级），使用相似度算法（SimHash）
  - 后端存储：device_fingerprints表，记录指纹哈希、各维度原始值、首次/最近出现时间
  - 指纹碰撞率：目标 < 0.001%（百万级设备）
  - 隐私合规：ATT弹窗引导、隐私政策声明，不采集通讯录/照片等敏感信息
- **涉及文件**: 
  - `redredvideo/AntiCheat/RRVDeviceFingerprint.h/.m` (新建)
  - `redredvideo/AntiCheat/RRVFingerprintCollector.h/.m` (新建)
  - `server/services/fingerprint.service.ts` (新建)
  - `server/models/device_fingerprint.model.ts` (新建)
  - `server/utils/simhash.util.ts` (新建)
- **验收标准**:
  - [ ] 同一设备重复生成指纹一致性 > 99.9%
  - [ ] 不同设备指纹碰撞率 < 0.001%
  - [ ] 关闭IDFA后仍可生成有效指纹
  - [ ] 重装App后指纹可关联到同一设备
  - [ ] IP变更不影响设备识别
  - [ ] 符合App Store隐私政策要求

---

### FRD-002 播放有效性判定（时长>=30秒+前台状态+非静音）
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: EVT-005, FRD-001
- **描述**: 定义并实现"有效播放"的判定规则。一次播放同时满足以下条件才计为有效：播放时长≥30秒、App处于前台活跃状态、设备非静音状态。后端对上报的播放事件进行规则校验，无效播放标记但不计入分账统计。
- **技术要点**: 
  - iOS端数据采集：
    - 播放时长：AVPlayer的currentTime变化累计（排除暂停/缓冲时间）
    - 前台状态：UIApplication.shared.applicationState监听，后台播放时间不计入
    - 静音检测：AVAudioSession.outputVolume，音量为0视为静音
    - 播放事件上报：start/heartbeat(每10秒)/end三类事件
  - 后端判定引擎：
    - 接收播放事件流（Kafka消费）
    - 校验规则：duration >= 30s AND foreground == true AND muted == false
    - 判定结果写入play_validations表：valid/invalid + reason
    - 灰度规则：新规则可灰度生效（如调整30秒阈值为20秒）
  - 防客户端篡改：
    - 播放心跳服务端时间校验（客户端上报间隔 vs 服务端接收间隔偏差<3秒）
    - 播放Token机制：起播时服务端签发Token，结束时带回校验
- **涉及文件**: 
  - `redredvideo/AntiCheat/RRVPlayValidator.h/.m` (新建)
  - `redredvideo/Player/RRVPlayerHeartbeat.h/.m` (新建)
  - `server/services/play-validation.service.ts` (新建)
  - `server/consumers/play-event.consumer.ts` (新建)
  - `server/models/play_validation.model.ts` (新建)
  - `server/config/play-rules.config.ts` (新建)
- **验收标准**:
  - [ ] 播放<30秒的事件被标记为无效
  - [ ] 后台播放不计为有效播放
  - [ ] 静音状态播放不计为有效播放
  - [ ] 客户端篡改时长被服务端时间校验拦截
  - [ ] 播放Token校验正常，伪造Token被拒
  - [ ] 判定规则可灰度配置

---

### FRD-003 倍速播放限制策略（>2x不计为有效播放）
- **优先级**: P1
- **预估工时**: 1天
- **依赖**: FRD-002
- **描述**: 对倍速播放进行策略限制。当用户使用超过2倍速播放时，该段时长不计入有效播放。播放心跳需上报当前播放速率，后端根据速率加权计算有效播放时长。同时检测频繁切换倍速的异常行为。
- **技术要点**: 
  - iOS端上报：
    - AVPlayer.rate属性监听，速率变化时上报事件
    - 心跳事件携带当前播放速率（0.5x/1x/1.25x/1.5x/2x/3x）
  - 后端计算：
    - 有效时长加权：1x-2x按实际时长计算，>2x该段时长不计入
    - 示例：用户播放3分钟，其中1分钟为3x倍速，有效时长 = 2分钟
  - 异常检测：
    - 频繁切换倍速（10秒内切换>3次）标记为可疑
    - 全程3x播放整集标记为高风险
  - 配置化：倍速阈值、加权系数可通过配置中心动态调整
- **涉及文件**: 
  - `redredvideo/Player/RRVPlaybackRateTracker.h/.m` (新建)
  - `server/services/playback-rate.service.ts` (新建)
  - `server/config/play-rules.config.ts` (修改，新增倍速规则)
- **验收标准**:
  - [ ] >2x倍速播放时长不计入有效播放
  - [ ] 1x-2x倍速播放按实际时长计算
  - [ ] 频繁切换倍速行为被标记为可疑
  - [ ] 全程高倍速播放整集被标记为高风险
  - [ ] 倍速阈值可动态配置

---

## 2. 异常行为检测

### FRD-004 异常播放行为检测（单设备单日>50集、连续跳集、秒级切换）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: FRD-001, FRD-002
- **描述**: 实现多维度的异常播放行为检测。监控单设备单日播放集数、集与集之间的切换模式、播放完成速度等指标，识别机器刷量、脚本自动播放等作弊行为。检测到异常后实时告警并触发处置流程。
- **技术要点**: 
  - 检测规则：
    - 高频播放：单设备单日播放>50集（正常用户P99 < 30集）
    - 连续跳集：播放序列为1,3,5,7...或1,2,3...但每集仅播放30-35秒（刚好过有效阈值）
    - 秒级切换：两集之间间隔<3秒（正常用户选集、缓冲至少需5-10秒）
    - 规律性播放：每集播放时长方差极小（<2秒），疑似脚本控制
    - 深夜集中播放：凌晨2-6点大量播放
  - 实时计算：
    - Kafka Stream/Flink实时处理播放事件流
    - Redis滑动窗口计数器：设备维度的播放频次统计
    - 时序分析：播放序列的时间间隔分布检测
  - 风险评分：每条规则命中给予不同分值，总分>阈值触发告警
  - 告警输出：写入alert_events表 + 推送至运营后台 + 企业微信通知
- **涉及文件**: 
  - `server/services/anomaly-detection.service.ts` (新建)
  - `server/consumers/play-anomaly.consumer.ts` (新建)
  - `server/detectors/high-frequency.detector.ts` (新建)
  - `server/detectors/skip-pattern.detector.ts` (新建)
  - `server/detectors/rapid-switch.detector.ts` (新建)
  - `server/detectors/regularity.detector.ts` (新建)
  - `server/models/alert_event.model.ts` (新建)
  - `server/utils/sliding-window.util.ts` (新建)
- **验收标准**:
  - [ ] 单设备日播放>50集准确触发告警
  - [ ] 连续跳集模式被识别
  - [ ] 秒级切换行为被检测
  - [ ] 规律性播放（方差极小）被标记
  - [ ] 风险评分准确，误报率<5%
  - [ ] 告警延迟<30秒（从行为发生到告警触发）

---

### FRD-005 同设备多账号检测（设备指纹关联多个UID告警）
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: FRD-001
- **描述**: 检测同一设备上使用多个账号的行为。作弊者常在同一设备上切换多个账号刷量。通过设备指纹关联登录的UID列表，当同一设备关联的活跃账号数超过阈值时产生告警。需区分正常场景（家庭共用设备）和作弊场景。
- **技术要点**: 
  - 关联存储：Redis Set维护 device_fingerprint → Set<uid> 映射
  - 检测逻辑：
    - 软阈值：同设备3个账号 → 标记观察
    - 硬阈值：同设备5个账号 → 产生告警
    - 时间窗口：7天滑动窗口内的活跃账号数
  - 正常场景排除：
    - 家庭设备：账号之间无批量播放行为，播放内容差异大
    - 账号迁移：旧账号停用、新账号启用，非并行使用
  - 关联图谱：构建设备-账号二部图，检测设备群控（多设备关联同一批账号）
  - 处置建议：软阈值 → 增加验证码频率；硬阈值 → 暂停播放计数 + 人工复核
- **涉及文件**: 
  - `server/services/multi-account.service.ts` (新建)
  - `server/detectors/device-account-bindng.detector.ts` (新建)
  - `server/services/device-graph.service.ts` (新建)
  - `server/models/device_account_mapping.model.ts` (新建)
- **验收标准**:
  - [ ] 同设备3+账号被标记观察
  - [ ] 同设备5+账号产生告警
  - [ ] 家庭共用设备场景不误报
  - [ ] 7天滑动窗口正确计算
  - [ ] 设备群控模式被识别
  - [ ] 处置建议正确输出

---

### FRD-006 广告点击异常检测（点击间隔<1秒、同IP高频点击）
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: EVT-009, FRD-001
- **描述**: 检测广告点击环节的作弊行为。广告收入是重要营收来源，点击作弊直接影响广告主信任和平台收益。监控点击间隔、同IP点击频率、点击-展示比率等指标，识别自动点击脚本和刷量行为。
- **技术要点**: 
  - 检测规则：
    - 快速点击：同设备两次广告点击间隔<1秒
    - 高频IP：同IP 1小时内广告点击>100次
    - 异常CTR：某设备/某IP的广告点击率>30%（正常约2-5%）
    - 点击坐标集中：所有点击落在同一像素区域（±5px）
    - 点击-转化不匹配：大量点击但零转化
  - 实时检测：
    - Redis HyperLogLog统计IP维度UV
    - Redis Sorted Set统计时间窗口内的点击序列
    - 实时流处理：Kafka Consumer逐条校验
  - 扣量处理：
    - 实时标记无效点击（is_valid = false）
    - 无效点击不计入广告收入和合作方分账
    - 日终批量校验：与实时结果交叉验证
  - 广告主报表：提供反作弊过滤后的真实数据
- **涉及文件**: 
  - `server/services/ad-click-fraud.service.ts` (新建)
  - `server/detectors/click-interval.detector.ts` (新建)
  - `server/detectors/ip-frequency.detector.ts` (新建)
  - `server/detectors/ctr-anomaly.detector.ts` (新建)
  - `server/consumers/ad-click.consumer.ts` (新建)
  - `server/models/ad_click_validation.model.ts` (新建)
- **验收标准**:
  - [ ] 点击间隔<1秒的点击被标记为无效
  - [ ] 同IP高频点击被检测并标记
  - [ ] 异常CTR设备被识别
  - [ ] 坐标集中的点击被检测
  - [ ] 无效点击不计入分账
  - [ ] 检测延迟<5秒

---

## 3. 结算风控

### FRD-007 结算冻结期实现（T+30窗口期，期间可追溯扣回）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: INF-001, INF-003
- **描述**: 实现T+30结算冻结期机制。合作方的收益在产生后进入30天冻结期，期间风控系统持续对该时段的播放和点击数据进行追溯校验。冻结期内发现的作弊数据可直接扣回。冻结期结束后收益转为可结算状态。
- **技术要点**: 
  - 收益状态流转：待冻结 → 冻结中 → 追溯校验 → 可结算 → 结算中 → 已结算
  - 冻结期计算：
    - 每日收益T日产生 → T+30日解冻
    - 定时任务：每日凌晨扫描到期的冻结收益，批量解冻
  - 追溯扣回机制：
    - 冻结期内发现作弊 → 创建扣回记录（关联原始播放事件ID）
    - 扣回金额从冻结收益中直接扣除
    - 扣回超过冻结余额 → 从后续收益中抵扣（设置每期最大抵扣比例50%）
  - 数据模型：
    - partner_revenue_daily：每日收益汇总（冻结金额、已扣回金额、可结算金额）
    - revenue_deductions：扣回记录（原因、金额、关联作弊事件）
  - 合作方可见：Portal上展示冻结金额、预计解冻时间、扣回明细
  - 告警：单日扣回金额>收益50%时告警通知运营
- **涉及文件**: 
  - `server/services/settlement-freeze.service.ts` (新建)
  - `server/services/revenue-deduction.service.ts` (新建)
  - `server/jobs/freeze-expiry.job.ts` (新建)
  - `server/jobs/retroactive-audit.job.ts` (新建)
  - `server/models/partner_revenue_daily.model.ts` (新建)
  - `server/models/revenue_deduction.model.ts` (新建)
- **验收标准**:
  - [ ] 每日收益自动进入30天冻结期
  - [ ] 冻结期内作弊扣回正确执行
  - [ ] 冻结到期后自动转为可结算
  - [ ] 扣回超过冻结余额时从后续收益抵扣
  - [ ] 每期抵扣不超过50%上限
  - [ ] Portal正确展示冻结和扣回信息

---

### FRD-008 合作方信用分系统（基于作弊率/投诉率/内容质量评分）
- **优先级**: P2
- **预估工时**: 3天
- **依赖**: FRD-004, FRD-006, FRD-007
- **描述**: 建立合作方信用评分体系，综合作弊率、投诉率、内容审核通过率、结算纠纷率等维度计算信用分（0-100分）。信用分影响合作方的结算周期、冻结期长短、分成比例等权益。低信用分合作方受到更严格的风控。
- **技术要点**: 
  - 评分维度与权重：
    - 作弊率（30%）：无效播放占比、广告作弊次数
    - 内容质量（25%）：审核一次通过率、用户投诉率、平均完播率
    - 结算信用（20%）：对账异议率、开票及时率
    - 合作时长（15%）：入驻时间越长基础分越高
    - 活跃度（10%）：内容更新频率、Portal登录频率
  - 评分计算：
    - 每日增量更新，每月全量重算
    - 加权平均 + 归一化到0-100分
    - 历史趋势：记录每日评分，支持趋势分析
  - 信用等级与权益：
    - A级（80-100）：T+15结算、分成比例+2%
    - B级（60-79）：T+30结算、标准分成
    - C级（40-59）：T+45结算、加强风控
    - D级（0-39）：暂停结算、人工复核
  - 通知：评分变动>5分时通知合作方，附带原因分析
- **涉及文件**: 
  - `server/services/credit-score.service.ts` (新建)
  - `server/services/credit-calculator.service.ts` (新建)
  - `server/jobs/credit-score-daily.job.ts` (新建)
  - `server/jobs/credit-score-monthly.job.ts` (新建)
  - `server/models/partner_credit_score.model.ts` (新建)
  - `server/config/credit-weights.config.ts` (新建)
  - `src/pages/Settings/CreditScore/index.tsx` (新建)
- **验收标准**:
  - [ ] 五个维度评分计算正确
  - [ ] 信用等级与权益正确关联
  - [ ] 每日增量更新延迟<5分钟
  - [ ] 评分变动通知合作方
  - [ ] Portal可查看信用分详情和历史趋势
  - [ ] 信用等级影响结算周期生效

---

## 4. 规则引擎与自动化

### FRD-009 风控规则引擎（可配置规则、阈值、处置动作）
- **优先级**: P0
- **预估工时**: 4天
- **依赖**: FRD-004, FRD-005, FRD-006
- **描述**: 构建可配置的风控规则引擎。运营人员可通过后台界面配置风控规则（条件表达式+阈值+处置动作），无需开发人员修改代码。支持规则的灰度发布、A/B测试、版本管理和回滚。规则引擎实时匹配事件流，命中规则后执行对应处置。
- **技术要点**: 
  - 规则DSL设计：
    - 条件表达式：`event.device_play_count_daily > 50 AND event.avg_duration < 35`
    - 支持运算符：>, <, >=, <=, ==, !=, AND, OR, NOT, IN, BETWEEN
    - 支持函数：COUNT(), AVG(), SUM(), DISTINCT_COUNT() 等聚合
    - 时间窗口：LAST_1H, LAST_24H, LAST_7D
  - 规则执行引擎：
    - 基于JSON规则树的解释器（或集成开源引擎如json-rules-engine）
    - 规则优先级：多条规则命中时按优先级执行，支持短路
    - 性能要求：单条事件规则匹配<5ms
  - 规则管理后台：
    - 规则CRUD：名称、描述、条件、处置动作、状态（草稿/灰度/全量/禁用）
    - 灰度发布：按百分比生效（如10%流量）
    - 版本管理：每次修改保留版本号，支持一键回滚
    - 规则测试：输入模拟事件数据，验证规则是否命中
  - 处置动作注册：限流、封禁、标记无效、延迟结算、通知人工复核等
- **涉及文件**: 
  - `server/engine/rule-engine.ts` (新建)
  - `server/engine/rule-parser.ts` (新建)
  - `server/engine/rule-executor.ts` (新建)
  - `server/engine/conditions/index.ts` (新建)
  - `server/engine/actions/index.ts` (新建)
  - `server/controllers/rule-management.controller.ts` (新建)
  - `server/models/risk_rule.model.ts` (新建)
  - `server/models/risk_rule_version.model.ts` (新建)
  - `admin/pages/RiskRules/index.tsx` (新建)
  - `admin/pages/RiskRules/RuleEditor.tsx` (新建)
- **验收标准**:
  - [ ] 规则DSL支持常见运算符和聚合函数
  - [ ] 单条事件规则匹配耗时<5ms
  - [ ] 规则灰度发布按比例生效
  - [ ] 规则版本管理和回滚正常
  - [ ] 模拟事件测试功能可用
  - [ ] 多规则同时命中按优先级执行

---

### FRD-010 风控处置自动化（触发规则→限流/封禁/结算延迟/人工复核）
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: FRD-009
- **描述**: 实现风控规则命中后的自动化处置流程。根据规则配置的处置动作，自动执行限流、封禁账号/设备、延迟结算、标记无效数据、创建人工复核工单等操作。支持处置动作的链式组合和异步执行，处置结果可追溯。
- **技术要点**: 
  - 处置动作类型：
    - 限流：对设备/账号/IP限制请求频率（Redis令牌桶算法）
    - 封禁：设备黑名单（Redis Set）、账号冻结（数据库状态位）
    - 结算延迟：将冻结期从T+30延长至T+60
    - 标记无效：批量标记播放/点击事件为invalid
    - 人工复核：创建工单推送至运营审核队列
    - 通知：企业微信/邮件通知运营人员
  - 链式处置：一条规则可配置多个处置动作按序执行
  - 异步执行：处置动作通过Kafka消息队列异步执行，确保不阻塞检测流程
  - 处置记录：risk_actions表记录每次处置的规则ID、处置类型、目标对象、执行结果、操作时间
  - 解封机制：封禁有时效（如7天），到期自动解封；支持人工提前解封
  - 处置Dashboard：展示实时处置数量、类型分布、命中规则TOP10
- **涉及文件**: 
  - `server/engine/actions/rate-limit.action.ts` (新建)
  - `server/engine/actions/ban.action.ts` (新建)
  - `server/engine/actions/settlement-delay.action.ts` (新建)
  - `server/engine/actions/mark-invalid.action.ts` (新建)
  - `server/engine/actions/manual-review.action.ts` (新建)
  - `server/engine/actions/notify.action.ts` (新建)
  - `server/engine/action-chain.executor.ts` (新建)
  - `server/consumers/risk-action.consumer.ts` (新建)
  - `server/models/risk_action.model.ts` (新建)
  - `server/jobs/auto-unban.job.ts` (新建)
  - `admin/pages/RiskActions/Dashboard.tsx` (新建)
- **验收标准**:
  - [ ] 六种处置动作均可独立执行
  - [ ] 链式处置按配置顺序执行
  - [ ] 异步执行不阻塞检测流程
  - [ ] 处置记录完整可追溯
  - [ ] 封禁到期自动解封
  - [ ] 处置Dashboard数据实时准确
