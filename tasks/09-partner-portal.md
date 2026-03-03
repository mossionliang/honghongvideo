# 09 — 合作方 Portal

> Web端 (React + Ant Design Pro + TypeScript) | 共 11 个任务

---

## 1. 认证与入驻

### PTR-001 合作方注册/登录（手机号+企业邮箱，双因子验证）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: INF-001, INF-010
- **描述**: 实现合作方独立的注册与登录系统。注册支持手机号和企业邮箱两种方式，登录后强制开启双因子验证（TOTP或短信验证码），确保合作方账号安全。注册时需验证企业邮箱域名白名单或手机号实名校验。
- **技术要点**: 
  - 注册流程：手机号/企业邮箱 → 短信/邮箱验证码 → 设置密码 → 完善基本信息
  - 登录方式：密码登录 + 短信验证码登录双通道
  - 双因子验证（2FA）：集成Google Authenticator TOTP算法（speakeasy库），首次登录绑定
  - 密码策略：最少8位，大小写+数字+特殊字符，bcrypt加密存储
  - JWT Token方案：access_token（2h过期）+ refresh_token（7d过期），存储于HttpOnly Cookie
  - 短信服务：对接阿里云短信（模板审核+签名），验证码5分钟有效，60秒发送间隔
  - 邮件服务：对接SendGrid/阿里云邮件推送，验证码15分钟有效
  - 前端使用Ant Design Pro的登录页模板，ProForm表单组件
  - 防暴力破解：验证码5次错误锁定30分钟，IP级别限流
- **涉及文件**: 
  - `src/pages/Auth/Login/index.tsx` (新建)
  - `src/pages/Auth/Register/index.tsx` (新建)
  - `src/pages/Auth/TwoFactor/index.tsx` (新建)
  - `src/services/auth.ts` (新建)
  - `src/utils/token.ts` (新建)
  - `server/controllers/partner-auth.controller.ts` (新建)
  - `server/services/sms.service.ts` (新建)
  - `server/services/email.service.ts` (新建)
  - `server/middlewares/partner-auth.middleware.ts` (新建)
- **验收标准**:
  - [ ] 手机号和企业邮箱均可注册并收到验证码
  - [ ] 密码策略校验生效，弱密码被拒绝
  - [ ] 首次登录强制绑定2FA，后续登录需输入动态码
  - [ ] Token过期后自动刷新，refresh_token过期后跳转登录
  - [ ] 验证码发送频率限制和错误次数锁定正常生效
  - [ ] 登录/注册页面响应式布局，移动端可用

---

### PTR-002 公司入驻申请表单（企业信息、联系人、业务类型）
- **优先级**: P0
- **预估工时**: 2天
- **依赖**: PTR-001
- **描述**: 新注册的合作方需填写公司入驻申请表单，包含企业基本信息（公司名称、统一社会信用代码、注册地址）、联系人信息（姓名、职位、手机号、邮箱）、业务类型（内容提供方/广告代理/发行渠道）。表单支持草稿保存，提交后进入人工审核流程。
- **技术要点**: 
  - 多步骤表单（StepsForm）：企业信息 → 联系人 → 业务类型 → 确认提交
  - 统一社会信用代码校验（18位校验算法）
  - 天眼查/企查查API对接：自动填充企业信息、校验企业真实性
  - 表单草稿：localStorage本地保存 + 后端API草稿保存（5分钟自动保存）
  - 业务类型选择联动：不同类型显示不同的补充字段
  - 提交后生成审核工单（状态：待审核/审核中/已通过/已驳回）
  - 后端：partner_applications表存储申请数据，关联审核流水表
- **涉及文件**: 
  - `src/pages/Onboarding/CompanyForm/index.tsx` (新建)
  - `src/pages/Onboarding/CompanyForm/steps/BasicInfo.tsx` (新建)
  - `src/pages/Onboarding/CompanyForm/steps/ContactInfo.tsx` (新建)
  - `src/pages/Onboarding/CompanyForm/steps/BusinessType.tsx` (新建)
  - `src/pages/Onboarding/CompanyForm/steps/Confirmation.tsx` (新建)
  - `src/services/onboarding.ts` (新建)
  - `server/controllers/partner-application.controller.ts` (新建)
  - `server/models/partner_application.model.ts` (新建)
