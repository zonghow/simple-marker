# SimpleMarker

一个原生 macOS 菜单栏标注工具。

SimpleMarker 常驻在菜单栏中，可以通过全局快捷键或托盘左键快速进入标注模式，在当前鼠标所在显示器上直接画线标注。

## 特性

- 菜单栏应用，不显示 Dock 图标
- 左键点击托盘图标直接进入标注模式
- 支持全局快捷键唤起
- 只覆盖鼠标当前所在的显示器
- 鼠标左键自由绘制
- 鼠标右键整笔擦除
- `Esc` 退出标注模式
- `⌘Z` 撤销
- `⌘⇧Z` 重做
- 平滑线条显示
- 设置页支持快捷键录制
- 右键托盘菜单支持设置、开机启动、退出

## 运行要求

- macOS 13+
- Xcode 26+

## 本地运行

```bash
open "SimpleMarker.xcodeproj"
```

然后在 Xcode 中：

1. 选择 `SimpleMarker` scheme
2. 点击 Run
3. 程序启动后会出现在菜单栏中

## Release 构建

```bash
make release
```

构建完成后，产物位于：

```bash
dist/SimpleMarker.app
```

如需清理本地产物：

```bash
make clean-release
```

## 使用方式

### 开始标注

- 菜单栏图标左键
- 或使用全局快捷键

### 标注模式操作

- 左键拖动：绘制
- 右键按住并移动：整笔擦除
- `⌘Z`：撤销
- `⌘⇧Z`：重做
- `Esc`：退出

## 托盘菜单

右键点击菜单栏图标可打开：

- 设置
- 开机启动
- 退出

## 项目结构

```text
SimpleMarker/
  App/
  Annotation/
  Hotkey/
  MenuBar/
  Settings/
  System/
SimpleMarker.xcodeproj/
Makefile
```
