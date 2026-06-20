# 云篆 YunZhuan — 东方美学人格体验

## 项目定位

融合东方水墨美学 × 16型人格的**单文件离线 PWA**。旋转罗盘选择本命类型，点击心笺叩问内心，获得庄子式空灵哲思解读。核心价值：以仪式化交互替代生硬测评，用东方哲思给予内心指引。

## 技术约束

- **单文件 HTML**：`index.html` 包含全部 HTML/CSS/JS，零外部依赖
- **离线运行**：双击即运行于 Chrome/Edge/Safari，无网络请求
- **零依赖**：所有图形用纯 CSS/SVG 绘制，字体使用系统预装
- **60fps**：动画优先使用 `transform` 和 `opacity`
- **文案解耦**：修改文案仅需编辑 JS 对象 `TOKEN_DATA`，无需触碰逻辑代码

## 当前状态

**已完成：**
- Git 仓库初始化 + GitHub 远程仓库（https://github.com/LUOSHUI666/yunzhuan）
- **Step 1 入境**：CSS 主题体系（12 色 + 2 字体）+ 3 层星图旋转 + 八卦罗盘（青铜色化+分层自转）+ 中心隶书文字 + 左右青铜箭头切换 16 型 + 键盘左右键
- **Step 2 问道**：`#stage` 纵向弹性布局 + `.compass-row` 包裹罗盘行 + 六张心笺（80×180px 竖向黄笺纸质感、独立浮动动画 ±6px 周期 3~4s、悬停朱砂光晕）
- **Step 3 叩心**：粒子爆发消散 + 选中笺飞升中央 + 其余淡出 ✅
- **Step 4 观象**：竹简卡片（五层纹理+绳结）+ 时辰打字机 + 正文打字机 ✅
- **Step 5 归真**：卡片外点击→淡出→笺复位→清历史 ✅
- **TOKEN_DATA**：48 组文案（INFP/INTJ/INFJ/ENFP × 6笺 × 2变体）✅
- `index.html` ~1500 行，六模块架构完整运行

**待实现：**
1. 全局打磨（动画节奏微调、移动端环形面板位置校准）
2. 微信客服上线（待用户提供凭证）

## 视觉铁律

**禁用：** 纯白 `#FFF`、高饱和现代色、圆角按钮、任何现代 UI 组件痕迹

**配色表：**

| 角色 | 色值 | 用途 |
|------|------|------|
| 背景 | `#0D0D14` | 深色星图基底 |
| 青铜 | `#6B3A2A` / `#8B5A3C` / `#3E2418` | 罗盘环、箭头 |
| 朱砂 | `#C41E3A` / `#E23D3D` | 心笺悬停发光 |
| 笺纸 | `#C8B896` | 心笺纸底 |
| 墨朱 | `#3C1010` | 心笺文字常态 |
| 竹简 | `#F0EAD6` / `#E0D5C0` | 解读卡片底色 |
| 墨色 | `#2C1810` / `#4A3728` | 正文、时辰文字 |

**字体回退：**
- 标题/罗盘/令牌：`'LiSu', '楷体', 'KaiTi', 'STKaiti', serif`
- 正文/时辰：`'SimSun', '宋体', 'STSong', 'FangSong', '仿宋', serif`

**心笺尺寸：** 宽 80px × 高 180px，竖向黄笺纸墨朱楷体

## 六模块架构（index.html 内部）

```
<style data-module="theme">     ← 1. 主题样式体系（CSS 变量 + 组件样式 + @keyframes）
<script data-module="config">   ← 2. 配置常量（转速/粒子数/打字速度/列表）
<script data-module="data">     ← 3. 数据层（TOKEN_DATA + getReading + 防重复）
<script data-module="render">   ← 4. 渲染引擎（创建 DOM：星图/罗盘/令牌/卡片）
<script data-module="effects">  ← 5. 动效控制器（粒子爆发/打字机/淡入淡出/位移）
<script data-module="app">      ← 6. 交互状态机（状态 + 事件绑定 + init 入口）
```

**模块职责边界：**
- `config`：纯常量，零逻辑
- `data`：纯数据 + 抽取算法，不碰 DOM
- `render`：纯 DOM 创建与样式操作，不处理动效时序
- `effects`：纯视觉动效工具函数，不涉及业务状态
- `app`：唯一有状态 + 绑定事件的模块，调用 render 和 effects

## 仪式五幕交互流

