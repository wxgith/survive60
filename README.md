# 撑过60秒 / SURVIVE 60

一个用 Godot 4.6.3 和 GDScript 制作的俯视飞机生存小游戏。驾驶飞机躲避陨石、自动开火、拾取火力升级，在 3 点生命耗尽前坚持 60 秒。

画面使用程序绘制的霓虹几何图形。单关卡、快速重开，无需账号，不联网，不收集数据。

## 从源码运行

1. 安装 [Godot 4.6.3 标准版](https://godotengine.org/download/archive/4.6.3-stable/)（无需 .NET）。
2. 下载或克隆本仓库，在 Godot 项目管理器中导入 `project.godot`。
3. 等待首次资源导入完成，按 F5 运行项目，点击「开始游戏」或按 Enter。

需要支持 Godot 4.6 的 Windows、Linux 或 macOS。仓库包含源项目，不包含预编译的可执行程序。

## 操作

- WASD / 方向键：移动
- 自动向上射击，无需瞄准
- 绿色芯片：火力从单发升级到双发、三发；未满级时每击碎 8 颗陨石掉落一次
- Esc：暂停 / 继续
- 切走窗口：自动暂停，返回后手动继续
- Enter：开始游戏
- R：结算后再来一局

## 测试

确保 `godot` 命令指向 Godot 4.6.3，在项目目录运行：

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_tests.gd
```

成功时输出 `ALL TESTS PASSED: 60 checks, 0 failures`，进程退出码为 0。断言失败或测试脚本中断均计为失败。

测试涵盖生命与无敌时间、胜负判定、移动边界、射击与升级、连续碰撞检测、暂停、窗口失焦、重复重开，以及完整 60 秒游戏模拟。

可选的固定策略难度采样：

```sh
godot --headless --path . --script tests/balance_probe.gd
```

采样不能替代真人试玩。受限环境中如用户配置目录不可写，请将 `XDG_CONFIG_HOME`、`XDG_CACHE_HOME`、`XDG_DATA_HOME` 指向可写目录后再运行。

## 导出

仓库提供 Windows x86-64 和单线程 Web 导出预设。先在 Godot 编辑器的「编辑器 → 管理导出模板」中安装与编辑器完全匹配的 4.6.3 导出模板，再通过「项目 → 导出」构建，或运行：

```sh
mkdir -p build/windows build/web
godot --headless --path . --export-release "Windows Desktop" build/windows/Survive60.exe
godot --headless --path . --export-release "Web" build/web/index.html
```

Windows 预设将游戏资源嵌入 EXE。Web 导出文件需要通过 HTTP(S) 服务打开，不能直接双击 HTML；本地测试可运行 `python3 -m http.server 8000 --directory build/web`，然后打开浏览器访问 `http://localhost:8000`。

对外分发导出包时，请同时附带根目录 `LICENSE`、`THIRD_PARTY_NOTICES.md`、`licenses/` 目录和 `assets/FONT-LICENSE.txt`、`assets/FONT-NOTICE.txt`，让玩家无需解包就能阅读许可说明。升级引擎时同步更新对应版本的 Godot 及第三方许可。

## 项目结构

- `project.godot`：项目配置
- `scenes/main.tscn`：主场景
- `scripts/`：游戏状态、玩家、武器、陨石、拾取物与界面
- `assets/`：中文界面字体子集和字体许可
- `tests/`：自动化测试及难度采样
- `export_presets.cfg`：Windows / Web 导出设置
- `licenses/`：Godot 引擎与第三方依赖许可

## 许可证

游戏原创代码、场景、配置和文档使用 [MIT License](LICENSE)。

字体 `assets/survive60-ui.otf` 是重命名为 Survive60 UI 的 Noto Sans CJK SC 字符子集，继续使用 SIL Open Font License 1.1；不受本项目 MIT 许可覆盖。Godot 引擎及其依赖也保留各自的许可。详见 [第三方声明](THIRD_PARTY_NOTICES.md)。
