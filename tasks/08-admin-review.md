# 08 — 内容审核后台 Web端

> React + Ant Design Pro | 共 10 个任务

---

## 1. 审核工作台

### REV-001 审核工作台主页
- **优先级**: P0
- **预估工时**: 2.5天
- **依赖**: ADM-002
- **描述**: 审核员的核心工作台页面。展示待审核任务队列（按优先级排序）、审核统计看板（今日待审/已审/通过率）、快捷操作入口。支持审核员领取任务和自动分配两种模式。
- **技术要点**: 
  - 待审队列：按提交时间+优先级排序，展示缩略图+标题+类型+提交者
  - 任务领取模式：审核员主动领取 / 系统按负载均衡自动分配
  - 审核计时：记录每条内容的审核耗时
  - 实时刷新：WebSocket / 轮询方式实时更新待审数量
  - 统计看板：今日待审、已审、通过数、拒绝数、平均审核耗时
- **涉及文件**: 
  - `admin-web/src/pages/Review/Dashboard/index.tsx` (新建)
  - `admin-web/src/pages/Review/Dashboard/components/TaskQueue.tsx` (新建)
  - `admin-web/src/pages/Review/Dashboard/components/ReviewStats.tsx` (新建)
  - `admin-web/src/services/review.ts` (新建)
  - `server/controllers/admin_review_controller.go` (新建)
  - `server/services/review_assign_service.go` (新建)
- **验收标准**:
  - [ ] 待审队列按优先级正确排序
  - [ ] 审核员可领取/被分配审核任务
  - [ ] 统计看板数据实时准确
  - [ ] 多审核员同时操作无冲突（乐观锁）
  - [ ] 页面加载流畅，队列实时更新

---

### REV-002 视频内容审核页
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: REV-001
- **描述**: 视频内容审核详情页：内嵌视频播放器（支持倍速/逐帧/截图）、AI预审结果展示（标注可疑时间点）、审核操作面板（通过/拒绝/打回修改+拒绝原因选择）、审核历史记录。
- **技术要点**: 
  - 视频播放器：基于 Video.js 或 xgplayer，支持1x/1.5x/2x倍速
  - AI标注展示：在进度条上标注AI检测到的可疑时间点（红色标记），点击跳转
  - AI预审信息面板：违规类型、置信度、截图证据
  - 审核操作：通过 / 拒绝（选择拒绝原因+补充说明）/ 打回修改
  - 批注功能：审核员可在视频特定时间点添加批注
  - 快捷键支持：空格暂停、←→快进快退、数字键快速审核
- **涉及文件**: 
  - `admin-web/src/pages/Review/VideoReview/index.tsx` (新建)
  - `admin-web/src/pages/Review/VideoReview/components/VideoPlayer.tsx` (新建)
  - `admin-web/src/pages/Review/VideoReview/components/AIResultPanel.tsx` (新建)
  - `admin-web/src/pages/Review/VideoReview/components/ReviewActions.tsx` (新建)
  - `admin-web/src/pages/Review/VideoReview/components/AnnotationList.tsx` (新建)
- **验收标准**:
  - [ ] 视频播放器正常加载，支持倍速播放
  - [ ] AI标注在进度条上正确展示，点击可跳转
  - [ ] 审核操作（通过/拒绝/打回）功能完整
  - [ ] 拒绝时必须选择原因
  - [ ] 快捷键操作流畅
  - [ ] 审核结果提交后自动加载下一条待审内容

---

