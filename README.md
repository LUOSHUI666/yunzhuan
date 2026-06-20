# 云篆 · 道门智慧 MBTI 顾问

融合道家符箓美学与 MBTI 性格类型的离线灵感工具。旋转罗盘选择本命类型，点击符箓令牌启卦，获得契合心境的道家哲思解读与虚拟问道时辰。

## 运行方式

双击 `index.html` 即可在浏览器中运行。零依赖，离线可用。

## 项目结构

```
yunzhuan/
├── index.html      # 主文件，含全部 HTML/CSS/JS
├── assets/         # 远期资源目录（Demo 阶段为空）
├── CHANGELOG.md    # 版本记录
├── README.md       # 本文件
└── .gitignore
```

## 技术栈

- 纯 HTML/CSS/JS，单文件，零外部依赖
- CSS 自定义属性统一主题
- 动画基于 transform + opacity，确保 60fps
- 文案数据内嵌 JSON，修改无需触碰逻辑代码
