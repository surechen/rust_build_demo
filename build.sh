#!/bin/bash
# 测试项目: https://github.com/HPCWorkspace/rust_build_demo/
####################################环境准备####################################
# 安装rustup
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# 更新rustup
# rustup update nightly && rustup default nightly
# 安装rustc-dev，包含hir和ast解析相关的crate
# 安装rustfmt
# 安装clippy
rustup component add rustc-dev rust-src clippy rustfmt miri llvm-tools-preview
mkdir workplace
##############################################################################

####################################依赖检查####################################
# crate发布者信息查询，执行慢，暂时关闭
#cargo install cargo-supply-chain
#cargo supply-chain update
#cargo supply-chain crates
#cargo supply-chain publishers

# 统计项目使用到的crates的unsafe代码片段信息
# 需要正确安装openssl
cargo install --locked cargo-geiger
cargo geiger > workplace/cargo-geiger.txt 2>&1 || true

# 跟踪和查询crates依存关系图
cargo install cargo-tree
cargo tree > workplace/cargo-tree.txt 2>&1

# 软件依赖图
cargo install cargo-deps
sudo apt install graphviz
cargo deps --all-deps | dot -Tpng > workplace/cargo-deps.png

# 代码行数统计
cargo install tokei
tokei > workplace/cargo-tokei.txt 2>&1 || true

# 检查Cargo.toml中未使用的依赖
cargo +stable install cargo-udeps --locked
cargo +nightly udeps --all-targets > workplace/cargo-udeps.txt 2>&1 || true

# 显示crates概述信息
# cargo-modules
cargo install cargo-modules
cargo modules generate tree --bin rust_build_demo1 > workplace/cargo-modules-tree.txt 2>&1
cargo modules generate graph --bin rust_build_demo1 > workplace/cargo-modules-graph.txt 2>&1

# license信息展示
cargo install cargo-license
cargo license > workplace/cargo-license.txt 2>&1
##############################################################################

####################################漏洞检查####################################
# 拉取advisory-db有时候会失败
# 从advisory-db搜索并打印项目依赖的crates的漏洞信息
#cargo +stable install --locked cargo-audit || true
#mkdir -vp /usr/local/src/rust/advisory-db
cargo audit --db /usr/local/src/rust/advisory-db --no-fetch > workplace/cargo-audit.txt 2>&1 || true
##############################################################################

####################################静态检查####################################
# 代码格式化检查
cargo fmt -- --check > workplace/cargo-check.txt 2>&1 || true
#cargo  fmt --all

# 语法检查
cargo clippy > workplace/cargo-clippy.txt 2>&1 || true

# cargo deny配置在deny.toml，根据配置禁用crate，包含crate源位置、license、漏洞
cargo install --locked cargo-deny
cargo deny check sources > workplace/cargo-deny-sources.txt 2>&1 || true
cargo deny check bans > workplace/cargo-deny-bans.txt 2>&1 || true
cargo deny check license > workplace/cargo-deny-license.txt 2>&1 || true

# 检查unwrap函数
cargo install --git https://github.com/hhatto/cargo-strict.git || true
cargo strict > workplace/cargo-strict.txt 2>&1 || true

# 检查crate或function占用可执行文件空间百分比
cargo install cargo-bloat
# 检查各个crate在可执行文件的空间占用百分比
cargo bloat --release --crates > workplace/cargo-bloat-crates.txt 2>&1 || true
# 检查各个函数在可执行文件的空间占用百分比
cargo bloat --release -n 30 > workplace/cargo-bloat-func.txt 2>&1 || true

# 计算泛型函数所有实例化中LLVM IR的行数
cargo install cargo-llvm-lines
cargo llvm-lines --bin rust_build_demo1 > workplace/cargo-llvm-lines.txt 2>&1 || true

# cargo 依赖的crates是否有新版本
cargo install cargo-outdated || true
cargo outdated > workplace/cargo-outdated.txt 2>&1 || true

# cargo doc中损坏的链接检查
cargo install cargo-deadlinks
cargo deadlinks
cargo deadlinks --check-http

# 检查损坏的链接
cargo install mlc
mlc

##############################################################################

####################################动态检查####################################

# 给程序画像
# 程序画像，根据函数调用和cache访问的信息，分析问题
# 只限于linux
sudo apt-get install valgrind
cargo install cargo-profiler
cargo profiler callgrind > workplace/cargo-profiler-callgrind.txt 2>&1
cargo profiler cachegrind --release > workplace/cargo-profiler-cachegrind.txt 2>&1

# 构建
cargo build

