#![feature(test)]

extern crate test;
use test::Bencher;

pub fn add1(i :i32) -> i32 {
    i + 1
}

#[bench]
fn benchmark1(bencher: &mut Bencher) {
    bencher.iter(|| add1(1))
}

pub fn add2(i :i32) -> i32 {
    i + 2
}

#[bench]
fn benchmark2(bencher: &mut Bencher) {
    bencher.iter(|| add2(1))
}