- **验收标准**:
  - [ ] 四步表单流程完整，可前进/后退/保存草稿
  - [ ] 统一社会信用代码格式校验正确
  - [ ] 企业名称可自动补全（对接第三方企业信息API）
  - [ ] 提交后状态变为"待审核"，可在列表页查看
  - [ ] 被驳回后可重新编辑并再次提交
  - [ ] 草稿自动保存，刷新页面不丢失

---

### PTR-003 资质材料上传页面（营业执照、许可证、版权授权，支持批量上传+进度条）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: PTR-002, INF-004
- **描述**: 合作方入驻需上传企业资质材料，包括营业执照、广播电视节目制作经营许可证、版权授权证明等。支持图片和PDF格式，支持批量拖拽上传，显示实时进度条。上传后支持预览、替换和删除。文件存储至OSS，记录文件元信息用于后续审核。
- **技术要点**: 
  - 前端上传组件：基于Ant Design Upload封装，支持拖拽区域+点击上传
  - 批量上传：并发控制（最多3个同时上传），队列管理
  - 分片上传：大文件（>10MB）自动切片上传至OSS（STS临时凭证直传）
  - 进度条：实时显示每个文件的上传进度百分比
  - 文件格式校验：前端+后端双重校验（JPG/PNG/PDF，单文件<20MB）
  - 图片预览：antd Image组件；PDF预览：react-pdf或iframe
  - OCR识别：对接阿里云OCR识别营业执照关键字段（公司名称、信用代码），自动回填
  - 后端：partner_documents表存储文件元信息（文件名、OSS路径、类型、上传时间、审核状态）
  - 文件防篡改：上传时计算MD5，存储校验
- **涉及文件**: 
  - `src/pages/Onboarding/QualificationUpload/index.tsx` (新建)
  - `src/components/FileUploader/index.tsx` (新建)
  - `src/components/FileUploader/OSSUploader.ts` (新建)
  - `src/components/FilePreview/index.tsx` (新建)
  - `src/services/upload.ts` (新建)
  - `server/controllers/partner-document.controller.ts` (新建)
  - `server/services/oss-sts.service.ts` (新建)
  - `server/services/ocr.service.ts` (新建)
- **验收标准**:
  - [ ] 支持拖拽和点击两种上传方式
  - [ ] 批量上传时每个文件独立显示进度条
  - [ ] 大文件分片上传至OSS，断点续传可用
  - [ ] 文件格式和大小校验前后端一致
  - [ ] 上传完成后可预览图片和PDF
  - [ ] OCR识别营业执照信息并自动回填
  - [ ] 文件MD5校验通过

---

## 2. 合同与内容管理

### PTR-004 合同在线签署（对接电子签章如e签宝/法大大）
- **优先级**: P1
- **预估工时**: 4天
- **依赖**: PTR-002, PTR-003
- **描述**: 入驻审核通过后，系统自动生成合作协议（基于模板填充合作方信息），合作方在线预览合同内容并进行电子签章。对接第三方电子签章服务（e签宝或法大大），实现具有法律效力的在线签署。签署完成后合同PDF归档存储。
- **技术要点**: 
  - 合同模板引擎：基于HTML模板 + 变量占位符，动态填充合作方信息生成合同
  - 电子签章SDK对接（优先e签宝）：
    - 企业实名认证（组织机构代码+法人信息）
    - 创建签署流程 → 上传合同文件 → 设置签署位置 → 获取签署链接
    - Webhook回调接收签署完成事件
  - 合同状态流转：草稿 → 待签署 → 签署中 → 已签署 → 已归档
  - 合同PDF生成：Puppeteer渲染HTML模板为PDF
  - 合同版本管理：续约/变更时保留历史版本
  - 前端：合同预览（PDF.js）、签署按钮跳转至第三方签署页、签署状态实时更新
