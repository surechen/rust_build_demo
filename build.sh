#!/bin/bash
# 测试项目: https://github.com/surechen/rust_build_demo/
echo -e "#####################################环境准备#####################################\n\n\n"
echo -e "安装rustup\n"
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo -e "更新rustup\n"
# rustup update nightly && rustup default nightly
echo -e "安装 rustc组件\n"
# rustc-dev，包含hir和ast解析相关的crate
# 安装rustfmt
# 安装clippy
rustup component add rustc-dev rust-src clippy rustfmt miri llvm-tools-preview
rm -rf workplace
mkdir workplace
echo -e "\n\n\n"
echo -e "#####################################环境准备 end#####################################\n\n\n"

echo -e "####################################依赖检查####################################\n\n\n"
echo -e "cargo-supply-chain:  crate发布者信息查询，执行慢，暂时关闭\n"
#cargo install cargo-supply-chain
#cargo supply-chain update
#cargo supply-chain crates
#cargo supply-chain publishers
echo -e "\n\n\n"

echo -e "cargo-geiger:  统计项目使用到的crates的unsafe代码片段信息\n"
# 需要正确安装openssl
cargo install --locked cargo-geiger
cargo geiger > workplace/cargo-geiger.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-tree:  跟踪和查询crates依存关系图\n"
cargo install cargo-tree
cargo tree > workplace/cargo-tree.txt 2>&1
echo -e "\n\n\n"

echo -e "cargo-deps:  软件依赖图\n"
cargo install cargo-deps
sudo apt install graphviz
cargo deps --all-deps | dot -Tpng > workplace/cargo-deps.png
echo -e "\n\n\n"

echo -e "tokei:  代码行数统计\n"
cargo install tokei
tokei > workplace/cargo-tokei.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-udeps:  检查Cargo.toml中未使用的依赖\n"
cargo +stable install cargo-udeps --locked
cargo +nightly udeps --all-targets > workplace/cargo-udeps.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-modules: 显示crates概述信息\n"
# cargo-modules
cargo install cargo-modules
cargo modules generate tree --bin rust_build_demo1 > workplace/cargo-modules-tree.txt 2>&1
cargo modules generate graph --bin rust_build_demo1 > workplace/cargo-modules-graph.txt 2>&1
echo -e "\n\n\n"

echo -e "cargo-license:  license信息展示\n"
cargo install cargo-license
cargo license > workplace/cargo-license.txt 2>&1
echo -e "####################################依赖检查 end####################################\n\n\n"
echo -e "\n\n\n"

echo -e "####################################漏洞检查####################################\n\n\n"
# 拉取advisory-db有时候会失败
echo -e "cargo-audit: 从advisory-db搜索并打印项目依赖的crates的漏洞信息\n"
#cargo +stable install --locked cargo-audit || true
#mkdir -vp /usr/local/src/rust/advisory-db
cargo audit --db /usr/local/src/rust/advisory-db --no-fetch > workplace/cargo-audit.txt 2>&1 || true
echo -e "\n\n\n"
echo -e "####################################漏洞检查 end####################################\n\n\n"

echo -e "####################################静态检查####################################\n\n\n"
echo -e "cargo fmt: 代码格式化检查\n"
cargo fmt -- --check > workplace/cargo-check.txt 2>&1 || true
#cargo  fmt --all
echo -e "\n\n\n"

echo -e "cargo-clippy:  lints检查\n"
cargo clippy > workplace/cargo-clippy.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo deny:  配置在deny.toml，根据配置禁用crate，包含crate源位置、license、漏洞\n"
cargo install --locked cargo-deny
cargo deny check sources > workplace/cargo-deny-sources.txt 2>&1 || true
cargo deny check bans > workplace/cargo-deny-bans.txt 2>&1 || true
cargo deny check license > workplace/cargo-deny-license.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-strict:  检查unwrap函数\n"
cargo install --git https://github.com/hhatto/cargo-strict.git || true
cargo strict > workplace/cargo-strict.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-bloat:  检查crate或function占用可执行文件空间百分比\n"
cargo install cargo-bloat
# 检查各个crate在可执行文件的空间占用百分比
cargo bloat --release --crates > workplace/cargo-bloat-crates.txt 2>&1 || true
# 检查各个函数在可执行文件的空间占用百分比
cargo bloat --release -n 30 > workplace/cargo-bloat-func.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-llvm-lines:  计算泛型函数所有实例化中LLVM IR的行数\n"
cargo install cargo-llvm-lines
cargo llvm-lines --bin rust_build_demo1 > workplace/cargo-llvm-lines.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-outdated:  cargo 依赖的crates是否有新版本\n"
cargo install cargo-outdated || true
cargo outdated > workplace/cargo-outdated.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-deadlinks:  cargo doc中损坏的链接检查\n"
cargo install cargo-deadlinks
cargo deadlinks
cargo deadlinks --check-http
echo -e "\n\n\n"

