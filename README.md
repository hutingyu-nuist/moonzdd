# MoonZDD

MoonZDD 是纯 MoonBit 实现的零抑制决策图（ZDD）库，用来表示和计算有限的**集合族**，也就是“集合的集合”。模块为 `hutingyu-nuist/moonzdd@0.1.0`，许可证为 MIT。

配置集成工具可组合不同组件方案并筛选成本；测试工具可从覆盖关系计算最小测试组合；稀疏项集工具可进行投影、频数统计、分页和压缩图交换。输入模型统一为整数项号，库不绑定网站、设备或特定业务规则。

## 数据模型

- 宇宙为 `[0,n)`，`0 <= n <= 256`；项号按升序排列。
- 成员是严格递增、无重复的 `Array[Int]`；重复成员会合并。
- `empty(n)` 是空族；`unit(n)` 是只含空集的族，两者不同。
- 节点表示“不选当前项”与“选当前项”的两个剩余集合族；高边为空时省略节点，相同三元组共享节点。低边与高边相等时仍保留节点。
- `Family` 不可变，不暴露内部节点或跨实例管理器 ID。导出的数组和返回的成员可由调用者修改，不影响原族。
- 二元运算要求宇宙大小相同。稀疏表示不保证总能压缩：某些集合族仍需指数级空间。

## 环境与安装

开发及 CI 固定 `moonc v0.10.18+6c83a7f62`，高于验收最低版本 0.10.16。由于使用当前的 `moon.mod` / `moon.pkg` 语法，建议直接使用上述编译器及配套 core；不宣称已验证所有旧编译器。

支持 `wasm-gc`、`wasm`、`js`、`native`。JS 需要 Node.js；native 需要 C 编译工具链。运行情况见仓库 Actions 的四后端检查；Windows 本机缺少 native 编译器时，不能将检查成功当作本机 native 测试已运行。

在自己的 MoonBit 模块中添加精确版本依赖：

```sh
moon add hutingyu-nuist/moonzdd@0.1.0
```

在使用处的 `moon.pkg` 导入：

```moonbit
import {
  "hutingyu-nuist/moonzdd" @zdd,
}
options("is-main": true)
```

对应的 `main.mbt` 可直接运行：

```moonbit
fn main {
  try {
    let edges = @zdd.Family::from_sets(4, [[0, 1], [1, 2], [2, 3]])
    let suites = edges.transversals()
    let best = suites.minimum_weight([5L, 2L, 4L, 1L]).unwrap()
    assert_eq(suites.count(), 3UL)
    assert_eq(best.elements, [1, 3])
    assert_eq(best.weight, 3L)
    println("minimal suites=3, cheapest=[1,3], cost=3")
  } catch {
    _ => abort("example failed")
  }
}
```

```sh
moon run .
```

上例的覆盖关系表示：需求分别可由测试 `{0,1}`、`{1,2}`、`{2,3}` 满足。输出三个按包含关系极小的测试组合，最低费用组合为 `{1,3}`，费用为 3。极小不等于成员个数最少。

## 核心 API

|任务|API 与语义|
|---|---|
|构造|`empty`、`unit`、`singleton`、`from_sets`、`powerset`、`choose`、`items`|
|按完整成员运算|`union`、`intersection`、`difference`、`symmetric_difference`|
|关系判断|`contains`、`equivalent`、`is_subfamily`、`is_disjoint`|
|逐成员组合|`join` 为 `{a∪b}`，`disjoint_join` 只接受无交集对；`meet` 为 `{a∩b}`，`subtract_members` 为 `{a\b}`|
|元素处理|`excluding`、`containing` 保留原成员；`cofactor` 选择含该项的成员后删除该项；`toggle` 翻转该项|
|域与筛选|`project` 保留指定项且不重新编号；`rename` 接受全宇宙双射；`restrict` 保留必选项并排除禁选项|
|大小与统计|`cardinality` 为闭区间筛选；`cardinality_spectrum` 为每种大小的精确计数；`occurrences` 为每项出现于多少个不同成员|
|偏序运算|`minimal`、`maximal`、`without_supersets_of`、`without_subsets_of`；后两者排除时包括相等成员|
|闭包|`downward_closure`、`upward_closure`；`complement_members` 将每个成员 S 映射为宇宙减 S|
|命中集|`transversals` 返回与每条超边相交的全部极小成员，不先枚举边族|
|访问|`count`、`rank`、`unrank`、`page`、`enumerate`、`first`、`last`；`size_bounds` 给出大小上下界|
|代价|`minimum_weight`、`maximum_weight`，返回成员及有符号 Int64 加法代价；空族返回 `None`|
|交换与诊断|`to_graph` / `from_graph`、`to_json` / `from_json`、`statistics`、`to_dot`|

完整类型及签名见 [pkg.generated.mbti](pkg.generated.mbti)。算法及复杂度边界见 [架构说明](docs/architecture.md)，交换约束见 [格式说明](docs/format.md)。

特别注意：`intersection` 比较整个成员是否相同，`meet` 对每一对成员计算项的交集，两者输出不同。`complement_members` 也不等于“所有未包含成员”的族补集。

