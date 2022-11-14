use gpgme::{Context, EncryptFlags, Key, Protocol};
use rustler::NifStruct;
use rustler::{Atom, Error};

mod atoms {
    rustler::atoms! {
        ok,
        error,
        eof,
        ectx,
        unknown // Other error
    }
}

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
        Err(_e) => false,
    }
}

#[derive(NifStruct)]
#[module = "GPG.NIF.Rust.EngineInfo"]
struct EngineInfo {
    pub directory: String,
    pub bin: String,
    pub err: String,
}

#[rustler::nif]
fn engine_info() -> EngineInfo {
    let gpgme = gpgme::init();
    let engine_info = gpgme.engine_info();

    match engine_info {
        Ok(v) => EngineInfo {
            directory: match v.get(Protocol::OpenPgp) {
                None => "not found".to_string(),
                Some(v) => match v.home_dir() {
                    Ok(path) => path.to_string(),
                    Err(_) => "invalid".to_string(),
                },
            },
            bin: match v.get(Protocol::OpenPgp) {
                None => "not found".to_string(),
                Some(v) => match v.path() {
                    Ok(path) => path.to_string(),
                    Err(_) => "invalid".to_string(),
                },
            },
            err: "".to_string(),
        },
        Err(e) => EngineInfo {
            directory: "".to_string(),
            bin: "".to_string(),
            err: e.to_string(),
        },
    }
}

fn get_context() -> Result<Context, Error> {
    match Context::from_protocol(Protocol::OpenPgp) {
        Err(_reason) => Err(Error::Term(Box::new(atoms::error()))),
        Ok(mut ctx) => {
            ctx.set_armor(true);
            match ctx.set_engine_info(Some("/usr/bin/gpg"), Some("~/.gnupg")) {
                Ok(_) => Ok(ctx),
                Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
            }
        }
    }
}

fn find_keys(ctx: &mut Context, keys: Vec<String>) -> Result<Vec<Key>, Error> {
    match ctx.find_keys(keys) {
        Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
        Ok(valid_keys) => Ok(valid_keys
            .filter_map(|x| x.ok())
            .filter(|k| k.can_encrypt())
            .collect()),
    }
}

#[rustler::nif]
fn encrypt(email: String, data: String) -> Result<Vec<u8>, Error> {
    let mut ctx = get_context()?;

    let key_input = vec![email];
    let keys: Vec<Key> = find_keys(&mut ctx, key_input)?;
    let mut output = Vec::new();

    match ctx.encrypt_with_flags(&keys, data, &mut output, EncryptFlags::ALWAYS_TRUST) {
        Ok(..) => Ok(output),
        Err(reason) => {
            Err(Error::Term(Box::new(reason.to_string())))
        }
    }
}

rustler::init!(
    "Elixir.GPG.NIF.Rust",
    [check_version, check_openpgp_supported, engine_info, encrypt]
);
