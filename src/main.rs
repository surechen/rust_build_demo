#[cfg(test)]
#[macro_use]
extern crate quickcheck;

fn reverse<T: Clone>(xs: &[T]) -> Vec<T> {
    let mut rev = vec!();
    for x in xs.iter() {
        rev.insert(0, x.clone())
    }
    rev
}

#[cfg(test)]
mod tests {
    use crate::reverse;
    quickcheck! {
        fn prop(xs: Vec<u32>) -> bool {
            xs == reverse(&reverse(&xs))
        }
    }
}

fn main() {
    println!("Hello, world!");
    let mut n: i32 = 64;
    let p1 = &n as *const i32;
    let p2 = &mut n as *mut i32;

    unsafe {
        println!("r1 is: {}", *p1);
        println!("r2 is: {}", *p2);
    }
}
