//#![deny(clippy::all)]
//#![warn(clippy::all)]
//#![allow(clippy::all)]

#[allow(dead_code)]
#[warn(absurd_extreme_comparisons)]
fn absurd_extreme_comparisons() {
    let vec: Vec<isize> = Vec::new();
    if vec.len() <= 0 {}
    if 100 > i32::MAX {}
}

#[allow(dead_code)]
#[warn(almost_swapped)]
fn almost_swapped() {
    let mut a = 1;
    let mut b = 2;
    a = b;
    b = a;
}

#[allow(dead_code)]
#[warn(approx_constant)]
fn approx_constant() {
    let x = 3.14;
    let y = 1_f64 / x;
}

#[allow(dead_code)]
#[warn(as_conversions)]
fn as_conversions() {
    fn f(a: i16) {
        let _s = a;
    }
    let a: i32 = i32::MAX;
    f(a as i16);
}

#[allow(dead_code)]
#[warn(assertions_on_constants)]
fn assertions_on_constants() {
    assert!(false);
    assert!(true);
    const B: bool = false;
    assert!(B)
}

#[allow(dead_code)]
#[warn(assign_op_pattern)]
fn assign_op_pattern() {
    let mut a = 5;
    let b = 0;

    // Bad
    a = a + b;

    // Good
    a += b;
}