### REV-003 AI智能预审系统
- **优先级**: P0
- **预估工时**: 4天
- **依赖**: 无
- **描述**: 基于AI的内容自动预审系统，对上传的视频/图片/文字进行多维度合规检测。检测维度：涉黄涉暴、政治敏感、版权风险、广告软文、未成年保护。输出风险等级和详细报告，高风险自动拦截，中风险标记人工复审。
- **技术要点**: 
  - 视频审核：抽帧（每秒1帧关键帧）→ 图片审核 + 音频转文字 → 文本审核
  - 图片审核：对接阿里云/腾讯云内容安全API（涉黄、涉暴、涉政、广告）
  - 文本审核：敏感词库匹配 + NLP语义分析（讽刺、隐喻检测）
  - 自建补充模型：针对短剧场景微调的NSFW分类模型（提升召回率）
  - 风险等级：高（自动拦截）、中（人工复审）、低（自动通过）
  - 审核报告：每个维度的检测结果、置信度、证据截图/片段
- **涉及文件**: 
  - `server/services/ai_review/review_pipeline.go` (新建)
  - `server/services/ai_review/video_review.go` (新建)
  - `server/services/ai_review/image_review.go` (新建)
  - `server/services/ai_review/text_review.go` (新建)
  - `server/services/ai_review/risk_evaluator.go` (新建)
  - `server/models/review_result.go` (新建)
  - `server/config/sensitive_words.go` (新建)
- **验收标准**:
  - [ ] 视频上传后自动触发AI预审
  - [ ] 涉黄/涉暴内容检测准确率 > 95%
  - [ ] 高风险内容自动拦截，不进入人工队列
  - [ ] 中风险内容标记并进入人工复审队列
  - [ ] 审核报告包含证据截图和时间点
  - [ ] 单视频预审耗时 < 视频时长的50%

---

### REV-004 AI审核结果学习与反馈
- **优先级**: P1
- **预估工时**: 2.5天
- **依赖**: REV-003
- **描述**: 人工审核结果反馈给AI模型的闭环机制。收集人工审核对AI预审结果的纠正（误判/漏判），定期将反馈数据用于模型微调或规则优化，持续提升AI审核准确率。
- **技术要点**: 
  - 反馈收集：人工审核时标记AI判断是否正确（确认/纠正）
  - 反馈数据存储：`ai_review_feedbacks` 表记录每次纠正
  - 误判分析报表：按维度统计误判率、漏判率
  - 规则热更新：敏感词库、阈值参数支持在线更新
  - 模型微调管线（预留）：收集足够样本后触发微调训练
  - 审核一致性检测：对同一内容分发给多人审核，检测一致性
- **涉及文件**: 
  - `admin-web/src/pages/Review/AIFeedback/index.tsx` (新建)
  - `admin-web/src/pages/Review/AIFeedback/components/FeedbackStats.tsx` (新建)
  - `server/services/ai_review/feedback_service.go` (新建)
  - `server/services/ai_review/rule_updater.go` (新建)
  - `server/models/ai_review_feedback.go` (新建)
- **验收标准**:
  - [ ] 审核员可标记AI判断正确/错误
  - [ ] 误判分析报表按维度统计正确
  - [ ] 敏感词库支持在线增删改
  - [ ] 阈值参数调整后即时生效
  - [ ] 反馈数据可导出用于模型训练

---

## 2. 审核规则与流程

### REV-005 审核规则与敏感词管理
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: REV-003
- **描述**: 管理审核规则体系：敏感词库（分级分类管理）、审核策略配置（各维度阈值、自动处置规则）、审核流程配置（是否需要二审、特殊内容加急审核）。
- **技术要点**: 
  - 敏感词管理：分类（政治/色情/暴力/广告/其他）、分级（禁用词/警告词）
  - 敏感词导入导出：支持Excel批量导入
  - 同义词/变体词管理：自动检测谐音、拼音、特殊字符变体
  - 审核策略：各检测维度的置信度阈值可配置
  - 审核流程：一审直接决定 / 一审+二审复核 / 特殊类型强制二审
- **涉及文件**: 
  - `admin-web/src/pages/Review/Rules/SensitiveWords/index.tsx` (新建)
  - `admin-web/src/pages/Review/Rules/Strategy/index.tsx` (新建)
  - `admin-web/src/pages/Review/Rules/Workflow/index.tsx` (新建)
  - `admin-web/src/services/reviewRule.ts` (新建)
  - `server/controllers/admin_review_rule_controller.go` (新建)
  - `server/services/sensitive_word_service.go` (新建)
