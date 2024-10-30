#!/usr/bin/env sh

# Update nixpkgs
nix flake update

INITIAL_WORKERD_VERSION=$(grep "workerd-" ./generated/node-packages.nix | awk -e'{ print gensub(/.*([0-9]\.[0-9]+\.[0-9]).*/, "\\1", "g", $1);}' | head -n 1)

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

sed -i "24s%.*%          url = \"$LINUX_X86_URL\";%" overrides.nix
sed -i "25s%.*%          sha512 = \"$LINUX_X86_SHA\";%" overrides.nix

sed -i "34s%.*%          url = \"$LINUX_ARM_URL\";%" overrides.nix
sed -i "35s%.*%          sha512 = \"$LINUX_ARM_SHA\";%" overrides.nix

sed -i "44s%.*%          url = \"$DARWIN_X86_URL\";%" overrides.nix
sed -i "45s%.*%          sha512 = \"$DARWIN_X86_SHA\"%;" overrides.nix

sed -i "54s%.*%          url = \"$DARWIN_ARM_URL\";%" overrides.nix
sed -i "55s%.*%          sha512 = \"$DARWIN_ARM_SHA\";%" overrides.nix

git add .
git commit -m "workerd: $INITIAL_WORKERD_VERSION -> $WORKERD_VERSION"
git push

echo "Done"
