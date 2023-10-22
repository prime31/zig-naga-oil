use std::{
    collections::HashMap,
    ffi::{c_char, c_void, CStr, CString},
    ptr::{self, null},
};

use naga_oil::compose::{NagaModuleDescriptor, ShaderDefValue};

type NagaComposer = naga_oil::compose::Composer;
type NagaComposableModuleDescriptor<'a> = naga_oil::compose::ComposableModuleDescriptor<'a>;

type Composer = *mut c_void;
type ShaderDefs = *mut c_void;
type Module = *mut c_void;

// unsafe fn c_str_to_string(str: *const c_char) -> String {
//     match str == null() {
//         true => String::new(),
//         false => CStr::from_ptr(str).to_str().unwrap().to_string(),
//     }
// }

unsafe fn c_str_to_option_string(str: *const c_char) -> Option<String> {
    match str == null() {
        true => None,
        false => Option::Some(CStr::from_ptr(str).to_str().unwrap().to_owned()),
    }
}

unsafe fn c_str_to_str(str: *const c_char) -> &'static str {
    match str == null() {
        true => "",
        false => CStr::from_ptr(str).to_str().unwrap(),
    }
}

#[repr(C)]
pub struct ModuleDescriptor {
    pub source: *const c_char,
    pub file_path: *const c_char,
    // pub shader_type: ShaderType,
    pub shader_defs: ShaderDefs,
    // pub additional_imports: &'a [ImportDefinition],
}

impl<'a> Into<NagaModuleDescriptor<'a>> for ModuleDescriptor {
    fn into(self) -> NagaModuleDescriptor<'a> {
        unsafe {
            let shader_defs: Box<HashMap<String, ShaderDefValue>> = Box::new(HashMap::new());

            NagaModuleDescriptor {
                source: c_str_to_str(self.source),
                file_path: c_str_to_str(self.file_path),
                shader_defs: *shader_defs,
                ..Default::default()
            }
        }
    }
}

#[repr(C)]
pub struct ComposableModuleDescriptor {
    pub source: *const c_char,
    pub file_path: *const c_char,
    // pub language: ShaderLanguage,
    pub as_name: *const c_char,
    // pub additional_imports: &'a [ImportDefinition],
    pub shader_defs: ShaderDefs,
}

impl<'a> Into<NagaComposableModuleDescriptor<'a>> for ComposableModuleDescriptor {
    fn into(self) -> NagaComposableModuleDescriptor<'a> {
        unsafe {
            let shader_defs: Box<HashMap<String, ShaderDefValue>> = Box::new(HashMap::new());

            NagaComposableModuleDescriptor {
                source: c_str_to_str(self.source),
                file_path: c_str_to_str(self.file_path),
                as_name: c_str_to_option_string(self.as_name),
                shader_defs: *shader_defs,
                ..Default::default()
            }
        }
    }
}

#[no_mangle]
pub extern "C" fn composer_create() -> Composer {
    let composer = Box::new(NagaComposer::default());
    Box::into_raw(composer) as *mut c_void
}

#[no_mangle]
pub unsafe extern "C" fn composer_destroy(composer: Composer) {
    let composer = Box::from_raw(composer as *mut NagaComposer);
    drop(composer);
}

#[no_mangle]
pub unsafe extern "C" fn add_composable_module(composer: Composer, desc: ComposableModuleDescriptor) -> i32 {
    let mut composer = Box::from_raw(composer as *mut NagaComposer);
    let result = composer.add_composable_module(desc.into());

    let result = match result {
        Ok(_) => {
            // println!("{} -> {:#?}", module.name, module)
            1
        }
        Err(e) => {
            println!("? -> {e:#?}");
            -1
        }
    };
    Box::leak(composer);
    result
}

#[no_mangle]
pub unsafe extern "C" fn make_naga_module(composer: Composer, desc: ModuleDescriptor) -> Module {
    let mut composer = Box::from_raw(composer as *mut NagaComposer);
    let result = composer.make_naga_module(desc.into());

    match result {
        Ok(module) => {
            Box::leak(composer);
            Box::into_raw(Box::new(module)) as *mut c_void
        }
        Err(e) => {
            println!("{}", e.emit_to_string(&composer));
            Box::leak(composer);
            ptr::null_mut()
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn naga_module_to_source(module: Module) -> *mut c_char {
    let module = Box::from_raw(module as *mut naga::Module);

    let info = naga::valid::Validator::new(
        naga::valid::ValidationFlags::all(),
        naga::valid::Capabilities::default(),
    )
    .validate(&module)
    .unwrap();

    let wgsl = naga::back::wgsl::write_string(&module, &info, naga::back::wgsl::WriterFlags::EXPLICIT_TYPES).unwrap();
    Box::leak(module);
    CString::new(wgsl).unwrap().into_raw()
}

#[no_mangle]
pub unsafe extern "C" fn source_destroy(src: *mut c_char) {
    drop(CString::from_raw(src));
}

// HashMap helpers
#[no_mangle]
pub unsafe extern "C" fn shader_defs_create() -> ShaderDefs {
    let map: Box<HashMap<String, ShaderDefValue>> = Box::new(HashMap::new());
    Box::into_raw(map) as *mut c_void
}

#[no_mangle]
pub unsafe extern "C" fn shader_defs_destroy(map: ShaderDefs) {
    let map: Box<HashMap<String, ShaderDefValue>> = Box::from_raw(map as *mut HashMap<String, ShaderDefValue>);
    drop(map);
}

#[no_mangle]
pub unsafe extern "C" fn shader_defs_insert_sint(map: ShaderDefs, key: *const c_char, value: i32) {
    let mut map: Box<HashMap<String, ShaderDefValue>> = Box::from_raw(map as *mut HashMap<String, ShaderDefValue>);

    let key = CStr::from_ptr(key).to_str().unwrap().to_string();
    map.insert(key, ShaderDefValue::Int(value));
    Box::leak(map);
}

#[no_mangle]
pub unsafe extern "C" fn shader_defs_insert_uint(map: ShaderDefs, key: *const c_char, value: u32) {
    let mut map: Box<HashMap<String, ShaderDefValue>> = Box::from_raw(map as *mut HashMap<String, ShaderDefValue>);

    let key = CStr::from_ptr(key).to_str().unwrap().to_string();
    map.insert(key, ShaderDefValue::UInt(value));
    Box::leak(map);
}

#[no_mangle]
pub unsafe extern "C" fn shader_defs_insert_bool(map: ShaderDefs, key: *const c_char, value: bool) {
    let mut map: Box<HashMap<String, ShaderDefValue>> = Box::from_raw(map as *mut HashMap<String, ShaderDefValue>);

    let key = CStr::from_ptr(key).to_str().unwrap().to_string().to_owned();
    map.insert(key, ShaderDefValue::Bool(value));
    Box::leak(map);
}

#[no_mangle]
pub unsafe extern "C" fn shader_defs_debug_print(map: ShaderDefs) {
    let map: Box<HashMap<String, ShaderDefValue>> = Box::from_raw(map as *mut HashMap<String, ShaderDefValue>);
    println!("map: {:?}", map);
    Box::leak(map);
}
