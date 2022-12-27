#![allow(non_snake_case)]

use core::ffi::c_void;
use std::alloc::Layout;
use std::ffi::CStr;
use std::os::raw::c_char;

use pixels::{Pixels, SurfaceTexture};
use rayon::prelude::*;
use winit::{
    dpi::PhysicalSize,
    event::{Event, WindowEvent},
    event_loop::EventLoop,
    window::WindowBuilder,
};

#[repr(C)]
struct State(*mut c_void);

unsafe impl Send for State {}
unsafe impl Sync for State {}

impl Drop for State {
    fn drop(&mut self) {
        unsafe {
            let ret_val_layout = Layout::array::<u8>(update_result_size() as usize).unwrap();
            std::alloc::dealloc(self.0 as *mut u8, ret_val_layout);
        }
    }
}

#[repr(C)]
pub struct Canvas {
    pub height: u32,
    pub i: u32,
    pub j: u32,
    pub width: u32,
}

#[derive(Debug)]
#[repr(C)]
pub struct RGB {
    pub b: u8,
    pub g: u8,
    pub r: u8,
}

extern "C" {
    #[link_name = "roc__mainForHost_1__Init_caller"]
    fn call_init(canvas: &Canvas, closure_data: *const u8, state: *mut c_void);

    #[link_name = "roc__mainForHost_1__Init_size"]
    fn init_size() -> i64;

    #[link_name = "roc__mainForHost_1__Init_result_size"]
    fn init_result_size() -> i64;

    #[link_name = "roc__mainForHost_1__Update_caller"]
    fn call_update(state: *const c_void, closure_data: *const u8, output: *mut c_void);

    #[link_name = "roc__mainForHost_1__Update_size"]
    fn update_size() -> i64;

    #[link_name = "roc__mainForHost_1__Update_result_size"]
    fn update_result_size() -> i64;

    #[link_name = "roc__mainForHost_1__Render_caller"]
    fn call_render(state: *const c_void, closure_data: *const u8, output: *mut c_void);

    #[link_name = "roc__mainForHost_1__Render_size"]
    fn render_size() -> i64;

    #[link_name = "roc__mainForHost_1__Render_result_size"]
    fn render_result_size() -> i64;
}

#[no_mangle]
pub unsafe extern "C" fn roc_alloc(size: usize, _alignment: u32) -> *mut c_void {
    return libc::malloc(size);
}

#[no_mangle]
pub unsafe extern "C" fn roc_realloc(
    c_ptr: *mut c_void,
    new_size: usize,
    _old_size: usize,
    _alignment: u32,
) -> *mut c_void {
    return libc::realloc(c_ptr, new_size);
}

#[no_mangle]
pub unsafe extern "C" fn roc_dealloc(c_ptr: *mut c_void, _alignment: u32) {
    return libc::free(c_ptr);
}

#[no_mangle]
pub unsafe extern "C" fn roc_panic(c_ptr: *mut c_void, tag_id: u32) {
    match tag_id {
        0 => {
            let slice = CStr::from_ptr(c_ptr as *const c_char);
            let string = slice.to_str().unwrap();
            eprintln!("Roc hit a panic: {}", string);
            std::process::exit(1);
        }
        _ => todo!(),
    }
}

#[no_mangle]
pub unsafe extern "C" fn roc_memcpy(dst: *mut c_void, src: *mut c_void, n: usize) -> *mut c_void {
    libc::memcpy(dst, src, n)
}

#[no_mangle]
pub unsafe extern "C" fn roc_memset(dst: *mut c_void, c: i32, n: usize) -> *mut c_void {
    libc::memset(dst, c, n)
}

#[cfg(unix)]
#[no_mangle]
pub unsafe extern "C" fn roc_getppid() -> libc::pid_t {
    libc::getppid()
}

#[cfg(unix)]
#[no_mangle]
pub unsafe extern "C" fn roc_mmap(
    addr: *mut libc::c_void,
    len: libc::size_t,
    prot: libc::c_int,
    flags: libc::c_int,
    fd: libc::c_int,
    offset: libc::off_t,
) -> *mut libc::c_void {
    libc::mmap(addr, len, prot, flags, fd, offset)
}

