defmodule GPG do
  @moduledoc """
  GNU Privacy Guard bindings
  """

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
    const context_struct = struct {
      context: c.gpgme_ctx_t
    };

    /// nif: engine_info/0
    fn engine_info(env: beam.env) beam.term {
      var enginfo: c.gpgme_engine_info_t = undefined;
      const err = c.gpgme_get_engine_info(&enginfo);

      if (err != c.GPG_ERR_NO_ERROR) {
          return 9888;
      }

      var resource_filename = beam.allocator.alloc(u8, 64)
        catch return beam.raise_enomem(env);
      errdefer beam.allocator.free(resource_filename);

      var resource_homedir = beam.allocator.alloc(u8, 64)
         catch return beam.raise_enomem(env);
      errdefer beam.allocator.free(resource_homedir);


      return __resource__.create(engine_info_struct, env, .{
          .filename = enginfo.*.file_name,
          .homedir = enginfo.*.home_dir,
      }) catch return beam.raise_resource_error(env);
    }

    /// nif: get_filename/1
    fn get_filename(env: beam.env, res: beam.term) beam.term {
      var result = __resource__.fetch(engine_info_struct, env, res)
          catch return beam.raise_resource_error(env);
      return beam.make_cstring_charlist(env, result.filename);
    }

    /// nif: get_homedir/1
    fn get_homedir(env: beam.env, res: beam.term) beam.term {
      var result = __resource__.fetch(engine_info_struct, env, res)
          catch return beam.raise_resource_error(env);
      return beam.make_cstring_charlist(env, result.homedir);
    }

    /// nif: create_context/0
    fn create_context(env: beam.env) beam.term {
      var ceofcontext: c.gpgme_ctx_t = undefined;
      var err = c.gpgme_new(&ceofcontext);

      if (err != c.GPG_ERR_NO_ERROR) {
        return beam.raise_resource_error(env);
      }

      err = c.gpgme_set_protocol(ceofcontext, c.gpgme_protocol_t.GPGME_PROTOCOL_OpenPGP);
      
      if (err != c.GPG_ERR_NO_ERROR) {
        return beam.raise_resource_error(env);
      }

      // set engine info in our context
      err = c.gpgme_ctx_set_engine_info(ceofcontext, c.gpgme_protocol_t.GPGME_PROTOCOL_OpenPGP, "/usr/bin/gpg2", "/home/silbermm/.gnupg/");
      if (err != c.GPG_ERR_NO_ERROR) {
        std.log.err("ERROR {}", .{err});
        return beam.raise_resource_error(env);
      }

      _ = c.gpgme_set_armor(ceofcontext, 1);

      var resource_context = beam.allocator.alloc(c.gpgme_engine_info_t, 64)
        catch return beam.raise_enomem(env);
      errdefer beam.allocator.free(resource_context);
      
      return __resource__.create(context_struct, env, .{
          .context = ceofcontext
      }) catch return beam.raise_resource_error(env);
    }

    /// nif: encrypt/3
    fn encrypt(env: beam.env, res: beam.term, email: beam.term, text: []u8) beam.term {
      var context = __resource__.fetch(context_struct, env, res)
          catch return beam.raise_resource_error(env);

      var key: c.gpgme_key_t = undefined;
      var err = c.gpgme_op_keylist_start(context.context, email, 0);
      while (err == c.GPG_ERR_NO_ERROR) {
          err = c.gpgme_op_keylist_next(context.context, &key);
          if (err != c.GPG_ERR_NO_ERROR) break;

          //var data = "this is a test of data to encrypt";

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

    /// nif: decrypt/2
    fn decrypt(env: beam.env, res: beam.term, data: []u8) beam.term {
      var context = __resource__.fetch(context_struct, env, res)
          catch return beam.raise_resource_error(env);

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

    /// nif: public_key/2
    fn public_key(env: beam.env, res: beam.term, email: beam.term) beam.term {

      var context = __resource__.fetch(context_struct, env, res)
          catch return beam.raise_resource_error(env);

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
      return beam.make_cstring_charlist(env, buf_slice);
    }
  """

  def get_engine_version do
    version = GPG.check_version()
    to_string(version)
  end

  @spec get_engine_info() :: map()
  def get_engine_info() do
    ref = GPG.engine_info()
    filename = GPG.get_filename(ref)
    %{filename: to_string(filename)}
  end

  def context() do
    # must check_version before creating a context
    # TODO: what if check_version fails?
    _version = GPG.check_version()
    create_context()
  end

  @spec get_public_key(reference(), binary()) :: binary()
  def get_public_key(ctx, email) do
    ctx
    |> public_key(email)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  end

  def encrypt_for(ctx, email, data) do
    ctx
    |> encrypt(email, data)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  end

  @doc ""
  def decrypt_data(ctx, data) do
    ctx
    |> decrypt(data)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  end
end
