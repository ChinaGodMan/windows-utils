[EnvUpdate](EnvUpdate.cpp)

- 用于刷新环境变量

pwsh 的`.NET`方法在一些机器上添加环境变量速度比较慢,改为通过`Set-Item`,速度提升明显
但是需要通过发送`WM_SETTINGCHANGE`消息通知系统环境变量已更改
在 pwsh 中用` Add-Type` 添加 C# 片段,首次加载时间也比较慢
改为编译后的 exe,提升下速度