echo -e "mlc:  检查损坏的链接\n"
cargo install mlc
mlc > workplace/cargo-mlc.txt 2>&1
echo -e "\n\n\n"
echo -e "####################################静态检查 end####################################\n\n\n"

echo -e "####################################动态检查####################################\n\n\n"
echo -e "cargo-profiler：  给程序画像\n"
# 程序画像，根据函数调用和cache访问的信息，分析问题
# 只限于linux
sudo apt-get install valgrind
cargo install cargo-profiler
cargo profiler callgrind > workplace/cargo-profiler-callgrind.txt 2>&1
cargo profiler cachegrind --release > workplace/cargo-profiler-cachegrind.txt 2>&1
echo -e "\n\n\n"

echo -e "cargo build: 构建\n"
cargo build
echo -e "\n\n\n"

echo -e "sanitizer快速内存错误检测器，能够检测unsafe部分\n"
export RUSTFLAGS=-Zsanitizer=address RUSTDOCFLAGS=-Zsanitizer=address
# 编译并执行
cargo run  > workplace/cargo-sanitizer-run.txt 2>&1 || true
unset RUSTFLAGS RUSTDOCFLAGS
echo -e "\n\n\n"
echo -e "####################################动态检查 end####################################\n\n\n"

echo -e "####################################测试####################################\n\n\n"
# 测试检查
echo -e "cargo-tarpaulin:  代码覆盖率检查\n"
# cargo-tarpaulin 只支持x86上的linux系统
cargo install cargo-tarpaulin
cargo tarpaulin --all  --all-features > workplace/cargo-tarpaulin.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-kcov:  代码覆盖率检查kcov\n"
#cargo install cargo-kcov || true
#sudo apt-get install cmake g++ pkg-config jq libssl-dev
#sudo apt-get install libcurl4-openssl-dev libelf-dev libdw-dev binutils-dev libiberty-dev
#cargo kcov --print-install-kcov-sh | sh || true
cargo kcov
echo -e "\n\n\n"

echo -e "grcov:  代码覆盖率\n"
# grcov
#cargo install grcov
# How to generate source-based coverage for a Rust project
#export RUSTFLAGS="-Zinstrument-coverage"
#cargo build
#export LLVM_PROFILE_FILE="your_name-%p-%m.profraw"
#cargo test
# How to generate .gcda files for a Rust project
#export CARGO_INCREMENTAL=0
#export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
#export RUSTDOCFLAGS="-Cpanic=abort"
#cargo build
#cargo test
# .gcda in target/debug/deps/ dir
#grcov . -s . --binary-path ./target/debug/ -t html --branch --ignore-not-existing -o ./target/debug/coverage/
# the report in target/debug/coverage/index.html
# for lcov
# apt-get install lcov
grcov . -s . --binary-path ./target/debug/ -t lcov --branch --ignore-not-existing -o ./target/debug/coverage/lcov.info
genhtml -o ./target/debug/coverage/ --show-details --highlight --ignore-errors source --legend ./target/debug/coverage/lcov.info > workplace/cargo-grcov.txt 2>&1 || true
# coveralls format
#grcov . --binary-path ./target/debug/ -t coveralls -s . --token YOUR_COVERALLS_TOKEN > coveralls.json
#unset RUSTFLAGS
#unset RUSTDOCFLAGS
echo -e "\n\n\n"

# fuzzcheck模糊测试
# 维护者少，待观察
#cargo +nightly install cargo-fuzzcheck

# fuzz测试
echo -e "cargo-fuzz:  模糊测试\n"
cargo install cargo-fuzz
#cargo fuzz init
#cargo fuzz add build_demo
cargo fuzz run build_demo > workplace/cargo-fuzz.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "honggfuzz模糊测试\n"
apt install build-essential binutils-dev libunwind-dev libblocksruntime-dev liblzma-dev
cargo install honggfuzz
export HFUZZ_RUN_ARGS="-t 20 -n 12 -v -N 10000000 --exit_upon_crash"
cargo hfuzz run honggfuzz > workplace/cargo-honggfuzz.txt 2>&1 || true
echo -e "\n\n\n"

echo -e "cargo-benchcmp:  性能检测结果对比\n"
cargo install cargo-benchcmp
cargo bench > 1.txt
# 运用修改
cargo bench > 2.txt
cargo benchcmp 1.txt 2.txt
echo -e "\n\n\n"

# mock测试，已添加代码，可直接使用cargo test执行
#mockall
#mockiato 官方从2019年尾已经不维护了，准备去掉

