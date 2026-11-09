# 第三方归属与参考边界

MoonZDD 的库、示例和独立真值表测试为本项目原创 MoonBit 实现，没有复制、翻译或供应商打包其他项目源码。概念和公开行为参考不表示 API 兼容。

- Shin-ichi Minato, “Zero-suppressed BDDs for set manipulation in combinatorial problems”, DAC 1993, DOI `10.1145/157485.164890`：参考高边为零的节点抑制及集合族表示。未复制论文文字、图、源码或受限测试集。
- [Graphillion](https://github.com/graphillion/graphillion)，MIT License，版权归其 LICENSE.txt 中列明的 Graphillion 开发者：参考公开 setset 的集合族运算、极小族和权重任务，未移植其 C/C++/Python 实现；未实现 graphset 前沿搜索、API 或文件兼容。原始许可见 [LICENSE.txt](https://github.com/graphillion/graphillion/blob/master/LICENSE.txt)。本项目不包含其代码，因此不将其代码版权声明改写为自己的版权。
- [MoonBit core](https://github.com/moonbitlang/core)，Apache License 2.0：编译器配套的标准库及 JSON 解析依赖。使用标准接口，无 vendored 副本；保留其发行物原有许可。没有外部运行时模块依赖。

相邻项目 MoonBDD（Apache-2.0）、moonfault（MIT）、moon_faultgraph（Apache-2.0）和 moonstl 仅用于语义查重，不是复制来源、运行时依赖或性能对标对象。