# sanitizer快速内存错误检测器，能够检测unsafe部分
export RUSTFLAGS=-Zsanitizer=address RUSTDOCFLAGS=-Zsanitizer=address
# 编译并执行
cargo run || true
unset RUSTFLAGS
unset RUSTDOCFLAGS
##############################################################################

#####################################测试#####################################

# 测试检查
# 代码覆盖率检查
# cargo-tarpaulin 只支持x86上的linux系统
cargo install cargo-tarpaulin
cargo tarpaulin --all  --all-features > workplace/cargo-tarpaulin.txt 2>&1 || true

# 代码覆盖率检查kcov
#cargo install cargo-kcov || true
#sudo apt-get install cmake g++ pkg-config jq libssl-dev
#sudo apt-get install libcurl4-openssl-dev libelf-dev libdw-dev binutils-dev libiberty-dev
#cargo kcov --print-install-kcov-sh | sh || true
cargo kcov

# 代码覆盖率
# grcov
cargo install grcov
# How to generate source-based coverage for a Rust project
export RUSTFLAGS="-Zinstrument-coverage"
cargo build
export LLVM_PROFILE_FILE="your_name-%p-%m.profraw"
cargo test
# How to generate .gcda files for a Rust project
export CARGO_INCREMENTAL=0
export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
export RUSTDOCFLAGS="-Cpanic=abort"
cargo build
cargo test
# .gcda in target/debug/deps/ dir
grcov . -s . --binary-path ./target/debug/ -t html --branch --ignore-not-existing -o ./target/debug/coverage/
# the report in target/debug/coverage/index.html
# for lcov
#grcov . -s . --binary-path ./target/debug/ -t lcov --branch --ignore-not-existing -o ./target/debug/coverage/lcov.info
#genhtml -o ./target/debug/coverage/ --show-details --highlight --ignore-errors source --legend ./target/debug/coverage/lcov.info
# coveralls format
#grcov . --binary-path ./target/debug/ -t coveralls -s . --token YOUR_COVERALLS_TOKEN > coveralls.json



# fuzzcheck模糊测试
#cargo +nightly install cargo-fuzzcheck

# fuzz测试
# cargo-fuzz模糊测试
cargo install cargo-fuzz
#cargo fuzz init
#cargo fuzz add build_demo
cargo fuzz run build_demo || true
# honggfuzz模糊测试
#apt install build-essential binutils-dev libunwind-dev libblocksruntime-dev liblzma-dev
#cargo install honggfuzz
#cargo hfuzz run honggfuzz

# 性能检测
cargo install cargo-benchcmp
cargo bench > 1.txt
# 运用修改
cargo bench > 2.txt
cargo benchcmp 1.txt 2.txt

# mock测试，已添加代码，可直接使用cargo test执行
#mockall
#mockiato 官方从2019年尾已经不维护了，准备去掉

#benchmark
#criterion.rs

# 代码中已包含proptest和quickcheck
# 测试
cargo test || true
##############################################################################

################################辅助开发和运维工具################################

# 自动应用rustc建议的错误修复方式
#cargo fix

# 运行miri检测
#rustup +nightly component add miri
#cargo miri run
#cargo miri test

# 宏展开工具
cargo install cargo-expand
cargo expand --bin rust_build_demo1 > workplace/cargo-expand.txt 2>&1

# 解开Rust语法糖，查看编译器对代码做了什么
# 2020年7月后无人工维护
# 需要使用nightly
#rustup install nightly
#rustup component add rustfmt
#cargo install cargo-inspect
#cargo inspect

# 更新依赖的crate
#cargo install cargo-update
#cargo update

# 打印cargo cache信息
#cargo cache

# 格式化Cargo.toml检测
cargo install cargo-tomlfmt
cp ./Cargo.toml ./Cargo_bef.toml
cargo tomlfmt
./build/diff.sh ./Cargo.toml ./Cargo_bef.toml
cp ./Cargo_bef.toml ./Cargo.toml
rm ./Cargo_bef.toml

# 打印Rust代码的汇编或LLVM IR
cargo install cargo-asm
cargo asm rust_build_demo1::main --rust > workplace/cargo-asm.txt 2>&1

# 一行执行多个命令
#cargo install cargo-do
#cargo do clean, update, build

# 从cargo项目创建Debian packages
#cargo install cargo-deb
#cargo deb

# 以已有的git项目作为模板创建一个crate
#cargo install cargo-generate
#cargo generate --git https://github.com/HPCWorkspace/rust_build_demo.git -name rust_build_demo_test

# 一条命令操作多个crates
#cargo install cargo-multi
#cargo multi update
#cargo multi build
#cargo multi test

# 发布新版本
#cargo install cargo-release
# [level](https://github.com/sunng87/cargo-release/blob/master/docs/reference.md)
#cargo release [level]