- **验收标准**:
  - [ ] 敏感词增删改查功能完整
  - [ ] 支持Excel批量导入敏感词
  - [ ] 审核策略阈值可调整并即时生效
  - [ ] 审核流程配置（一审/二审）正常流转
  - [ ] 变体词检测覆盖常见绕过手段

---

### REV-006 二审复核与仲裁
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: REV-002
- **描述**: 二审复核机制：一审拒绝的内容可申诉进入二审、特定类型内容强制二审、一审通过但被举报的内容进入复审。仲裁机制：一审二审结论不一致时进入主管仲裁。
- **技术要点**: 
  - 二审队列：独立于一审队列，仅高级审核员可见
  - 申诉入口：合作方在Portal提交申诉 → 进入二审队列
  - 强制二审：配置哪些分类/关键词命中时强制二审
  - 仲裁流程：一审二审结论不一致 → 自动进入仲裁 → 主管裁定
  - 审核链路追踪：完整记录一审→二审→仲裁的全流程
- **涉及文件**: 
  - `admin-web/src/pages/Review/SecondReview/index.tsx` (新建)
  - `admin-web/src/pages/Review/Arbitration/index.tsx` (新建)
  - `admin-web/src/pages/Review/SecondReview/components/AppealDetail.tsx` (新建)
  - `server/services/review_workflow_service.go` (新建)
  - `server/models/review_appeal.go` (新建)
- **验收标准**:
  - [ ] 一审拒绝的内容可通过申诉进入二审
  - [ ] 强制二审规则配置后正确触发
  - [ ] 一二审不一致时自动进入仲裁
  - [ ] 审核链路完整可追溯
  - [ ] 仲裁结果为最终结论

---

## 3. 举报与合规

### REV-007 用户举报处理
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: REV-001
- **描述**: 处理App端用户举报的内容：举报工单列表、举报详情（举报原因+被举报内容+举报人信息）、处理操作（确认违规→下架/删除/封号 / 驳回举报）、举报统计分析。
- **技术要点**: 
  - 举报工单列表：按举报类型、处理状态、时间筛选
  - 同一内容多次举报合并展示（聚合举报）
  - 举报优先级：相同内容举报数越多优先级越高
  - 处理操作：确认违规（下架内容/警告发布者/封禁发布者）/ 驳回
  - 恶意举报检测：频繁举报同一用户/内容的标记为可疑
  - 举报统计：举报量趋势、举报类型分布、处理时效
- **涉及文件**: 
  - `admin-web/src/pages/Review/Report/index.tsx` (新建)
  - `admin-web/src/pages/Review/Report/components/ReportDetail.tsx` (新建)
  - `admin-web/src/pages/Review/Report/components/ReportStats.tsx` (新建)
  - `admin-web/src/services/report.ts` (新建)
  - `server/controllers/admin_report_controller.go` (新建)
- **验收标准**:
  - [ ] 举报工单列表支持筛选和排序
  - [ ] 同一内容多次举报正确聚合
  - [ ] 确认违规后内容自动下架
  - [ ] 恶意举报用户被标记
  - [ ] 举报统计图表正常

---

### REV-008 版权核查工具
- **优先级**: P1
- **预估工时**: 2.5天
- **依赖**: REV-003
- **描述**: 辅助审核员进行版权核查的工具集：视频指纹比对（检测盗版/搬运）、版权证明文件管理（授权书上传与校验）、版权投诉处理（DMCA流程）。
- **技术要点**: 
  - 视频指纹：基于pHash/感知哈希的视频帧指纹，与库内已有内容比对
  - 相似度检测：对比结果展示相似片段的时间点对应关系
  - 版权文件管理：合作方上传授权书/版权证明，审核员校验
  - AI辅助校验：OCR提取版权文件中的关键信息（授权方、授权范围、有效期）
  - DMCA流程：版权投诉接收→核实→下架→反通知→恢复
