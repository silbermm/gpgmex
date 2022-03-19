# GPGMEx - Native Elixir bindings for GnuPG
# Copyright (C) 2021  Matt Silbernagel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
defmodule GPG.NIF do
  @moduledoc false

  use Zig,
    libs: ["/usr/lib/libgpgme.so"],
    include: ["/usr/include"],
    link_libc: true

  ~Z"""
  const c = @cImport({
      @cInclude("gpgme.h");
      @cInclude("locale.h");
      @cDefine("SIZE", "4092");
  });

  /// nif: check_version/0
  fn check_version(env: beam.env) beam.term {
      var y = c.gpgme_check_version(null);
      return beam.make_cstring_charlist(env, y);
  }

  /// nif: check_openpgp_supported/0
  fn check_openpgp_supported(env: beam.env) bool {
      var err = c.gpgme_engine_check_version(c.gpgme_protocol_t.GPGME_PROTOCOL_OpenPGP);
      if (err != c.GPG_ERR_NO_ERROR) {
          return false;
      }
      return true;
  }

  /// resource: engine_info_struct definition
  const engine_info_struct = struct {
      filename: [*c]u8,
      homedir: [*c]u8,
  };

  /// resource: context_struct definition
  const context_struct = struct { context: c.gpgme_ctx_t };

  /// nif: engine_info/0
  fn engine_info(env: beam.env) beam.term {
      var enginfo: c.gpgme_engine_info_t = undefined;
      const err = c.gpgme_get_engine_info(&enginfo);

      if (err != c.GPG_ERR_NO_ERROR) {
          return 9888;
      }

      var resource_filename = beam.allocator.alloc(u8, 64) catch return beam.raise_enomem(env);
      errdefer beam.allocator.free(resource_filename);

      var resource_homedir = beam.allocator.alloc(u8, 64) catch return beam.raise_enomem(env);
      errdefer beam.allocator.free(resource_homedir);

      return __resource__.create(engine_info_struct, env, .{
          .filename = enginfo.*.file_name,
          .homedir = enginfo.*.home_dir,
      }) catch return beam.raise_resource_error(env);
  }

  /// nif: get_filename/1
  fn get_filename(env: beam.env, res: beam.term) beam.term {
      var result = __resource__.fetch(engine_info_struct, env, res) catch return beam.raise_resource_error(env);
      return beam.make_cstring_charlist(env, result.filename);
  }

  /// nif: get_homedir/1
  fn get_homedir(env: beam.env, res: beam.term) beam.term {
      var result = __resource__.fetch(engine_info_struct, env, res) catch return beam.raise_resource_error(env);
      return beam.make_cstring_charlist(env, result.homedir);
  }

  /// nif: create_context/0
  fn create_context(env: beam.env) beam.term {
      var ceofcontext: c.gpgme_ctx_t = undefined;
      var err = c.gpgme_new(&ceofcontext);

      if (err != c.GPG_ERR_NO_ERROR) {
          std.log.err("ERROR {}", .{err});
          return beam.raise_resource_error(env);
      }

      err = c.gpgme_set_protocol(ceofcontext, c.gpgme_protocol_t.GPGME_PROTOCOL_OpenPGP);
      if (err != c.GPG_ERR_NO_ERROR) {
          return beam.raise_resource_error(env);
      }

      // set engine info in our context
      err = c.gpgme_ctx_set_engine_info(ceofcontext, c.gpgme_protocol_t.GPGME_PROTOCOL_OpenPGP, "/usr/bin/gpg2", "~/.gnupg/");
      if (err != c.GPG_ERR_NO_ERROR) {
          std.log.err("ERROR {}", .{err});
          return beam.raise_resource_error(env);
      }

      _ = c.gpgme_set_armor(ceofcontext, 1);

      var resource_context = beam.allocator.alloc(c.gpgme_engine_info_t, 64) catch return beam.raise_enomem(env);
      errdefer beam.allocator.free(resource_context);

      return __resource__.create(context_struct, env, .{ .context = ceofcontext }) catch return beam.raise_resource_error(env);
  }

  /// Encrypt data
  /// nif: encrypt/3
  fn encrypt(env: beam.env, res: beam.term, email: []u8, text: []u8) beam.term {
      var context = __resource__.fetch(context_struct, env, res) catch return beam.raise_resource_error(env);

      var key: c.gpgme_key_t = undefined;
      var err = c.gpgme_op_keylist_start(context.context, email.ptr, 0);
      while (err == c.GPG_ERR_NO_ERROR) {
          err = c.gpgme_op_keylist_next(context.context, &key);
          if (err != c.GPG_ERR_NO_ERROR) {
              break;
          }

          var cipher: c.gpgme_data_t = undefined;
          err = c.gpgme_data_new(&cipher);
          var to_encrypt: c.gpgme_data_t = undefined;

          err = c.gpgme_data_new_from_mem(&to_encrypt, text.ptr, text.len, 0);
          var keys = [_]c.gpgme_key_t{ key, null };

          err = c.gpgme_op_encrypt(context.context, &keys, c.gpgme_encrypt_flags_t.GPGME_ENCRYPT_ALWAYS_TRUST, to_encrypt, cipher);
          if (err != c.GPG_ERR_NO_ERROR) break;

          //_ = c.gpgme_op_encrypt_result(context.context);

          // READ THE ENCRYPTED DATA
          var d: [c.SIZE]u8 = undefined;
          var read_bytes = c.gpgme_data_seek(cipher, 0, c.SEEK_SET);
          var read_new_bytes_2 = c.gpgme_data_read(cipher, &d, c.SIZE);
          while (read_new_bytes_2 > 0) {
              read_new_bytes_2 = c.gpgme_data_read(cipher, &d, c.SIZE);
          }

          // RELEASE THE POINTERS
          c.gpgme_data_release(to_encrypt);
          c.gpgme_data_release(cipher);
          c.gpgme_key_release(key);
          const buf_slice = d[0..];
          return beam.make_cstring_charlist(env, buf_slice);
      }
      return beam.raise_resource_error(env);
  }

  /// Decrypt data
  /// nif: decrypt/2
  fn decrypt(env: beam.env, res: beam.term, data: []u8) beam.term {
      var context = __resource__.fetch(context_struct, env, res) catch return beam.raise_resource_error(env);

      var cipher: c.gpgme_data_t = undefined;
      var err = c.gpgme_data_new_from_mem(&cipher, data.ptr, data.len, 0);

      var decrypted: c.gpgme_data_t = undefined;
      err = c.gpgme_data_new(&decrypted);
      if (err != c.GPG_ERR_NO_ERROR) {
          std.log.err("unable to build data obj {}", .{err});
          return beam.raise_resource_error(env);
      }

      err = c.gpgme_op_decrypt(context.context, cipher, decrypted);
      if (err != c.GPG_ERR_NO_ERROR) {
          std.log.err("unable to decrpyt {}", .{err});
          return beam.raise_resource_error(env);
      }

      // READ THE ENCRYPTED DATA
      var d: [c.SIZE]u8 = undefined;
      var read_bytes = c.gpgme_data_seek(decrypted, 0, c.SEEK_SET);
      var read_new_bytes_2 = c.gpgme_data_read(decrypted, &d, c.SIZE);
      while (read_new_bytes_2 > 0) {
          read_new_bytes_2 = c.gpgme_data_read(decrypted, &d, c.SIZE);
      }

      // RELEASE THE POINTERS
      c.gpgme_data_release(decrypted);
      c.gpgme_data_release(cipher);
      const buf_slice = d[0..];
      return beam.make_cstring_charlist(env, buf_slice);
  }

  /// Get the public key for a particular email
  /// nif: public_key/2
  fn public_key(env: beam.env, res: beam.term, email: beam.term) beam.term {
      var context = __resource__.fetch(context_struct, env, res) catch return beam.raise_resource_error(env);

      var data: c.gpgme_data_t = undefined;
      var err = c.gpgme_data_new(&data);

      if (err != c.GPG_ERR_NO_ERROR) {
          return beam.raise_resource_error(env);
      }

      err = c.gpgme_data_set_encoding(data, c.gpgme_data_encoding_t.GPGME_DATA_ENCODING_ARMOR);
      if (err != c.GPG_ERR_NO_ERROR) {
          return beam.raise_resource_error(env);
      }

      // EXPORT AND GET PUBLIC KEY
      err = c.gpgme_op_export(context.context, email, 0, data);
      if (err != c.GPG_ERR_NO_ERROR) {
          return beam.raise_resource_error(env);
      }

      var read_bytes = c.gpgme_data_seek(data, 0, c.SEEK_END);
      if (read_bytes == -1) {
          std.log.err("data-seek-err: {}", .{12});
          return beam.raise_resource_error(env);
      }

      read_bytes = c.gpgme_data_seek(data, 0, c.SEEK_SET);

      if (read_bytes == -1) {
          return beam.raise_resource_error(env);
      }

      read_bytes = c.gpgme_data_seek(data, 0, c.SEEK_SET);

      var buf: [c.SIZE]u8 = undefined;
      var read_new_bytes = c.gpgme_data_read(data, &buf, c.SIZE);
      while (read_new_bytes > 0) {
          read_new_bytes = c.gpgme_data_read(data, &buf, c.SIZE);
      }
      const buf_slice = buf[0..];

      // RELEASE THE POINTERS
      c.gpgme_data_release(data);

      return beam.make_cstring_charlist(env, buf_slice);
  }

  /// nif: generate_key/2
  fn generate_key(env: beam.env, res: beam.term, email: []u8) c_ulong {
      var context = __resource__.fetch(context_struct, env, res) catch return beam.raise_resource_error(env);

      var err = c.gpgme_op_createkey(context.context, email.ptr, null, 0, 0, null, c.GPGME_CREATE_CERT & c.GPGME_CREATE_NOEXPIRE & c.GPGME_CREATE_ENCR);
      if (err != c.GPG_ERR_NO_ERROR) {
          if (err == c.GPG_ERR_NOT_SUPPORTED) {
              return beam.make_error_term(env, 190);
          }
          std.log.err("ERROR {}", .{err});
          return beam.raise_resource_error(env);
      }
      return 0;
  }
  """
end
