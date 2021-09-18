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
    fn get_filename(env: beam.env, res: beam.term) beam.term {
      var result = __resource__.fetch(engine_info_struct, env, res)
          catch return beam.raise_resource_error(env);
      return beam.make_cstring_charlist(env, result.filename);
    }


  """

  @doc """
  """
  def gpg_engine_version do
    version = GPG.check_version()
    to_string(version)
    IO.puts(version)
  end
end
