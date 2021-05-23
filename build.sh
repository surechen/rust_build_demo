#测试项目: https://github.com/HPCWorkspace/rust_build_demo/
####################################环境准备####################################
#安装rustup
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#更新rustup
# rustup update nightly && rustup default nightly
# 安装rustc-dev，包含hir和ast解析相关的crate
#rustup component add rustc-dev rust-src

##############################################################################

####################################依赖检查####################################
#crate发布者信息查询，执行慢，暂时关闭
#cargo install cargo-supply-chain
#cargo supply-chain update
#cargo supply-chain crates
#cargo supply-chain publishers

#统计项目使用到的crates的unsafe代码片段信息
cargo install --locked cargo-geiger
cargo geiger || true

#跟踪和查询crates依存关系图
cargo install cargo-tree
cargo tree

#软件依赖图
cargo install cargo-deps
sudo apt install graphviz
cargo deps --all-deps | dot -Tpng > graph.png

#代码行数统计
cargo install tokei
tokei

#检查Cargo.toml中未使用的依赖
cargo install cargo-udeps --locked
cargo +nightly udeps --all-targets || true
##############################################################################

####################################漏洞检查####################################
#拉取advisory-db有时候会失败
#从advisory-db搜索并打印项目依赖的crates的漏洞信息
cargo install --locked  cargo-audit || true
mkdir -vp /usr/local/src/rust/advisory-db
cargo audit --db /usr/local/src/rust/advisory-db || true
##############################################################################

####################################静态检查####################################
#代码格式化检查
cargo fmt -- --check
#cargo  fmt --all

#语法检查
cargo clippy

#cargo deny配置在deny.toml，根据配置禁用crate，包含crate源位置、license、漏洞
cargo install --locked cargo-deny
cargo deny check || true

#检查unwrap函数
cargo install --git https://github.com/hhatto/cargo-strict.git
cargo strict

#检查各个函数在可执行文件的空间占用百分比
cargo install cargo-bloat
cargo bloat --release --crates

#计算泛型函数所有实例化中LLVM IR的行数
cargo install cargo-llvm-lines
cargo llvm-lines | head -20

#license检查
cargo install cargo-license
cargo license

#依赖的crates作者信息展示，依赖网络可能失败
#cargo install cargo-supply-chain --force || true
#cargo supply-chain crates  || true
#cargo 依赖的crates是否有新版本
cargo install cargo-outdated
cargo outdated || true 

#cargo doc中损坏的链接检查
cargo install cargo-deadlinks
cargo deadlinks
cargo deadlinks --check-http

#检查损坏的链接
cargo install mlc
mlc

##############################################################################

####################################动态检查####################################

#给程序画像
sudo apt-get install valgrind
cargo install cargo-profiler
cargo profiler callgrind
cargo profiler cachegrind --release

#构建
cargo build

#sanitizer快速内存错误检测器，能够检测unsafe部分
export RUSTFLAGS=-Zsanitizer=address RUSTDOCFLAGS=-Zsanitizer=address
#编译并执行
cargo run || true
unset RUSTFLAGS
unset RUSTDOCFLAGS
##############################################################################

#####################################测试#####################################

#测试检查



#代码覆盖率检查
#cargo-tarpaulin 只支持x86上的linux系统
cargo install cargo-tarpaulin
cargo tarpaulin --all  --all-features || true

#cargo install cargo-kcov || true
#sudo apt-get install cmake g++ pkg-config jq libssl-dev
#sudo apt-get install libcurl4-openssl-dev libelf-dev libdw-dev binutils-dev libiberty-dev
#cargo kcov --print-install-kcov-sh | sh || true
cargo kcov

#fuzzcheck模糊测试
#cargo +nightly install cargo-fuzzcheck

#fuzz测试
#cargo-fuzz模糊测试
cargo install cargo-fuzz
#cargo fuzz init
#cargo fuzz add build_demo
cargo fuzz run build_demo || true
#honggfuzz模糊测试
#apt install build-essential binutils-dev libunwind-dev libblocksruntime-dev liblzma-dev
#cargo install honggfuzz
#cargo hfuzz run honggfuzz

#性能检测
cargo install cargo-benchcmp
cargo bench > 1.txt
#运用修改
cargo bench > 2.txt
cargo benchcmp 1.txt 2.txt

#mock测试，已添加代码，可直接使用cargo test执行
#mockall
#mockiato

#benchmark
#criterion.rs

#代码中已包含proptest和quickcheck
#测试
cargo test || true
##############################################################################

################################辅助开发和运维工具################################

#自动应用rustc建议的错误修复方式
#cargo fix

#运行miri检测
#rustup +nightly component add miri
#cargo miri run
#cargo miri test

#宏展开工具
cargo install cargo-expand
cargo expand --bin rust_build_demo1

#解开Rust语法糖，查看编译器对代码做了什么
#需要使用nightly
#rustup install nightly
#rustup component add rustfmt
cargo install cargo-inspect
cargo inspect

#更新依赖的crate
#cargo install cargo-update
#cargo update

#打印cargo cache信息
#cargo cache

#格式化Cargo.toml
cargo install cargo-tomlfmt
cargo tomlfmt

#打印Rust代码的汇编或LLVM IR
cargo install cargo-asm
cargo asm

#程序画像，根据函数调用和cache访问的信息，分析问题
#只限于linux
sudo apt-get install valgrind
cargo install cargo-profiler
cargo profiler callgrind
cargo profiler cachegrind --release

#一行执行多个命令
#cargo install cargo-do
#cargo do clean, update, build

#从cargo项目创建Debian packages
#cargo install cargo-deb
#cargo deb

#以已有的git项目作为模板创建一个crate
#cargo install cargo-generate
#cargo generate --git https://github.com/HPCWorkspace/rust_build_demo.git -name rust_build_demo_test

#一条命令操作多个crates
#cargo install cargo-multi
#cargo multi update
#cargo multi build
#cargo multi test

#发布新版本
#cargo install cargo-release
#[level](https://github.com/sunng87/cargo-release/blob/master/docs/reference.md)
#cargo release [level]

#创建crate的rpm版zhangxinzhangxsssd本
#目前有问题： error: rpmbuild error: error running rpmbuild: No such file or directory (os error 2)
#cargo rpm init
#cargo rpm build

#执行rs脚本
#cargo install cargo-script
#cargo script ./toolsbox/cargo-script/helloworld.rs

#文档生成
#使用rustdoc
#cargo doc

#根据.h头文件生成bingding文件
#cargo install bindgen
#bindgen ./toolsbox/bindgen/input.h -o bindings.rs
##############################################################################