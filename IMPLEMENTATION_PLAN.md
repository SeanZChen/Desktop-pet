# macOS 桌面宠物 - 实现方案

## 项目概述

创建一个运行在 macOS 桌面右下角的可爱宠物，点击时会弹出打招呼对话框。

## 技术选型

| 技术 | 选择 | 理由 |
|------|------|------|
| 框架 | Electron | 跨平台，使用 Web 技术，易于开发和维护 |
| 语言 | JavaScript/TypeScript | 广泛使用，社区成熟 |
| UI | HTML + CSS | 灵活实现宠物形象和动画 |

## 功能需求

### 核心功能
1. ✅ 宠物显示在桌面右下角
2. ✅ 点击宠物弹出打招呼对话框
3. ✅ 宠物有基本动画效果
4. ✅ 支持关闭宠物

### 扩展功能（可选）
- 🎨 多种宠物形象切换
- 💬 随机打招呼语句
- 🎭 宠物状态动画（睡觉、玩耍等）
- 💾 记住用户名字

## 实现架构

### 项目结构
```
desktop-pet/
├── package.json          # 项目配置
├── main.js              # 主进程 - 窗口管理
├── renderer.js           # 渲染进程 - 宠物逻辑
├── index.html            # 宠物界面
├── style.css             # 样式
└── assets/               # 资源文件
    └── pet.png           # 宠物图片
```

### 核心组件

| 组件 | 职责 | 文件 |
|------|------|------|
| **主进程** | 管理透明窗口、位置、生命周期 | main.js |
| **渲染进程** | 宠物渲染、动画、点击事件 | renderer.js |
| **UI界面** | 宠物形象、对话框 | index.html + style.css |

### 关键技术点

#### 1. 透明无边框窗口
```javascript
// main.js
const { BrowserWindow } = require('electron');

const win = new BrowserWindow({
  width: 120,
  height: 150,
  transparent: true,
  frame: false,
  alwaysOnTop: true,
  skipTaskbar: true,
  webPreferences: {
    nodeIntegration: true
  }
});
```

#### 2. 右下角定位
```javascript
// 获取屏幕尺寸，计算右下角位置
const { screen } = require('electron');
const display = screen.getPrimaryDisplay();
const { width, height } = display.workAreaSize;

win.setPosition(
  width - PET_WIDTH - 20,  // 右边距20px
  height - PET_HEIGHT - 20 // 下边距20px
);
```

#### 3. 点击事件与对话框
```javascript
// renderer.js
document.getElementById('pet').addEventListener('click', () => {
  // 显示打招呼对话框
  showGreeting();
});

function showGreeting() {
  const greetings = [
    '你好呀！😊',
    '今天心情不错！☀️',
    '陪我玩一会儿吧~',
    '主人好！🐾'
  ];
  const randomGreeting = greetings[Math.floor(Math.random() * greetings.length)];
  
  // 显示对话框
  document.getElementById('dialog').textContent = randomGreeting;
  document.getElementById('dialog').style.display = 'block';
  
  // 3秒后自动隐藏
  setTimeout(() => {
    document.getElementById('dialog').style.display = 'none';
  }, 3000);
}
```

#### 4. 宠物动画
```css
/* style.css */
@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}

.pet {
  animation: bounce 2s ease-in-out infinite;
  cursor: pointer;
}
```

## 实现步骤

### Phase 1: 基础框架搭建
1. 初始化 Electron 项目
2. 创建主进程窗口配置
3. 设置透明窗口和右下角定位

### Phase 2: 宠物界面
1. 创建 HTML 结构（宠物 + 对话框）
2. 添加 CSS 样式和动画
3. 实现点击事件处理

### Phase 3: 功能完善
1. 添加多种打招呼语句
2. 实现对话框显示/隐藏动画
3. 添加右键菜单（关闭宠物）

### Phase 4: 打包发布
1. 配置 electron-builder
2. 打包成 DMG 安装包
3. 测试分发

## 预期效果

```
┌─────────────────────────────────────────────────────┐
│                                                   │
│   macOS 桌面                                      │
│                                                   │
│                                                   │
│                                                   │
│                                                   │
│                              ┌──────────┐         │
│                              │   🐱     │         │
│                              │  [宠物]  │   ← 点击显示对话框
│                              └────┬─────┘         │
│                                   │                │
│                              ┌────▼─────┐         │
│                              │ 你好呀！  │         │
│                              └──────────┘         │
└─────────────────────────────────────────────────────┘
```

## 依赖与资源

| 依赖 | 版本 | 用途 |
|------|------|------|
| electron | ^28.0.0 | 桌面应用框架 |
| electron-builder | ^24.9.1 | 打包工具 |

## 启动命令

```bash
# 安装依赖
npm install

# 开发模式运行
npm start

# 打包成 DMG
npm run build
```

---

**确认:** 以上是基本实现逻辑，是否需要我继续实现代码？