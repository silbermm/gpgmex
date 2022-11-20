# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [Unreleased]

## [0.0.8]
### Fixed
  - Added `native` path to the hex package so that it compiles correctly

## [0.0.7]
### Updated
  - Refactor NIF to use Rustler with the [gpgme crate](https://docs.rs/gpgme/latest/gpgme/index.html)
  - the GPG.get_public_key/1 function now just returns the fingerprint of the public key in the system

### Added
  - key_info function that
    - returns the data (fingerprint, uid, email) about a text key passed into the function

## [0.0.6]
### Updated
  - Fixed some tests
  - Fixed a regression in the ecrypt function

## [0.0.5]
### DEPRECATED

## [0.0.4]

## [0.0.3]
### Updated
  - support for configuring gpg_bin path and gpg_home directory 

## [0.0.2]
### Added
  - import_key/1
    - imports a public key
  - documentation updates

## [0.0.1]
### Added
  - Initial release with very basic functionality
    - Create a GPG key
    - Delete a GPG key
    - Encrypt
    - Decrypt

[Unreleased]: https://github.com/silbermm/gpgmex/compare/v0.0.8...HEAD
[0.0.8]: https://github.com/silbermm/gpgmex/releases/tag/v0.0.8
[0.0.7]: https://github.com/silbermm/gpgmex/releases/tag/v0.0.7
[0.0.1]: https://github.com/silbermm/gpgmex/releases/tag/v0.0.1
