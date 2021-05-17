#测试项目: https://github.com/HPCWorkspace/rust_build_demo/
#环境准备
#代理设置，根据实际情况使用
# export http_proxy="socks5://127.0.0.1:1080"
# export https_proxy="socks5://127.0.0.1:1080"
#安装rustup
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#更新rustup
# rustup update nightly && rustup default nightly
# 安装rustc-dev，包含hir ast解析的一些crate
#rustup component add rustc-dev



#代码格式化检查
cargo fmt -- --check
#cargo  fmt --all

#语法检查
cargo clippy

####################################依赖检查####################################
#crate发布者信息查询，执行慢，暂时关闭
#cargo install cargo-supply-chain
#cargo supply-chain
#统计项目使用到的crates的unsafe代码片段信息
cargo install --locked  cargo-geiger || true
cargo geiger || true

#跟踪和查询crates依存关系图
cargo install cargo-tree || true
cargo tree || true

#软件依赖图
cargo install cargo-deps || true
#sudo apt install graphviz
cargo deps --all-deps | dot -Tpng > graph.png || true

#代码行数统计
cargo install tokei || true
tokei || true

#检查Cargo.toml中未使用的依赖
cargo install cargo-udeps --locked
cargo +nightly udeps --all-targets || true

####################################漏洞检查####################################

#需要关闭代理尝试拉取advisory-db，有时候会失败
#从advisory-db搜索并打印项目依赖的crates的漏洞信息
git config --global --unset http.proxy
git config --global --unset https.proxy
unset http_proxy
unset https_proxy
env
cargo install --locked  cargo-audit || true
mkdir -vp /usr/local/src/rust/advisory-db
cargo audit --db /usr/local/src/rust/advisory-db || true
git config --global http.proxy socks5://127.0.0.1:1080
git config --global https.proxy socks5://127.0.0.1:1080
export http_proxy="socks5://127.0.0.1:1080"
export https_proxy="socks5://127.0.0.1:1080"

####################################静态检查####################################

#cargo deny配置在deny.toml，根据配置禁用crate，包含crate源位置、license、漏洞
cargo install --locked cargo-deny
cargo deny check || true

#检查unwrap函数
#cargo install --git https://github.com/hhatto/cargo-strict.git
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
cargo install cargo-outdated || true
cargo outdated || true 



####################################动态检查####################################

#给程序画像
#apt-get install valgrind
cargo install cargo-profiler
cargo build --release

#构建
cargo build

#sanitizer快速内存错误检测器，能够检测unsafe部分
export RUSTFLAGS=-Zsanitizer=address RUSTDOCFLAGS=-Zsanitizer=address
#编译并执行
cargo run || true 

####################################测试检查####################################

#测试检查
cargo install cargo-tarpaulin
cargo tarpaulin --all  --all-features || true

#代码覆盖率检查
#cargo install cargo-kcov || true
#sudo apt-get install cmake g++ pkg-config jq libssl-dev
#sudo apt-get install libcurl4-openssl-dev libelf-dev libdw-dev binutils-dev libiberty-dev
#cargo kcov --print-install-kcov-sh | sh || true
cargo kcov

#fuzzcheck模糊测试
#cargo +nightly install cargo-fuzzcheck

#fuzz
#cargo install cargo-fuzz
#cargo fuzz init
#cargo fuzz add build_demo
#cargo fuzz run build_demo

#代码中已包含proptest和quickcheck
#测试
cargo test || true


####################################辅助开发和运维工具####################################

#自动应用rustc建议的错误修复方式
#cargo fix

#运行miri检测
#rustup +nightly component add miri
#cargo miri run
#cargo miri test

#宏展开工具
#cargo install cargo-expand
#cargo expand

#解开Rust语法糖，查看编译器对代码做了什么
#需要使用nightly
#rustup install nightly
#rustup component add rustfmt
#cargo install cargo-inspect
#cargo inspect

#更新以来的crate
#cargo install cargo-update
#cargo update

#打印cargo cache信息
#cargo cache

#格式化Cargo.toml
#cargo install cargo-tomlfmt
#cargo tomlfmt

#打印Rust代码的汇编或LLVM IR
#cargo install cargo-asm
#cargo asm

#程序画像，根据函数调用和cache访问的信息，分析问题
#只限于linux
#sudo apt-get install valgrind
#cargo install cargo-profiler
#cargo profiler callgrind
#cargo profiler cachegrind --release