- **涉及文件**: 
  - `src/pages/Contract/ContractList/index.tsx` (新建)
  - `src/pages/Contract/ContractPreview/index.tsx` (新建)
  - `src/pages/Contract/SignCallback/index.tsx` (新建)
  - `src/services/contract.ts` (新建)
  - `server/controllers/contract.controller.ts` (新建)
  - `server/services/esign.service.ts` (新建)
  - `server/services/pdf-generator.service.ts` (新建)
  - `server/templates/contracts/cooperation-agreement.html` (新建)
  - `server/models/contract.model.ts` (新建)
- **验收标准**:
  - [ ] 审核通过后自动生成合同，合作方可预览
  - [ ] 点击签署后正确跳转至第三方签署页面
  - [ ] 签署完成后Webhook回调正确处理，状态更新为已签署
  - [ ] 签署后的合同PDF可下载，包含电子签章
  - [ ] 合同版本历史可追溯
  - [ ] 异常处理：签署超时、拒签、签章服务不可用等场景

---

### PTR-005 内容上传页面（视频分片上传+元数据表单：剧名/简介/标签/演员/备案号）
- **优先级**: P0
- **预估工时**: 4天
- **依赖**: PTR-004, INF-004, INF-006
- **描述**: 合作方上传短剧内容的核心页面。包含视频文件分片上传和元数据填写两部分。视频支持大文件分片上传（单集可达数GB），元数据表单包括剧名、简介、标签、演员表、备案号等信息。支持一次创建整部剧并批量上传多集视频。
- **技术要点**: 
  - 视频分片上传：
    - 前端使用ali-oss SDK直传OSS，分片大小2MB
    - 断点续传：localStorage记录已上传分片，刷新后可继续
    - 并发上传：同时上传3个分片，队列管理剩余分片
    - 上传前校验：格式（MP4/MOV/MKV）、大小（<5GB/集）、时长（<30min/集）
    - 上传后：自动触发转码任务（INF-006）
  - 元数据表单：
    - 剧集信息：剧名、简介（富文本）、类型标签（多选）、目标受众
    - 演员表：动态增减行，支持搜索已有演员或新建
    - 备案号：广电总局备案号校验格式
    - 分集管理：集数、每集标题、排序拖拽
    - 封面图：支持上传或从视频截取指定帧
  - 批量操作：Excel模板导入元数据，减少手动填写
- **涉及文件**: 
  - `src/pages/Content/Upload/index.tsx` (新建)
  - `src/pages/Content/Upload/VideoUploader.tsx` (新建)
  - `src/pages/Content/Upload/MetadataForm.tsx` (新建)
  - `src/pages/Content/Upload/EpisodeManager.tsx` (新建)
  - `src/pages/Content/Upload/ActorSelector.tsx` (新建)
  - `src/components/ChunkUploader/index.ts` (新建)
  - `src/services/content.ts` (新建)
  - `server/controllers/content-upload.controller.ts` (新建)
  - `server/services/transcode-trigger.service.ts` (新建)
  - `server/models/drama.model.ts` (修改，添加合作方字段)
- **验收标准**:
  - [ ] 视频分片上传正常，2GB以上文件无异常
  - [ ] 断点续传有效，刷新页面后可继续上传
  - [ ] 元数据表单校验完整，必填项不可跳过
  - [ ] 备案号格式校验正确
  - [ ] 批量上传多集视频，每集独立进度条
  - [ ] 上传完成后自动触发转码
  - [ ] Excel模板导入元数据正确解析

---

### PTR-006 上传进度与审核状态追踪（时间轴展示审核流程节点）
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: PTR-005
- **描述**: 合作方上传内容后，提供可视化的审核进度追踪页面。使用时间轴组件展示完整的审核流程节点（上传完成→转码中→机审中→人工初审→人工复审→上线/驳回），每个节点显示时间、操作人、处理意见。支持驳回原因查看和重新提交。
- **技术要点**: 
  - 时间轴组件：基于Ant Design Timeline，自定义节点样式（进行中/已完成/失败）
  - 审核状态轮询：WebSocket实时推送审核进度变更（备选方案：30秒轮询）
  - 审核节点定义：
    - 上传完成 → 转码处理 → AI机审（涉黄/暴力/政治敏感） → 人工初审 → 人工复审 → 最终状态
  - 驳回处理：显示驳回原因 + 标注具体问题帧/时间点，支持合作方修改后重新提交
  - 列表页：所有已上传内容的审核状态汇总（ProTable筛选+排序）
  - 批量操作：批量查看、批量撤回