# 创建crate的rpm版本
# 目前有问题： error: rpmbuild error: error running rpmbuild: No such file or directory (os error 2)
#cargo rpm init
#cargo rpm build

# 执行rs脚本
#cargo install cargo-script
#cargo script ./toolsbox/cargo-script/helloworld.rs

# 文档生成
# 使用rustdoc
#cargo doc

# 根据.h头文件生成bingding文件
#cargo install bindgen
#bindgen ./toolsbox/bindgen/input.h -o bindings.rs


##############################################################################


#####################################结果展示#####################################

# 打印未使用的依赖项
# ‘\047’代表单引号，在我们的例子中最后是拼接命令awk 'NR>=381' workplace/cargo-udeps.txt
echo -e "cargo-deps：未使用的crate依赖项\n"
cat -n workplace/cargo-udeps.txt | grep "unused dependencies:" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-udeps.txt"; system(cmd)}'

# 打印依赖树
echo -e "cargo-tree：crates依赖关系树\n"
cat workplace/cargo-tree.txt

# 程序画像结果
echo -e "cargo-profiler：函数调用统计\n"
cat workplace/cargo-profiler-callgrind.txt
echo -e "cargo-profiler：cpu cache信息统计\n"
cat workplace/cargo-profiler-cachegrind.txt

# 漏洞检测
echo -e "cargo-audit：漏洞检测\n"
cat workplace/cargo-audit.txt

# 统计unsafe代码片段信息
echo -e "cargo-geiger：unsafe代码片段检测\n"
cat workplace/cargo-geiger.txt

# 代码行数统计
echo -e "cargo-tokei：代码行数统计\n"
cat workplace/cargo-tokei.txt

# 检查unwrap函数
echo -e "cargo-strict：检查unwrap函数\n"
cat workplace/cargo-strict.txt

# clippy lint检查
echo -e "cargo-clippy：lints检查\n"
rm workplace/cargo-clippy-result.txt
grep "warn(clippy::" workplace/cargo-clippy.txt | awk -F"::" '{print $2}' | awk -F")" '{cmd= "c="$1"; a=\140grep \""$1"\" workplace/cargo-clippy.txt | wc -l\140; d=\042$c : $a\042; echo $d >> workplace/cargo-clippy-result.txt"; system(cmd)}'
grep "warnings emitted" workplace/cargo-clippy.txt
cat workplace/cargo-clippy-result.txt
#cat workplace/cargo-clippy.txt

# dylint lint检查
#cargo install cargo-dylint dylint-link

# 检查crate在可执行文件的空间占用百分比
echo -e "cargo-bloat： 可执行文件的空间占用百分比\n"
cat -n workplace/cargo-bloat-crates.txt | grep "File  .text" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-bloat-crates.txt"; system(cmd)}'

# 检查各个函数在可执行文件的空间占用百分比
echo -e "cargo-bloat： 可执行文件的空间占用百分比\n"
cat -n workplace/cargo-bloat-func.txt | grep "File  .text" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-bloat-func.txt"; system(cmd)}'

# 计算泛型函数所有实例化中LLVM IR的行数
echo -e "cargo-llvm-lines： 各函数LLVM IR的行数\n"
cat -n workplace/cargo-llvm-lines.txt | grep "Lines        Copies" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-llvm-lines.txt"; system(cmd)}'

# 显示crates概述信息
# cargo-modules
cat -n workplace/cargo-modules-tree.txt | grep "rust_build_demo1" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-modules-tree.txt"; system(cmd)}'
cat -n workplace/cargo-modules-graph.txt | grep "digraph" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-modules-graph.txt"; system(cmd)}'

# 代码覆盖率检测
# cargo-tarpaulin
cat -n workplace/cargo-tarpaulin.txt | grep "Coverage Results:" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-tarpaulin.txt"; system(cmd)}'

# 打印汇编代码
# cargo-asm
cat workplace/cargo-asm.txt

# 格式检查
# cargo-check
cat workplace/cargo-check.txt

# license信息展示
# cargo-license
cat workplace/cargo-license.txt

# 查看依赖crates是否有新的版本
# cargo-outdated
cat -n workplace/cargo-outdated.txt | grep "Name                                Project" | awk '{cmd= "awk \047NR>="$1"\047 workplace/cargo-outdated.txt"; system(cmd)}'

# 宏展开展示
# cargo-expand
cat workplace/cargo-expand.txt

# cargo deny
cat workplace/cargo-deny-sources.txt
cat workplace/cargo-deny-bans.txt
cat workplace/cargo-deny-license.txt


##############################################################################