```
入境 → 问道 → 叩心 → 观象 → 归真
```

1. **入境**：星图三层漂移 + 亮星不规则闪烁 + 稀有流星。罗盘整体自转（120s/圈），外环反向90s、中环正向70s、内环反向110s，天池反向抵消始终正立。左右青铜箭头/键盘切换16型
2. **问道**：六张心笺独立浮动（±6px，周期 3~4s），悬停时朱砂字发光
3. **叩心**：点击心笺 → 20 个金色粒子 0.8s 消散 → 其他笺淡出 → 选中笺飞升中央 → 罗盘加速
4. **观象**：心笺展开为竹简卡片 → 标签"INFP · 逍遥散人" → 时辰打字机 80ms/字 → 正文打字机 40~60ms/字 → 底部淡出"道法自然，不必执着"
5. **归真**：点击卡片外空白 → 卡片淡出 → 心笺归位 → 罗盘恢复 → 可重新启卦

## 数据模型

```javascript
// 配置常量
const COMPASS_SPEED = 30;          // 罗盘转速（秒/圈）
const PARTICLE_COUNT = 20;         // 粒子数量
const TYPEWRITER_SPEED_TEXT = 50;  // 正文打字速度（ms/字）
const TYPEWRITER_SPEED_TIME = 80;  // 时辰打字速度（ms/字）
const TOKEN_FLOAT_AMPLITUDE = 6;   // 令牌浮动幅度（px）
const TOKENS = ['迷途', '坎', '执', '散', '渊', '生'];
const MBTI_TYPES = ['INFP','INFJ','INTJ','ENFP','ENFJ','ENTJ','ESFP','ESFJ','ESTP','ESTJ','ISFP','ISFJ','ISTP','ISTJ','INTP','ENTP'];

// TOKEN_DATA 结构（MVP 先覆盖 INFP/INTJ/INFJ/ENFP 四种）
const TOKEN_DATA = {
  "INFP": {
    "迷途": [
      { text: "你看那雾中山径……", time: "卯时初刻 · 晨露未晞" },
      { text: "另一种正文……",   time: "酉时三刻 · 归鸟入林" }
    ],
    // 坎/执/散/渊/生 同理
  },
  // INTJ/INFJ/ENFP 同理
};

// 会话防重复
let sessionHistory = {}; // key: "INFP_迷途" → value: ["已展示过的text", ...]
```

**关键规则：**
- 正文与时辰强绑定，作为一个单元抽取和展示
- `time` 字段可选，缺省时卡片不显示时辰行
- 同一类型同一令牌连续点击，过滤历史避免正文重复（数组长度≥2 时生效）
- `getReading(mbti, token)` 负责抽取 + 过滤 + 更新历史
- `resetSessionHistory()` 归真时清除历史

## 环形全览坐标算法

16 个选项均匀分布在圆周上，半径 ~180px：
```
θ = (i / 16) * 2π - π/2   // 从顶部开始
x = cx + R * cos(θ)
y = cy + R * sin(θ)
```

## MVP 文案覆盖范围

- 类型：INFP、INTJ、INFJ、ENFP（4 种）
- 令牌：迷途、坎、执、散、渊、生（6 个）
- 变体：每个组合 2 条
- 总量：4 × 6 × 2 = 48 组（正文 + 时辰）

## 代码规范

- JS：小驼峰 `getReading`、`currentMBTI`
- CSS：短横线连接 `.card-bamboo`、`.token--floating`
- 常量：全大写 `PARTICLE_COUNT`、`COMPASS_SPEED`
- 数据键名：中文（令牌名、类型名），直观可读
- 所有 DOM 操作集中在 `app` 模块，通过 `data-token` 等属性绑定
- 状态变更通过 `updateUI()` 统一刷新
- 异步打字机使用 `async/await`，时辰先于正文启动但正文慢于时辰

## 提交规范

每完成一个功能模块后提交：
```
git add index.html
git commit -m "feat: <模块名> — <一句话描述>"
git push
```

## 严禁事项

- 不要引入任何外部依赖（npm 包、CDN、Google Fonts 等）
- 不要使用纯白 `#FFF` 或 `#FFFFFF`
- 不要使用圆角按钮、Material Design 等现代 UI 风格
- 不要修改 Git config 全局设置
- 不要在未确认时修改 `TOKEN_DATA` 之外的逻辑代码（文案编辑除外）
- 不要引入 React/Vue/任何框架