- **涉及文件**: 
  - `src/pages/Content/AuditTracker/index.tsx` (新建)
  - `src/pages/Content/AuditTracker/AuditTimeline.tsx` (新建)
  - `src/pages/Content/ContentList/index.tsx` (新建)
  - `src/services/audit.ts` (新建)
  - `src/utils/websocket.ts` (新建)
  - `server/controllers/audit-status.controller.ts` (新建)
  - `server/websocket/audit-notify.gateway.ts` (新建)
- **验收标准**:
  - [ ] 时间轴正确展示所有审核节点及当前进度
  - [ ] 状态变更实时推送，无需手动刷新
  - [ ] 驳回原因清晰展示，可定位到具体问题
  - [ ] 重新提交后审核流程重新开始
  - [ ] 列表页支持按状态、日期、剧名筛选
  - [ ] WebSocket断线自动重连

---

## 3. 收益与结算

### PTR-007 收益看板（实时/日/月收益曲线、按剧/按集收益明细）
- **优先级**: P1
- **预估工时**: 3天
- **依赖**: INF-001, PTR-011
- **描述**: 为合作方提供直观的收益数据看板。顶部展示核心指标卡片（今日收益、本月收益、累计收益、待结算金额），中部为收益趋势图（支持切换实时/日/月维度），底部为按剧/按集的收益明细表格。数据来源为分账计算系统的结果。
- **技术要点**: 
  - 图表库：ECharts（@ant-design/charts封装），支持实时数据刷新
  - 核心指标卡片：StatisticCard组件，今日收益30秒刷新
  - 收益趋势图：
    - 实时：最近24小时，5分钟粒度折线图
    - 日维度：最近30/90天，每日收益柱状图
    - 月维度：最近12个月，月度收益趋势
  - 按剧收益：ProTable展示每部剧的播放量、广告收入、付费收入、分成比例、实际收益
  - 按集收益：展开某部剧后显示每集明细（嵌套表格）
  - 数据下钻：点击某天→查看该日按小时分布；点击某剧→查看按集分布
  - 数据缓存：Redis缓存热点查询结果，TTL 5分钟
  - 大数据量处理：后端预聚合日/月维度数据，避免实时大表查询
- **涉及文件**: 
  - `src/pages/Revenue/Dashboard/index.tsx` (新建)
  - `src/pages/Revenue/Dashboard/RevenueCards.tsx` (新建)
  - `src/pages/Revenue/Dashboard/RevenueTrend.tsx` (新建)
  - `src/pages/Revenue/Dashboard/RevenueByDrama.tsx` (新建)
  - `src/pages/Revenue/Dashboard/RevenueByEpisode.tsx` (新建)
  - `src/services/revenue.ts` (新建)
  - `server/controllers/partner-revenue.controller.ts` (新建)
  - `server/services/revenue-aggregation.service.ts` (新建)
- **验收标准**:
  - [ ] 核心指标卡片数据准确，30秒自动刷新
  - [ ] 三种时间维度切换正常，图表渲染流畅
  - [ ] 按剧/按集明细数据与实际分账结果一致
  - [ ] 数据下钻交互流畅
  - [ ] 大数据量下页面加载时间<2秒
  - [ ] 多租户数据隔离，只能看到自己的收益

---

