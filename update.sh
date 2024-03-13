#!/usr/bin/env sh

# Update wrangler
nix run nixpkgs#node2nix -- -i node-packages.json -o ./node-packages.nix

# Move generated files into the generated folder
mv ./node-packages.nix ./generated/node-packages.nix
mv ./default.nix ./generated/default.nix
mv ./node-env.nix ./generated/node-env.nix

# Figure out workerd version and update overrides
WORKERD_VERSION=$(grep "workerd-" ./generated/node-packages.nix | awk -e'{ print gensub(/.*([0-9]\.[0-9]+\.[0-9]).*/, "\\1", "g", $1);}' | head -n 1)
sed -i -E "s/version = \".*\"/version = \"${WORKERD_VERSION}\"/" overrides.nix

# Define URLS
LINUX_X86_URL="https://registry.npmjs.org/@cloudflare/workerd-linux-64/-/workerd-linux-64-$WORKERD_VERSION.tgz"
LINUX_ARM_URL="https://registry.npmjs.org/@cloudflare/workerd-linux-arm64/-/workerd-linux-arm64-$WORKERD_VERSION.tgz"
DARWIN_X86_URL="https://registry.npmjs.org/@cloudflare/workerd-darwin-64/-/workerd-darwin-64-$WORKERD_VERSION.tgz"
DARWIN_ARM_URL="https://registry.npmjs.org/@cloudflare/workerd-darwin-arm64/-/workerd-darwin-arm64-$WORKERD_VERSION.tgz"

# Calculate sha512's
LINUX_X86_SHA=$(nix-prefetch-url --type sha512 "$LINUX_X86_URL")
LINUX_ARM_SHA=$(nix-prefetch-url --type sha512 "$LINUX_ARM_URL")
DARWIN_X86_SHA=$(nix-prefetch-url --type sha512 "$DARWIN_X86_URL")
DARWIN_ARM_SHA=$(nix-prefetch-url --type sha512 "$DARWIN_ARM_URL")

# TODO: Can we automate this part as well?
# Print manual steps
echo ""
echo ""
echo "Now you need to manually update the overrides.nix:"
echo ""

echo "linuxWorkerd"
printf "url = \"%s\"\nsha512 = \"%s\"\n\n" "$LINUX_X86_URL" "$LINUX_X86_SHA"

echo "linuxWorkerdArm"
printf "url = \"%s\"\nsha512 = \"%s\"\n\n" "$LINUX_ARM_URL" "$LINUX_ARM_SHA"

echo "darwinWorkerd"
printf "url = \"%s\"\nsha512 = \"%s\"\n\n" "$DARWIN_X86_URL" "$DARWIN_X86_SHA"

echo "darwinWorkerdArm"
printf "url = \"%s\"\nsha512 = \"%s\"\n\n" "$DARWIN_ARM_URL" "$DARWIN_ARM_SHA"
