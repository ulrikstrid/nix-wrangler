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

  wrangler = prev.wrangler.override (oldAttrs:
    let
      linuxWorkerd = {
        name = "_at_cloudflare_slash_workerd-linux-64";
        packageName = "@cloudflare/workerd-linux-64";
        # Should be same version as workerd
        version = "1.20240404.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-64/-/workerd-linux-64-1.20240404.0.tgz";
          sha512 = "2lzg38hm32rxns18qq20ii7bzp7pzmspmwvdrqkibv8glhfhgyy3nzvb8rh32ljxs4wjh8dl8z9d163x1f1iwlnfyccnpxnl6mvplwx";
        };
      };
      linuxWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-linux-arm64";
        packageName = "@cloudflare/workerd-linux-arm64";
        # Should be same version as workerd
        version = "1.20240404.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-arm64/-/workerd-linux-arm64-1.20240404.0.tgz";
          sha512 = "1fwcbzdiz7qynx7krzciwqnwd8cc17dhqyjwvf6wf6k092kgxx3r3ma43brciz5q0978ia1m70h6f2g70grxw8vv5pa25lq6ak3knl6";
        };
      };
      darwinWorkerd = {
        name = "_at_cloudflare_slash_workerd-darwin-64";
        packageName = "@cloudflare/workerd-darwin-64";
        # Should be same version as workerd
        version = "1.20240404.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-64/-/workerd-darwin-64-1.20240404.0.tgz";
          sha512 = "0ijr04xqh7d1p1zba7vja20dp2s12psg1z357n9qd67g14w2i2d15annmx98kf4mhqk27qgj6hwhx2v9ll929ym8q50h6rxfazyikxd";
        };
      };
      darwinWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-darwin-arm64";
        packageName = "@cloudflare/workerd-darwin-arm64";
        # Should be same version as workerd
        version = "1.20240404.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-arm64/-/workerd-darwin-arm64-1.20240404.0.tgz";
          sha512 = "2s1xjbfa24ss7f2pa4sfl3rcpavyx6j80kj4b1wl9jm7v2x1hgpvgnn49ax1z0ykq3zbibkzgnd7j3fnsrqs9q6l1180gdnw26hznjp";
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