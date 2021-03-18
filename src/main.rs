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
