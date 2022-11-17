use gpgme::{Context, Data, EncryptFlags, Key, Protocol};
use rustler::{Atom, Error, NifMap, NifTuple};

mod atoms {
    rustler::atoms! {
        ok,
        error,
        unknown
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

#[derive(NifMap)]
struct LocalEngineInfo {
    pub directory: String,
    pub bin: String,
}

#[rustler::nif]
fn engine_info(home_dir: String, path: String) -> Result<LocalEngineInfo, Error> {
    let ctx = get_context(home_dir, path)?;
    let engine_info = ctx.engine_info();
    Ok(LocalEngineInfo {
        directory: match engine_info.home_dir() {
            Ok(h) => h.to_string(),
            Err(_reason) => "not found".to_string(),
        },
        bin: match engine_info.path() {
            Err(_reason) => "not found".to_string(),
            Ok(path) => path.to_string(),
        },
    })
}

fn get_context(home_dir: String, path: String) -> Result<Context, Error> {
    match Context::from_protocol(Protocol::OpenPgp) {
        Err(_reason) => Err(Error::Term(Box::new(atoms::error()))),
        Ok(mut ctx) => {
            ctx.set_armor(true);
            match ctx.set_engine_info(Some(path), Some(home_dir)) {
                Ok(_) => Ok(ctx),
                Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
            }
        }
    }
}

fn find_key(ctx: &mut Context, key: String) -> Result<Key, Error> {
    match ctx.locate_key(key) {
        Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
        Ok(valid_key) => Ok(valid_key),
    }
}

#[derive(NifTuple)]
struct OkTuple {
    ok: Atom,
    values: String,
}

#[rustler::nif]
fn encrypt(email: String, data: String, home_dir: String, path: String) -> Result<OkTuple, Error> {
    let mut ctx = get_context(home_dir, path)?;

    let key: Key = find_key(&mut ctx, email)?;

    let mut output = Vec::new();

    match ctx.encrypt_with_flags(Some(&key), data, &mut output, EncryptFlags::ALWAYS_TRUST) {
        Ok(..) => match String::from_utf8(output) {
            Ok(s) => Ok(OkTuple {
                ok: atoms::ok(),
                values: s.to_string(),
            }),
            Err(e) => Err(Error::Term(Box::new(e.to_string()))),
        },
        Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
    }
}

#[rustler::nif]
fn decrypt(data: String, home_dir: String, path: String) -> Result<OkTuple, Error> {
    let mut ctx = get_context(home_dir, path)?;
    let mut output = Vec::new();

    match ctx.decrypt(data, &mut output) {
        Ok(..) => match String::from_utf8(output) {
            Ok(s) => Ok(OkTuple {
                ok: atoms::ok(),
                values: s.to_string(),
            }),
            Err(e) => Err(Error::Term(Box::new(e.to_string()))),
        },
        Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
    }
}

#[rustler::nif]
fn import_key(key: String, home_dir: String, path: String) -> Result<OkTuple, Error> {
    let mut ctx = get_context(home_dir, path)?;

    match Data::from_bytes(key) {
        Ok(mut data_mem) => {
            // let d = ctx.read_keys(&mut data_mem).unwrap();
            //for key in d {
            let import_result = ctx.import(&mut data_mem);
            return match import_result {
                Ok(import_key) => Ok(OkTuple {
                    ok: atoms::ok(),
                    values: import_key.imported().to_string(),
                }),
                Err(e) => Err(Error::Term(Box::new(e.to_string()))),
            };
            //}
            //return Err(Error::Term(Box::new("invalid".to_string())));
        }
        Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
    }
}

#[rustler::nif]
fn public_key(email: String, home_dir: String, path: String) -> Result<OkTuple, Error> {
    let mut ctx = get_context(home_dir, path)?;
    let key: Key = find_key(&mut ctx, email)?;
    Ok(OkTuple {
        ok: atoms::ok(),
        values: key.fingerprint().unwrap_or("").to_string(),
    })
}

#[derive(NifMap)]
struct PublicKeyInfo {
    pub id: String,
    pub fingerprint: String,
    pub can_encrypt: bool,
    pub is_valid: bool,
    pub user_ids: Vec<String>,
    pub email: Vec<String>,
}

#[rustler::nif]
fn key_info(key: String, home_dir: String, path: String) -> Result<PublicKeyInfo, Error> {
    let mut ctx = get_context(home_dir, path)?;
    match Data::from_bytes(key) {
        Ok(mut data_mem) => {
            let mut d = ctx.read_keys(&mut data_mem).unwrap();
            for k in d.by_ref().filter_map(|x| x.ok()) {
                return Ok(PublicKeyInfo {
                    id: k.id().unwrap_or("").to_string(),
                    fingerprint: k.fingerprint().unwrap_or("invalid").to_string(),
                    can_encrypt: k.can_encrypt(),
                    is_valid: !k.is_invalid(),
                    user_ids: k
                        .user_ids()
                        .enumerate()
                        .map(|(_, uid)| uid.id().unwrap_or("invalid").to_string())
                        .collect(),
                    email: k
                        .user_ids()
                        .map(|uid| uid.email().unwrap_or("invalid").to_string())
                        .collect(),
                });
            }
            return Err(Error::Term(Box::new("no valid key found".to_string())));
        }
        Err(reason) => Err(Error::Term(Box::new(reason.to_string()))),
    }
}

rustler::init!(
    "Elixir.GPG.Rust.NIF",
    [
        check_version,
        check_openpgp_supported,
        engine_info,
        encrypt,
        decrypt,
        import_key,
        public_key,
        key_info
    ]
);
