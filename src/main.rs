fn main() {
    println!("Hello, world!");
    let mut n: i32 = 64;
    let p1 = &num as *const i32;
    let r2 = &mut num as *mut i32;

    unsafe {
        println!("r1 is: {}", *r1); 
        println!("r2 is: {}", *r2);
    }
}