## 顺序、预算与错误

遍历先走低边，较小项号对应更高位；例如三项 powerset 的开头为 `[]`、`[2]`、`[1]`、`[1,2]`。这不是按成员长度或通常数组词典序排序。`rank`、`unrank`、`page` 与此顺序一致；代价相同的最优成员也取此顺序最先者。

构造与变换使用 `Limits { nodes, steps }`，默认最多 100000 个节点（包括两个终端）、2000000 个工作步骤。预算包含输入导入、递归运算、记忆化处理及输出压缩，不仅是最终图大小。宇宙上限限制递归路径；预算上限分别为 1000000 节点和 100000000 步。示例：

```moonbit
let small = @zdd.Family::choose(20, 3, limits={ nodes: 2000, steps: 100000 })
```

失败会抛出 `ZddError`，不修改输入：`Invalid(String)` 表示参数或格式不合法；`BudgetExceeded` 表示资源上限；`CountOverflow` 表示 UInt64 计数溢出；`WeightOverflow` 表示已计算的 Int64 中间代价溢出；`MissingMember` 表示请求了不存在成员的 rank。调用者应捕获错误，不将失败当成空族。

`count`、`rank`、`unrank`、`page` 和 `occurrences` 要求总成员数可由 UInt64 表示。`cardinality_spectrum` 对系数逐项检查，并将中间存储限制为 2000000 个计数器；它不要求系数之和可表示。权重优化对每个求值的中间最优代价做溢出检查，发生溢出就报告错误，不丢弃溢出分支。`first`、`last`、`size_bounds`、结构统计和有界枚举不依赖总计数。

`enumerate(limit)` 和 `page(offset, limit)` 返回 `{ sets, complete }`，最多请求 10000 个成员；`complete=false` 表示确实还有成员。`page` 的 complete 指偏移之后是否已到结尾，不表示包含了更早的成员。`enumerate` 另受工作预算限制。DOT 默认最多输出 5000 个非终端节点，超限报错，不返回残图。

## 三个可复现工作流

在克隆的仓库根目录运行：

```sh
moon run examples/configurations
moon run examples/coverage
moon run examples/itemsets
```

1. [配置方案](examples/configurations/main.mbt)：输入两组组件候选，组合后排除不兼容的同时选项，再计算最低费用；输出 4 个组合、3 个合法组合和费用 5 的 `{0,2}`。
2. [测试覆盖](examples/coverage/main.mbt)：输入三个需求到可覆盖测试的关系，计算全部极小命中集并优化费用；输出 3 个方案和费用 3 的 `{1,3}`，并逐条断言覆盖成立。
3. [稀疏项集](examples/itemsets/main.mbt)：输入不同购物篮，投影、JSON 往返交换、统计各项出现次数，再按必选／禁选项与大小筛选并分页；输出投影后 5 个成员、频数 `[2,2,4,0,0]`，筛选结果 `{0,2}`。

输入均在示例开头给出，可替换为调用方解析后的业务数据；库保留整数项号，由调用方维护项号到业务名称的映射。集合族不记录原始输入成员的重复次数，不能直接当交易多重集频数库使用。

## 检查与测试

```sh
moon info
moon fmt --check
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn
moon test --target wasm --deny-warn
moon test --target js --deny-warn
moon test --target native --deny-warn
```

[CI](.github/workflows/ci.yml) 在四后端分别检查、构建、运行全部测试和三个示例，并检查公开接口与格式。测试包含终端、排序、预算、溢出、恶意图和 JSON；独立位掩码真值表覆盖三项宇宙全部 256 个集合族，以及 4096 对族的代数／乘积／包含关系。它不复用 ZDD 递推来生成预期结果，也不是仅做自有格式往返。

实测压缩例：80 项的 powerset 含 80 个非终端节点；63 项 powerset 的 count 为 `9223372036854775808`，64 项会报告 `CountOverflow`。这些是结构及整数边界结果，不是对其他库的速度比较，也不保证实际业务数据的压缩比。

## 边界与来源

本库实现通用有限集合族，不实现布尔表达式解析、ROBDD、SAT/CP、故障树概率、形式概念分析、序列挖掘或图路径前沿搜索；也不提供 Graphillion/CUDD 的二进制／API 兼容。最小命中集可指数增长，必须保留预算。

实现为原创 MoonBit 代码，参考 Minato 的 ZDD 表示及 Graphillion setset 的集合族任务；没有复制这些项目或相邻 MoonBit 项目的实现。Graphillion 是 MIT，MoonBit core 是 Apache-2.0；详见 [第三方说明](THIRD_PARTY.md)。查重范围与局限见 [选题检查](docs/competition/duplicate-check.md)，结论仅限“在已记录检索范围内未发现成熟直接替代”。

项目使用 [MIT](LICENSE)。AI 辅助开发范围与核验方式见 [AI_USE.md](AI_USE.md)，版本记录见 [CHANGELOG.md](CHANGELOG.md)，资源与安全边界见 [SECURITY.md](SECURITY.md)。技术交付不代表赛事官方验收或报名结果。