#[cfg(unix)]
#[no_mangle]
pub unsafe extern "C" fn roc_shm_open(
    name: *const libc::c_char,
    oflag: libc::c_int,
    mode: libc::mode_t,
) -> libc::c_int {
    libc::shm_open(name, oflag, mode as libc::c_uint)
}

fn init(canvas: &Canvas) -> State {
    let ptr = unsafe {
        let ret_val_layout = Layout::array::<u8>(init_result_size() as usize).unwrap();
        let ret_val_buf = std::alloc::alloc(ret_val_layout) as *mut c_void;

        let closure_layout = Layout::array::<u8>(init_size() as usize).unwrap();
        let closure_data_buf = std::alloc::alloc(closure_layout);

        call_init(canvas, closure_data_buf, ret_val_buf);

        std::alloc::dealloc(closure_data_buf, closure_layout);
        ret_val_buf
    };

    State(ptr)
}

fn update_and_render(state: &State) -> (State, [u8; 4]) {
    let updated_state = unsafe {
        let ret_val_layout = Layout::array::<u8>(update_result_size() as usize).unwrap();
        let ret_val_buf = std::alloc::alloc(ret_val_layout) as *mut c_void;

        let closure_layout = Layout::array::<u8>(update_size() as usize).unwrap();
        let closure_data_buf = std::alloc::alloc(closure_layout);

        call_update(state.0, closure_data_buf, ret_val_buf);

        std::alloc::dealloc(closure_data_buf, closure_layout);

        ret_val_buf
    };

    let rendered = unsafe {
        let ret_val_layout = Layout::array::<u8>(render_result_size() as usize).unwrap();
        let ret_val_buf = std::alloc::alloc(ret_val_layout) as *mut c_void;

        let closure_layout = Layout::array::<u8>(render_size() as usize).unwrap();
        let closure_data_buf = std::alloc::alloc(closure_layout);

        call_render(updated_state, closure_data_buf, ret_val_buf);

        let rgb = &mut *(ret_val_buf as *mut RGB);
        let color = [rgb.r, rgb.g, rgb.b, 255];

        std::alloc::dealloc(closure_data_buf, closure_layout);
        std::alloc::dealloc(ret_val_buf as *mut u8, ret_val_layout);

        color
    };

    (State(updated_state), rendered)
}

#[no_mangle]
pub extern "C" fn rust_main() -> i32 {
    let width = 1200;
    let height = 800;

    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("Canvas")
        .with_resizable(false)
        .with_inner_size(PhysicalSize { width, height })
        .build(&event_loop)
        .unwrap();

    let mut pixels = {
        let surface_texture = SurfaceTexture::new(width, height, &window);
        Pixels::new(width, height, surface_texture).unwrap()
    };

    let indices: Vec<_> = (0..height)
        .rev()
        .flat_map(|j| (0..width).map(move |i| (i, j)))
        .collect();

    let mut states: Vec<State> = indices
        .into_par_iter()
        .map(|(i, j)| {
            let canvas = Canvas {
                i,
                j,
                width,
                height,
            };

            init(&canvas)
        })
        .collect();

    let mut samples = 0;

    event_loop.run(move |event, _, control_flow| {
        control_flow.set_poll();

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => {
                control_flow.set_exit();
            }
            Event::MainEventsCleared => {
                if samples < 500 {
                    eprintln!("Samples: {samples}");
                    let (new_states, rgb): (Vec<_>, Vec<_>) =
                        states.par_iter().map(update_and_render).unzip();

                    states = new_states;

                    let frame: Vec<u8> = rgb.into_iter().flatten().collect();

                    pixels.get_frame_mut().copy_from_slice(&frame);

                    samples += 1;

                    window.request_redraw();
                }
            }

            Event::RedrawRequested(_) => pixels.render().unwrap(),
            _ => (),
        }
    });
}
