#![no_main]
#![feature(restricted_std)]

use sel4_root_task::{debug_println, root_task};

#[root_task(heap_size = 64 * 1024)]
fn main(_bootinfo: &sel4::BootInfoPtr) -> ! {
    std::panic::set_hook(Box::new(|info| {
        debug_println!("panic: {:?}", info);
    }));

    let r = std::panic::catch_unwind(|| {
        debug_println!("about to panic");
        panic!("panicking");
    });

    debug_println!("after panic: {:?}", r);

    debug_println!("TEST_PASS");

    sel4::init_thread::suspend_self()
}