#benchmark
#criterion.rs

# 代码中已包含proptest和quickcheck
echo -e "cargo test： 测试\n"
echo -e "属性测试quickcheck\n"
echo -e "属性测试proptest，这个用例设计为会报错，影响tarpaulin等覆盖率工具，默认注释掉，需要尝试请打开注释\n"
cargo test > workplace/cargo-test.txt 2>&1 || true
echo -e "\n\n\n"
echo -e "####################################测试 end####################################\n\n\n"

echo -e "################################辅助开发和运维工具################################\n\n\n"
# 自动应用rustc建议的错误修复方式
#cargo fix

# 运行miri检测
#rustup +nightly component add miri
#cargo miri run
#cargo miri test

echo -e "cargo-expand：  宏展开工具\n"
cargo install cargo-expand
cargo expand --bin rust_build_demo1 > workplace/cargo-expand.txt 2>&1
echo -e "\n\n\n"

# 解开Rust语法糖，查看编译器对代码做了什么
# 2020年7月后无人工维护
# 需要使用nightly
#rustup install nightly
#rustup +nightly component add rustfmt
#cargo +nightly install cargo-inspect
#cargo +nightly inspect

echo -e "cargo-update：  更新依赖的crate\n"
#cargo install cargo-update
#cargo update
echo -e "\n\n\n"

echo -e "cargo-cache：  打印cargo cache信息\n"
#cargo install cargo-cache
#cargo cache
echo -e "\n\n\n"

echo -e "cargo-tomlfmt：  格式化Cargo.toml检测\n"
cargo install cargo-tomlfmt
cargo tomlfmt > workplace/cargo-tomlfmt.txt 2>&1
echo -e "\n\n\n"

echo -e "cargo-asm：  打印Rust代码的汇编或LLVM IR\n"
cargo install cargo-asm
cargo asm rust_build_demo1::main --rust > workplace/cargo-asm.txt 2>&1
echo -e "\n\n\n"

echo -e "cargo-do：  一行执行多个命令\n"
#cargo install cargo-do
#cargo do clean, update, build
echo -e "\n\n\n"

echo -e "cargo-deb：  从cargo项目创建Debian packages\n"
#cargo install cargo-deb
#cargo deb
echo -e "\n\n\n"

echo -e "cargo-generate：  以已有的git项目作为模板创建一个crate\n"
#cargo install cargo-generate
#cargo generate --git https://github.com/HPCWorkspace/rust_build_demo.git -name rust_build_demo_test
echo -e "\n\n\n"

echo -e "cargo-multi：  一条命令操作多个crates\n"
#cargo install cargo-multi
#cargo multi update
#cargo multi build
#cargo multi test
echo -e "\n\n\n"

echo -e "cargo-release：  发布新版本\n"
#cargo install cargo-release
# [level](https://github.com/sunng87/cargo-release/blob/master/docs/reference.md)
#cargo release [level]
echo -e "\n\n\n"

echo -e "cargo-rpm： 创建crate的rpm版本\n"
# 目前有问题： error: rpmbuild error: error running rpmbuild: No such file or directory (os error 2)
#cargo rpm init
#cargo rpm build
echo -e "\n\n\n"

echo -e "cargo-script：  执行rs脚本\n"
#cargo install cargo-script
cargo script ./src/toolsbox/cargo-script/helloworld.rs > workplace/cargo-script.txt 2>&1
echo -e "\n\n\n"

echo -e "rustdoc：  文档生成\n"
# 使用rustdoc
#cargo doc
echo -e "\n\n\n"

echo -e "cargo-bindgen：  根据.h头文件生成bingding文件\n"
#cargo install bindgen
#bindgen ./toolsbox/bindgen/input.h -o bindings.rs
echo -e "\n\n\n"
echo -e "################################辅助开发和运维工具 end################################\n\n\n"