### PTR-008 对账单查看与下载（PDF/Excel导出）
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: PTR-007
- **描述**: 合作方可查看月度对账单，包含该月所有收益明细（按剧汇总、广告收入明细、付费收入明细、扣款明细、应结金额）。支持在线预览和导出为PDF/Excel格式下载。对账单需双方确认后进入结算流程。
- **技术要点**: 
  - 对账单列表：按月展示，状态（待确认/已确认/有异议/已结算）
  - 对账单详情页：
    - 收入汇总：广告收入、付费收入、其他收入
    - 扣款明细：作弊扣量、税费、服务费
    - 按剧明细：每部剧的收益拆分
    - 应结金额 = 总收入 - 扣款
  - PDF导出：后端使用Puppeteer渲染HTML模板为PDF，包含公司抬头和印章
  - Excel导出：后端使用exceljs库生成带格式的Excel，多Sheet（汇总+明细）
  - 异议处理：合作方可针对具体条目提出异议，关联客服工单
  - 对账单确认：合作方点击确认后锁定数据，不可修改
- **涉及文件**: 
  - `src/pages/Revenue/Statements/index.tsx` (新建)
  - `src/pages/Revenue/Statements/StatementDetail.tsx` (新建)
  - `src/pages/Revenue/Statements/DisputeForm.tsx` (新建)
  - `src/services/statement.ts` (新建)
  - `server/controllers/statement.controller.ts` (新建)
  - `server/services/pdf-export.service.ts` (新建)
  - `server/services/excel-export.service.ts` (新建)
  - `server/templates/statements/monthly-statement.html` (新建)
- **验收标准**:
  - [ ] 月度对账单按时自动生成
  - [ ] 对账单明细数据准确，与收益看板一致
  - [ ] PDF导出格式规范，包含公司抬头
  - [ ] Excel导出包含汇总和明细两个Sheet
  - [ ] 异议提交后关联工单，有处理进度
  - [ ] 确认后对账单数据锁定

---

### PTR-009 结算信息管理（银行账户、税务信息）
- **优先级**: P1
- **预估工时**: 2天
- **依赖**: PTR-001
- **描述**: 合作方管理结算所需的银行账户和税务信息。银行账户包括开户行、账号、户名等，需通过小额打款验证。税务信息包括纳税人识别号、发票类型、税率等。信息变更需审核确认，确保结算安全。
- **技术要点**: 
  - 银行账户管理：
    - 开户行选择：对接银行联行号数据库（支行级别）
    - 银行卡号校验：Luhn算法 + 银行卡BIN校验
    - 小额打款验证：系统向该账户打入0.01-0.99元随机金额，合作方输入金额确认
    - 支持多个银行账户，设置默认结算账户
  - 税务信息：
    - 一般纳税人/小规模纳税人选择
    - 税率自动关联（6%/3%/1%）
    - 纳税人识别号格式校验
  - 信息变更审核：敏感信息（银行账号、户名）变更需人工审核
  - 加密存储：银行卡号AES加密存储，API返回时脱敏（显示后4位）
- **涉及文件**: 
  - `src/pages/Settings/BankAccount/index.tsx` (新建)
  - `src/pages/Settings/TaxInfo/index.tsx` (新建)
  - `src/services/settlement.ts` (新建)
  - `server/controllers/settlement-info.controller.ts` (新建)
  - `server/services/bank-verify.service.ts` (新建)
  - `server/utils/crypto.util.ts` (新建)
  - `server/models/partner_bank_account.model.ts` (新建)
  - `server/models/partner_tax_info.model.ts` (新建)
- **验收标准**:
  - [ ] 银行账户信息填写完整，卡号校验正确
  - [ ] 小额打款验证流程完整
  - [ ] 税务信息与纳税人类型正确关联
  - [ ] 银行卡号加密存储，API返回脱敏
  - [ ] 敏感信息变更触发审核流程
  - [ ] 支持管理多个银行账户

---

