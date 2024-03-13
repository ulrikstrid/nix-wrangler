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
        version = "1.20240304.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-64/-/workerd-linux-64-1.20240304.0.tgz";
          sha512 = "12sb1dvyr570isrrpnqc0hpdp18q66hmapli5q9hwh6j3fzjfvycbzpxbib38a17857xf6z5ss1x4p3fn8xnf7p68g54k1xpk6l8l0v";
        };
      };
      linuxWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-linux-arm64";
        packageName = "@cloudflare/workerd-linux-arm64";
        # Should be same version as workerd
        version = "1.20240304.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-arm64/-/workerd-linux-arm64-1.20240304.0.tgz";
          sha512 = "3rqwdmq4ifjfy0krx11dvb1l6a2fwcv6mgzcwph912n2vcfcbwlmmlvxivg71nfnqs2i5gnazf06rr3ahidr1h3x5p39vdvzivkzf9c";
        };
      };
      darwinWorkerd = {
        name = "_at_cloudflare_slash_workerd-darwin-64";
        packageName = "@cloudflare/workerd-darwin-64";
        # Should be same version as workerd
        version = "1.20240304.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-64/-/workerd-darwin-64-1.20240304.0.tgz";
          sha512 = "16zp5mdadjs792rgliffn48x5509gs7sfh2sx23dd5wywj3mbjfbr1s614696963i80rxy1ihfmiw0k1s0dgrnv802a34mkqnzfbwdd";
        };
      };
      darwinWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-darwin-arm64";
        packageName = "@cloudflare/workerd-darwin-arm64";
        # Should be same version as workerd
        version = "1.20240304.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-arm64/-/workerd-darwin-arm64-1.20240304.0.tgz";
          sha512 = "0vixmlbwv2bcag1spr92zk52pd5kry5ysgx2xfaip9z7az069pkk37hx60rchm1ybspg1g13nzw6lr3x25fh61p0cgicx8ggg28ww91";
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