echo -e "#####################################结果展示#####################################\n\n\n"
# 打印未使用的依赖项
# ‘\047’代表单引号，在我们的例子中最后是拼接命令awk 'NR>=381' workplace/cargo-udeps.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-deps：未使用的crate依赖项\n"
cat -n workplace/cargo-udeps.txt | grep "unused dependencies:" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-udeps.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 打印依赖树
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-tree：crates依赖关系树\n"
cat workplace/cargo-tree.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 程序画像结果
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-profiler：函数调用统计\n"
cat workplace/cargo-profiler-callgrind.txt
echo -e "cargo-profiler：cpu cache信息统计\n"
cat workplace/cargo-profiler-cachegrind.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 漏洞检测
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-audit：漏洞检测\n"
cat workplace/cargo-audit.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 统计unsafe代码片段信息
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-geiger：unsafe代码片段检测\n"
cat workplace/cargo-geiger.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 代码行数统计
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-tokei：代码行数统计\n"
cat workplace/cargo-tokei.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 检查unwrap函数
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-strict：检查unwrap函数\n"
cat workplace/cargo-strict.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# clippy lint检查
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-clippy：lints检查\n"
rm workplace/cargo-clippy-result.txt
grep "warn(clippy::" workplace/cargo-clippy.txt | awk -F"::" '{print $2}' | awk -F")" '{cmd= "c="$1"; a=\140grep \""$1"\" workplace/cargo-clippy.txt | wc -l\140; d=\042$c : $a\042; echo $d >> workplace/cargo-clippy-result.txt"; system(cmd)}'
grep "warnings emitted" workplace/cargo-clippy.txt
cat workplace/cargo-clippy-result.txt
#cat workplace/cargo-clippy.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# dylint lint检查
#cargo install cargo-dylint dylint-link

# 检查crate在可执行文件的空间占用百分比
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-bloat： 可执行文件的空间占用百分比\n"
cat -n workplace/cargo-bloat-crates.txt | grep "File  .text" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-bloat-crates.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 检查各个函数在可执行文件的空间占用百分比
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-bloat： 可执行文件的空间占用百分比\n"
cat -n workplace/cargo-bloat-func.txt | grep "File  .text" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-bloat-func.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 计算泛型函数所有实例化中LLVM IR的行数
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-llvm-lines： 各函数LLVM IR的行数\n"
cat -n workplace/cargo-llvm-lines.txt | grep "Lines        Copies" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-llvm-lines.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 显示crates概述信息
# cargo-modules
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-modules： 依赖树信息\n"
cat -n workplace/cargo-modules-tree.txt | grep "rust_build_demo1" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-modules-tree.txt"; system(cmd)}'
echo -e "cargo-modules： 依赖图信息\n"
cat -n workplace/cargo-modules-graph.txt | grep "digraph" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-modules-graph.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 代码覆盖率检测
# cargo-tarpaulin
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-tarpaulin： 代码覆盖率\n"
cat -n workplace/cargo-tarpaulin.txt | grep "Coverage Results:" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-tarpaulin.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 打印汇编代码
# cargo-asm
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-asm： 汇编代码展示\n"
cat workplace/cargo-asm.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 格式检查
# cargo-check
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-check： 格式检查结果\n"
cat workplace/cargo-check.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# license信息展示
# cargo-license
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-license： license结果展示\n"
cat workplace/cargo-license.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 查看依赖crates是否有新的版本
# cargo-outdated
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-outdated： 查看依赖crates是否有新的版本结果展示\n"
cat -n workplace/cargo-outdated.txt | grep "Name                                Project" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-outdated.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 宏展开展示
# cargo-expand
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-expand： 宏展开结果展示\n"
cat workplace/cargo-expand.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# cargo deny
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-deny： 源检查结果展示\n"
cat workplace/cargo-deny-sources.txt
echo -e "cargo-deny： 禁用crate结果展示\n"
cat workplace/cargo-deny-bans.txt
echo -e "cargo-deny： license禁用结果展示\n"
cat workplace/cargo-deny-license.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# cargo-script
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-script： rust脚本执行结果展示\n"
cat workplace/cargo-script.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# cargo-tomlfmt
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-tomlfmt： 配置检测结果展示\n"
cat workplace/cargo-tomlfmt.txt
echo -e "-----------------------------------------------------------------------------\n\n\n"

# cargo-mlc
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-mlc： 文档链接结果展示\n"
cat -n workplace/cargo-mlc.txt | grep "Result" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-mlc.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# cargo-grcov.txt 2>&1
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-grcov： 代码覆盖率结果展示\n"
cat -n workplace/cargo-grcov.txt | grep "Overall coverage rate" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-grcov.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# 测试结果
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "测试结果展示\n"
cat -n workplace/cargo-test.txt | grep "running" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-test.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# sanitizer
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "sanitizer快速内存错误检测器\n"
cat -n workplace/cargo-sanitizer-run.txt | grep "============================" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-sanitizer-run.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# honggfuzz
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "honggfuzz模糊测试\n"
cat -n workplace/cargo-honggfuzz.txt | grep "Summary iterations" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-honggfuzz.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"

# cargo-fuzz
echo -e "-----------------------------------------------------------------------------\n\n\n"
echo -e "cargo-fuzz模糊测试\n"
cat -n workplace/cargo-fuzz.txt | grep "Running" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-fuzz.txt"; system(cmd)}'
echo -e "-----------------------------------------------------------------------------\n\n\n"



echo -e "#####################################结果展示 end#####################################\n\n\n"