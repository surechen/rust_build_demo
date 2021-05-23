#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    if let Ok(s) = std::str::from_utf8(data) {
        if s.len() > 30 {
            println!("panic url:{}", s);
            panic!("BOOM");
        }
    }
});
