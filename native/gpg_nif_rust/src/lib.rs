use gpgme::Protocol;

use rustler::NifStruct;

#[rustler::nif]
fn check_version() -> &'static str {
    //let proto =  Protocol::OpenPgp;
    //let mut ctx = Context::from_protocol(proto)?;
    let gpgme = gpgme::init();
    gpgme.version()
}

#[rustler::nif]
fn check_openpgp_supported() -> bool {
    let gpgme = gpgme::init();
    let proto = Protocol::OpenPgp;
    match gpgme.check_engine_version(proto) {
        Ok(_v) => true,
        Err(_e) => false 
    }
}

#[derive(NifStruct)]
#[module = "GPG.NIF.Rust.EngineInfo"]
struct EngineInfo {
    pub directory: String,
    pub bin: String,
    pub err: String
}

#[rustler::nif]
fn engine_info() -> EngineInfo {
    let gpgme = gpgme::init();
    let engine_info = gpgme.engine_info();

    match engine_info {
        Ok(v) =>
            // iterate over v to get the values
            EngineInfo{
                directory: match v.get(Protocol::OpenPgp) {
                    None => "not found".to_string(),
                    Some(v) => match v.home_dir() {
                        Ok(path) => path.to_string(),
                        Err(_) => "invalid".to_string()
                    }
                },
                bin: match v.get(Protocol::OpenPgp) {
                    None => "not found".to_string(),
                    Some(v) => match v.path() {
                        Ok(path) => path.to_string(),
                        Err(_) => "invalid".to_string()
                    }
                },
                err: "".to_string()
            },
        Err(e) =>
            EngineInfo{
                directory: "".to_string(),
                bin: "".to_string(),
                err: e.to_string()
            }
    }
}



rustler::init!("Elixir.GPG.NIF.Rust", [check_version, check_openpgp_supported, engine_info]);
