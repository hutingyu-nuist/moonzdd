# 选题与严格语义查重

检查日期：2026-11-09。使用已安装 moonbit-hackathon-builder 及 osc2026-guide 的 Project Research Guide。规则使用技能内固定资料，不重新查询或改写章程。2026-10-30 24:00 已过去，本次技术交付不宣称在期限内完成或已获官方验收。

## 需求与不同领域候选

评分维度均为1–5：广度、用户多样性、复用、低重合风险、实现深度、可验证性、可交付性、可维护性；硬失败优先于分数。

| 排序 | 候选/问题域 | 成熟依据/实际需求 | 分数 | 决策 |
|---|---|---|---|---|
|1|MoonZDD，离散集合族压缩计算|Graphillion setset 的集合族代数、组合筛选与权重排序；配置、测试覆盖及稀疏项集工具均需重复处理集合的集合|5/4/5/4/5/5/4/4=36|通过，原创纯MoonBit核心；高相邻ROBDD已检查|
|2|科学FITS文件读写|FITS/CFITSIO/Astropy用于观测数据、科研图像、归档数据交换|5/4/5/1/5/5/3/3=31|淘汰：moonastrofits是直接替代|
|3|二维矩形装箱|MaxRects/rectpack常用于纹理图集、印刷排版、物流布局|5/5/5/1/4/5/4/4=33|淘汰：rectloom及moon_binpack是直接替代|

图同构仅做初步探索，moon search 已返回 moongraph/iso 等直接实现，没有列入可行候选。没有虚构参与者使用经历或用户访谈；以上需求来自成熟跨生态库所公开支持的任务。

## 检索方法和实际范围

1. `moon search <关键词> --limit 100`，工具链moonc0.10.18。完整原始输出保存在本地研究记录，公开文档只保留可复核范围。查询：fits、FITSIO、BITPIX、BINTABLE、astronomy、cfitsio；rectangle packing、bin packing、rectpack、maxrects；decision diagram、bdd、zdd、zero suppressed、zero-suppressed decision、set family、setset、graphillion、Sylvan、CUDD、powerset、set union product、hitting set、minimal sets、集合族、决策图、moonzdd。最大返回35模块，未触及100上限；中文和名称匹配存在明显噪声，不能用零结果判断不存在。
2. MoonCakes精确版本元数据、文档页及真实源ZIP。MoonBDD的GitHub源仓库404，改用公开包完整接口、源码、测试和说明核查，而非据此当作不存在。其包SHA256：9d2d86c94569dc4450a85893d6a3867c37612b4e72176759523b2205344c7124。
3. GitHub仓库检索 `ZDD language:MoonBit`、`decision diagram language:MoonBit`、`zero suppressed language:MoonBit`、`set family language:MoonBit`、`FITS language:MoonBit`、`packing language:MoonBit`，per_page100，成功响应记录total_count和incomplete_results。第一次含空格的PowerShell参数传递失败，已用URI编码查询重新执行。没有把失败当作零结果。仓库搜索不覆盖私有仓库和未索引代码。
4. 官方 [awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit) README/tree（2c21cca295d865327783cba31861cd78ecb955a4）；误用旧组织路径得到404，已更正。检索完整永久注册表，读取决策图、集合族、集合乘积、FITS、二维装箱及保留项目完整指纹。MoonBench/MoonContract/MoonRecur/MoonShard/MoonCite/MoonPhone等保留；相关MoonSPDX Semantic Proof、MoonPolicyProof、MoonConcept、MoonSeqMine均不复制。
5. 对核心行为和接口反向检索：集合族、零抑制、union product、minimal sets、hitting set、Graphillion/setset及ZDD；未把关键词和同名包当成语义裁决。发布前还会复查。

## 源码级比较