- **涉及文件**: 
  - `admin-web/src/pages/Review/Copyright/index.tsx` (新建)
  - `admin-web/src/pages/Review/Copyright/components/FingerprintCompare.tsx` (新建)
  - `admin-web/src/pages/Review/Copyright/components/LicenseVerify.tsx` (新建)
  - `server/services/ai_review/fingerprint_service.go` (新建)
  - `server/services/ai_review/ocr_service.go` (新建)
  - `server/models/copyright_claim.go` (新建)
- **验收标准**:
  - [ ] 视频指纹比对能检出高相似度内容
  - [ ] 版权文件上传和管理功能完整
  - [ ] AI-OCR可提取版权文件关键信息
  - [ ] DMCA投诉处理流程完整
  - [ ] 比对结果可视化展示相似片段

---

## 4. 审核质量

### REV-009 审核质量监控
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: REV-002
- **描述**: 审核质量监控体系：审核员绩效统计（审核量、准确率、速度）、质检抽查（随机抽取已审内容复查）、审核一致性评估、质量评分排名。
- **技术要点**: 
  - 审核员绩效：每人每日审核量、平均耗时、通过率、被推翻率
  - 质检抽查：按比例随机抽取已审内容，由质检员复查
  - 质检结果：与原审核结论对比，计算准确率
  - 一致性评估：同一内容分配给多人审核，计算Kappa系数
  - 质量看板：审核员排名、质量趋势图、异常告警
- **涉及文件**: 
  - `admin-web/src/pages/Review/Quality/index.tsx` (新建)
  - `admin-web/src/pages/Review/Quality/components/PerformanceTable.tsx` (新建)
  - `admin-web/src/pages/Review/Quality/components/QualityChart.tsx` (新建)
  - `admin-web/src/pages/Review/Quality/components/SpotCheck.tsx` (新建)
  - `server/controllers/admin_review_quality_controller.go` (新建)
  - `server/services/review_quality_service.go` (新建)
- **验收标准**:
  - [ ] 审核员绩效数据统计准确
  - [ ] 质检抽查可随机抽取并分配给质检员
  - [ ] 质检结果与原审核结论自动对比
  - [ ] 质量看板图表正常展示
  - [ ] 准确率低于阈值的审核员自动告警

---

### REV-010 审核数据报表
- **优先级**: P2
- **预估工时**: 1.5天
- **依赖**: REV-009
- **描述**: 审核业务数据报表：审核量趋势、各类型内容分布、审核通过率趋势、AI vs 人工审核对比、平均审核时效、审核积压预警。支持日报/周报/月报自动生成和导出。
- **技术要点**: 
  - 报表维度：时间趋势、内容类型分布、审核结论分布
  - AI审核对比：AI预审准确率、人工纠正率、AI节省的人力
  - 积压预警：待审数量超过阈值时自动告警（邮件/钉钉通知）
  - 报表自动生成：每日凌晨定时生成昨日报表
  - 导出：PDF报表 + Excel明细数据
- **涉及文件**: 
  - `admin-web/src/pages/Review/Report/ReviewReport/index.tsx` (新建)
  - `admin-web/src/pages/Review/Report/ReviewReport/components/TrendChart.tsx` (新建)
  - `admin-web/src/pages/Review/Report/ReviewReport/components/AICompareChart.tsx` (新建)
  - `server/controllers/admin_review_report_controller.go` (新建)
  - `server/jobs/review_report_job.go` (新建)
- **验收标准**:
  - [ ] 审核量趋势图按日/周/月展示正确
  - [ ] AI vs 人工审核对比数据准确
  - [ ] 积压超过阈值时触发告警通知
  - [ ] 日报/周报/月报自动生成
  - [ ] 报表支持PDF和Excel导出
