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
        version = "1.20241022.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-64/-/workerd-linux-64-1.20241022.0.tgz";
          sha512 = "1hf3686vh6rd75rjsz03jdi3vv59jaycjpvpv4ncsxm6aacqf45b3n93q3rd84pw15xvvmyj70p4vvqhcxrxq79fxr6y92hs3bmrhs6";
        };
      };
      linuxWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-linux-arm64";
        packageName = "@cloudflare/workerd-linux-arm64";
        # Should be same version as workerd
        version = "1.20241022.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-arm64/-/workerd-linux-arm64-1.20241022.0.tgz";
          sha512 = "1lchvp1lr7329avil9gww0wycbi611kzm58pxrpx4kq9jxql3nrmng7i32xawy38qapd36ynggyr8ka8fp74rn1qlnclzmij9g996f7";
        };
      };
      darwinWorkerd = {
        name = "_at_cloudflare_slash_workerd-darwin-64";
        packageName = "@cloudflare/workerd-darwin-64";
        # Should be same version as workerd
        version = "1.20241022.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-64/-/workerd-darwin-64-1.20241022.0.tgz";
          sha512 = "2rwagdkm7h4481ky0nzfxrm3kwlyvajvr963g12f54vazmy733g8pl5gpfdl6rxj3lm8rcai6bimhyi140ks8i5h09j76zvgnx5ilyl"
        };
      };
      darwinWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-darwin-arm64";
        packageName = "@cloudflare/workerd-darwin-arm64";
        # Should be same version as workerd
        version = "1.20241022.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-arm64/-/workerd-darwin-arm64-1.20241022.0.tgz";
          sha512 = "2zqljnd1nclxnhwyshz768l3i98fixivn9ap9l2wc7mh7brhklalf1vbnd4mjxkqi20i7irx5abh3w3apiw3pdl9hn63wqlzp8bzqql";
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