| 项目及证据 | 用户/输入与输出 | 算法/接口与维护证据 | 重合分类与边界 |
|---|---|---|---|
|[MoonBDD0.1.0](https://mooncakes.io/docs/oyjh0381/moonbdd@0.1.0)|布尔公式、状态迁移→布尔图、可达状态、见证|Apache-2.0；50次下载为检查时快照；README/mbti/manager.mbt/operations.mbt/property_test.mbt；mk在low=high时归约，Shannon布尔cofactor、ITE、量化、模型计数|高度相邻。ZDD在high=0归约；跳过的项表示不存在；1是仅含空集的集合族。集合并集乘积/不交乘积与极小命中集是不同核心工作流。改变现有Manager会破坏布尔终端、量化及跳变量契约，独立实现优于修改其语义。不会提供ROBDD公式或模型检查替代|
|[HOL Light BDD](https://github.com/bobzhang/hol-light.mbt/tree/6d4d8e3c4fc5d48403784d22bb8228587c8d3b66/library/bdd)|逻辑项→内核定理|library/bdd API、bdd.mbt及bdd_ref_test.mbt；bdd_and/or/taut等绑定Thm|相邻布尔证明，不是任意稀疏集合族引擎|
|[moonstl0.1.1](https://github.com/moonbitstack/moonstl)|数组池→显式子集/笛卡尔积枚举|README、algo/combinatorics.mbt、接口与测试；Powerset::next/Product::next；ZIP哈希58cdf66445e63ae4cb59618c6b074dc33572e117c8b0e4cb083108e2b9c7704f|同类任务不同核心；没有压缩集合族上的闭合代数、图交换或按计数跳转|
|[moonfault0.1.0](https://github.com/forey217/moonfault) / [moon_faultgraph0.3.0](https://github.com/btlqql/moon-faultgraph)|故障门和事件概率→系统概率、重要度、正事件割集|公开包README/API、BDD、诊断、边界测试；MIT/Apache-2.0；Tree::minimal_cut_sets / FaultGraph::minimal_cut_sets|相邻组合子集输出，但接口围绕故障树/布尔概率；MoonZDD不构建故障图、不提供该领域分析|
|[moonastrofits0.1.0](https://github.com/cosettese/MoonAstroFITS)|字节→FITS头/HDU/图像/BINTABLE及P/Q堆列|Apache-2.0；树b84398fe6e5238a264536ccf04e5e021b69645c7；README/LICENSE/mbti/hdu.mbt/header_test.mbt/table_heap_test.mbt|直接重合，淘汰FITS候选；不能靠不做P/Q变成新项目|
|[rectloom0.1.0](https://github.com/YM-ai-nb/rectloom)|标号矩形→多页布局、诊断与交换|MIT；树ea51c287e200864650740499ba50dc811b5d7196；README/LICENSE/mbti/pack_skyline.mbt/rectloom_test.mbt|直接重合，淘汰二维装箱候选；另有moon_binpack的MaxRects/Skyline/Guillotine和kagura/packing2d|
|注册表MoonSPDX/MoonPolicyProof/MoonConcept/MoonSeqMine|许可证布尔证明/网络规则改变/对象属性闭包/有序序列挖掘|完整保留指纹及既有公开成果|不重复这些任务、输入模型或输出协议；ZDD不提供这些领域引擎|

## 完成标准与边界

本次核心是有限整数宇宙上的不可变集合族值。包括有预算的canonical ZDD节点、闭合代数、集合乘积与元素变换、投影、大小筛选、极小/极大族、命中集、检查溢出的计数及rank/unrank、权重最优成员和严格交换格式。三个可运行下游工作流分别对输入进行实际组合/筛选并断言输出；小域独立显式集合oracle对照，检查错误/预算/恶意格式及跨后端一致性。

不做图路径前沿搜索、通用SAT/CP/ROBDD求解、故障树概率、FCA或序列挖掘，不声称Graphillion/CUDD兼容或替代全部能力。库的复用价值是下游可在压缩表示上组合和筛选而无需先列出所有成员；不能保证所有集合族都能压缩，最坏情形仍指数级。

结论：**在已记录检索范围内未发现成熟直接替代**。源码公开性、MoonCakes索引延迟、模糊匹配、GitHub搜索覆盖及检查日期构成限制；这不是主办方裁决，也不是绝对不存在同类。
