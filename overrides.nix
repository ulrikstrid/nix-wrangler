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
        version = "1.20240314.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-64/-/workerd-linux-64-1.20240314.0.tgz";
          sha512 = "0iwdf07h5s843ml6b1zfys5bkbckhg9v3s5pnrddmvanal6lp6vw6amn9n71nk6qb6m92m32lhayh870yqxqvbkj6a666551xv1vxnl";
        };
      };
      linuxWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-linux-arm64";
        packageName = "@cloudflare/workerd-linux-arm64";
        # Should be same version as workerd
        version = "1.20240314.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-linux-arm64/-/workerd-linux-arm64-1.20240314.0.tgz";
          sha512 = "1aqmyv6cxxjz0b2vav4w35qw20dgd40r5s052vg9fi3wyhish0wdshxngin35qnlpfcy4cgkfn90srz0yd85hygn39hwqfawhxv530q";
        };
      };
      darwinWorkerd = {
        name = "_at_cloudflare_slash_workerd-darwin-64";
        packageName = "@cloudflare/workerd-darwin-64";
        # Should be same version as workerd
        version = "1.20240314.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-64/-/workerd-darwin-64-1.20240314.0.tgz";
          sha512 = "1x3sns6043zvmlc34d6zdzvwizlwf81spyvjwhcdqvabszvykr937zh8b3ladxvl0zxcsda8wkw3i1wa6pc2lnnlykk34i6h3mmdp6p";
        };
      };
      darwinWorkerdArm = {
        name = "_at_cloudflare_slash_workerd-darwin-arm64";
        packageName = "@cloudflare/workerd-darwin-arm64";
        # Should be same version as workerd
        version = "1.20240314.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@cloudflare/workerd-darwin-arm64/-/workerd-darwin-arm64-1.20240314.0.tgz";
          sha512 = "2v2zl5cdw0w2hs6fjamzm5a5dg06np5s1jafvb4zras2dw63am6kg0ki25q9fc616c1kvybrskqpyqwrlncq4cnwyhd9506gl7zrbl2";
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