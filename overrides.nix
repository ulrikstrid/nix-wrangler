{ pkgs, nodejs }:

let
  inherit (pkgs)
    stdenv
    lib
    fetchurl;

  since = version: lib.versionAtLeast nodejs.version version;
  before = version: lib.versionOlder nodejs.version version;
in

final: prev: {
  inherit nodejs;

  wrangler = prev."wrangler-3.59".override (oldAttrs:
    let
      linuxWorkerd = {
        name = "_at_cloudflare_slash_workerd-linux-64";
        packageName = "@cloudflare/workerd-linux-64";
        # Should be same version as workerd
        version = "1.20240524.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-64/-/workerd-linux-64-1.20240524.0.tgz";
          sha512 = "24ihcg5dml12ajaqcjrp0fhk6npv3hmw6zpbwkr9w3fryjk114qp29kaqcjfwdvcl0zaapl48l67may6g33c8lhd2q25by1fgwa7j8k";
        };
      };
      linuxWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-linux-arm64";
        packageName = "@cloudflare/workerd-linux-arm64";
        # Should be same version as workerd
        version = "1.20240524.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-arm64/-/workerd-linux-arm64-1.20240524.0.tgz";
          sha512 = "2mq32hjigh56d04158pyvhccam2r2qgshy080p5pik8gd83nqj46cigii3f57pxcykrnzflfs16gp2aklahi0yhi1mnpdzmmrdzanpw";
        };
      };
      darwinWorkerd = {
        name = "_at_cloudflare_slash_workerd-darwin-64";
        packageName = "@cloudflare/workerd-darwin-64";
        # Should be same version as workerd
        version = "1.20240524.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-64/-/workerd-darwin-64-1.20240524.0.tgz";
          sha512 = "0ipvj8187icmm7v244dyc6dyx9lk2plfca8yy63c012xa36m60najad17zgjbz3rd57wwfp212phpbbdrby0rvawbpwlknvwy6rfdh1";
        };
      };
      darwinWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-darwin-arm64";
        packageName = "@cloudflare/workerd-darwin-arm64";
        # Should be same version as workerd
        version = "1.20240524.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-arm64/-/workerd-darwin-arm64-1.20240524.0.tgz";
          sha512 = "1f0x51j26nc7cjs6jgaxbf8fg8wgrbpkg5qc6abba6bxwqwsx8bg4fzpd6q8n1d9828whpn1zqbch73s08rrc6z147l8jq2irjfqxn2";
        };
      };

    in
    {
      meta = oldAttrs.meta // { broken = before "16.13"; };
      buildInputs = [ pkgs.llvmPackages.libcxx pkgs.llvmPackages.libunwind ] ++ lib.optional stdenv.isLinux pkgs.autoPatchelfHook;
      preFixup = ''
        # patch elf is trying to patch binary for sunos
        rm -r $out/lib/node_modules/wrangler/node_modules/@esbuild/sunos-x64
      '';
      dependencies = oldAttrs.dependencies
        ++ lib.optional (stdenv.isLinux && stdenv.isx86_64) linuxWorkerd
        ++ lib.optional (stdenv.isLinux && stdenv.isAarch64) linuxWorkerdArm
        ++ lib.optional (stdenv.isDarwin && stdenv.isx86_64) darwinWorkerd
        ++ lib.optional (stdenv.isDarwin && stdenv.isAarch64) darwinWorkerdArm;
    });
}