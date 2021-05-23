#[cfg(target_os = "linux")]
use honggfuzz::fuzz;

#[cfg(target_os = "linux")]
fn main() {
    // Here you can parse `std::env::args and
    // setup / initialize your project

    let mut some_global_state = 0u64;
    let mut count = 0;
    // You have full control over the loop but
    // you're supposed to call `fuzz` ad vitam aeternam
    // loop {
    //     // The fuzz macro gives an arbitrary object (see `arbitrary crate`)
    //     // to a closure-like block of code.
    //     // For performance reasons, it is recommended that you use the native type
    //     // `&[u8]` when possible.
    //     // Here, this slice will contain a "random" quantity of "random" data.
    //     if count >= 30 {
    //         return;
    //     }
    //     count += 1;
    //     fuzz!(|data: &[u8]| {
    //         some_global_state += 1;
    //         if data.len() != 3 {
    //             return;
    //         }
    //         if data[0] != b'h' {
    //             return;
    //         }
    //         if data[1] != b'e' {
    //             return;
    //         }
    //         if data[2] != b'y' {
    //             return;
    //         }
    //         panic!("BOOM")
    //     });
    // }

    fuzz!(|data: &[u8]| {
        some_global_state += 1;
        if data.len() != 3 {
            return;
        }
        if data[0] != b'h' {
            return;
        }
        if data[1] != b'e' {
            return;
        }
        if data[2] != b'y' {
            return;
        }
        panic!("BOOM")
    });
}
