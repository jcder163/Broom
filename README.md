# Broom
一个简单的命令行工具，用来扫描项目内没有使用的资源
# 安装
`brew tap jcder163/homebrew-tap`
`brew install broom`
# 使用
支持了三个子命令`broom scan`, `broom config`, `broom show`
## Show
用来展示基础配置，比如项目名称、项目路径、认定的资源名称
## Config
` broom config --project xxx -s "imageset|jpg|gif|png|pdf|json|apng" -p xxx `
可以按照项目，配置路径和资源后缀，支持单独配置
## Scan
` broom scan --project xxx `, 打印扫描出来的无用文件
` broom scan --project xxx -o /xxx/xxx/xxx.json `, 输出扫描出来的无用文件到指定的文件