### PTR-010 开票申请（填写发票信息、查看开票进度）
- **优先级**: P2
- **预估工时**: 2天
- **依赖**: PTR-008, PTR-009
- **描述**: 合作方对已结算的款项申请开具发票。填写开票信息（发票类型、抬头、税号、金额、项目名称），提交后由财务人员处理。支持查看开票进度、下载电子发票、物流信息追踪（纸质发票）。
- **技术要点**: 
  - 开票申请表单：
    - 发票类型：增值税普通发票 / 增值税专用发票
    - 抬头信息：自动关联税务信息，支持手动修改
    - 开票金额：关联已结算未开票的对账单，可选择合并开票
    - 开票项目：信息技术服务费 / 广告服务费 等
  - 开票进度：待处理 → 开票中 → 已开票 → 已邮寄（纸质）/ 已发送（电子）
  - 电子发票：对接税务系统API（如百望云/航天信息），自动开票
  - 发票下载：电子发票PDF/OFD格式下载
  - 物流追踪：纸质发票关联快递单号，对接快递100查询物流
  - 发票台账：所有开票记录汇总，支持按时间/金额/状态筛选
- **涉及文件**: 
  - `src/pages/Invoice/Apply/index.tsx` (新建)
  - `src/pages/Invoice/List/index.tsx` (新建)
  - `src/pages/Invoice/Detail/index.tsx` (新建)
  - `src/services/invoice.ts` (新建)
  - `server/controllers/invoice.controller.ts` (新建)
  - `server/services/e-invoice.service.ts` (新建)
  - `server/services/logistics.service.ts` (新建)
  - `server/models/invoice.model.ts` (新建)
- **验收标准**:
  - [ ] 开票申请表单信息完整，校验正确
  - [ ] 可关联已结算对账单，金额自动计算
  - [ ] 开票进度实时展示
  - [ ] 电子发票可在线下载
  - [ ] 纸质发票物流信息可追踪
  - [ ] 发票台账列表可筛选、可导出

---

## 4. 系统能力

### PTR-011 多租户数据隔离（数据库层tenant_id隔离、API层权限校验）
- **优先级**: P0
- **预估工时**: 3天
- **依赖**: INF-001, PTR-001
- **描述**: 实现合作方Portal的多租户数据隔离机制。数据库层面所有合作方相关表增加tenant_id字段，查询自动追加租户条件；API层面通过中间件校验当前用户只能访问本租户数据。确保合作方之间数据完全隔离，防止越权访问。
- **技术要点**: 
  - 数据库层隔离：
    - 所有合作方相关表增加`tenant_id`字段，建立索引
    - ORM全局Scope/Middleware：查询自动追加`WHERE tenant_id = ?`
    - 使用TypeORM的Subscriber或Query Builder拦截器实现透明注入
    - 数据库连接：共享连接池，通过SQL条件隔离（非独立数据库）
  - API层隔离：
    - 认证中间件：从JWT中提取tenant_id，注入请求上下文
    - 权限校验中间件：所有API自动校验资源归属（resource.tenant_id === ctx.tenantId）
    - 防止参数篡改：即使传入其他tenant_id也会被覆盖为当前用户的
  - 安全审计：
    - 记录所有数据访问日志（who, what, when）
    - 异常访问告警：检测到越权尝试时记录并告警
  - 测试：
    - 编写隔离性测试：创建两个租户，验证互相不可见
    - 边界测试：批量操作、关联查询、报表聚合的隔离性
- **涉及文件**: 
  - `server/middlewares/tenant.middleware.ts` (新建)
  - `server/decorators/tenant-aware.decorator.ts` (新建)
  - `server/subscribers/tenant-filter.subscriber.ts` (新建)
  - `server/interceptors/tenant-inject.interceptor.ts` (新建)
  - `server/guards/resource-ownership.guard.ts` (新建)
  - `server/models/*.model.ts` (修改，所有合作方相关表添加tenant_id)
  - `server/tests/tenant-isolation.spec.ts` (新建)
  - `database/migrations/add-tenant-id.migration.ts` (新建)
- **验收标准**:
  - [ ] 所有合作方表包含tenant_id字段并建立索引
  - [ ] ORM查询自动追加租户过滤条件
  - [ ] API无法访问其他租户数据（返回404而非403，避免信息泄露）
  - [ ] 参数篡改tenant_id无效
  - [ ] 隔离性测试全部通过
  - [ ] 数据访问审计日志完整记录
