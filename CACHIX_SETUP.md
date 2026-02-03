# Plan: Cachix + GitHub Actions CI for nixos-config

## Goal
Set up automated builds on GitHub Actions that push to Cachix, so future local rebuilds pull from your personal cache instead of building from source.

## Configuration
- **System**: aarch64-darwin only (Apple Silicon)
- **Trigger**: Push to main branch only
- **Runner**: `macos-14` (GitHub's M1 runner)

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Push to main   │ ──▶ │ GitHub Actions  │ ──▶ │    Cachix       │
│                 │     │ (macos-14 M1)   │     │  (your cache)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  Local rebuild  │
                                               │  pulls binaries │
                                               └─────────────────┘
```

---

## Step 1: Create Cachix Account (Manual)

1. Go to https://app.cachix.org and sign up (GitHub OAuth works)
2. Create a new binary cache:
   - Click "Create Cache"
   - Name it (e.g., `bassim-nixos` or your GitHub username)
   - Choose "Public" (free tier, unlimited storage for public caches)
3. Get your cache's public key:
   - Go to cache settings → "Public Key"
   - Copy it (format: `<name>.cachix.org-1:<base64-key>`)
4. Generate auth token:
   - Go to https://app.cachix.org/personal-auth-tokens
   - Create token with "Write" permission
   - Copy the token

## Step 2: Add GitHub Secret

1. Go to your repo: https://github.com/AVGVSTVS96/nixos-config/settings/secrets/actions
2. Click "New repository secret"
3. Name: `CACHIX_AUTH_TOKEN`
4. Value: paste the token from Step 1

---

## Step 3: Create GitHub Actions Workflow

**File**: `.github/workflows/build.yml`

```yaml
name: Build and Cache

on:
  push:
    branches: [main]
  workflow_dispatch:  # Allow manual trigger

jobs:
  build-darwin:
    name: Build aarch64-darwin
    runs-on: macos-14
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@main

      - name: Setup Magic Nix Cache
        uses: DeterminateSystems/magic-nix-cache-action@main

      - name: Setup Cachix
        uses: cachix/cachix-action@v15
        with:
          name: <CACHE_NAME>  # Replace with your cache name
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'

      - name: Build Darwin Configuration
        run: |
          nix build .#darwinConfigurations.aarch64-darwin.system \
            --accept-flake-config \
            --no-link \
            --print-build-logs
```

---

## Step 4: Update Local Cache Config

**File**: `modules/shared/cachix/default.nix`

```nix
{ pkgs, lib, ... }:
{
  nix.settings = {
    extra-substituters = [
      "https://<CACHE_NAME>.cachix.org"  # Your personal cache (first priority)
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
      "https://yaxitech.cachix.org"
    ];
    extra-trusted-public-keys = [
      "<CACHE_NAME>.cachix.org-1:<PUBLIC_KEY>"  # From Cachix dashboard
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "yaxitech.cachix.org-1:PFNhlI60xbzG/d/c+N0mbcro3J8z1Rvm2+t1aU/4Kko="
    ];
  };
}
```

---

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `.github/workflows/build.yml` | Create | GitHub Actions workflow |
| `modules/shared/cachix/default.nix` | Modify | Add your Cachix cache |

---

## Verification

1. **After Cachix setup**: Run `cachix use <CACHE_NAME>` locally to verify auth works
2. **After first CI run**: Check GitHub Actions tab for green build
3. **After workflow completes**: Check https://app.cachix.org for uploaded paths
4. **Test locally**:
   ```bash
   # Clear local build and test cache hit
   nix store delete /nix/store/...-darwin-system-...  # (specific path)
   nix build .#darwinConfigurations.aarch64-darwin.system --print-build-logs
   # Should show "copying from https://<CACHE_NAME>.cachix.org"
   ```

---

## Notes

- **Free tier**: Cachix public caches have unlimited storage
- **CI minutes**: GitHub gives 2,000 free minutes/month for macos runners
- **First CI build**: Will be slow (building from scratch), subsequent pushes are fast
- **Secrets**: ragenix secrets won't decrypt in CI (no private keys), but the build will still complete - just won't include decrypted secrets in the output

---

## Placeholders to Replace

After creating your Cachix account, replace these in the files:
- `<CACHE_NAME>` → Your cache name (e.g., `bassim-nixos`)
- `<PUBLIC_KEY>` → Your cache's public key from Cachix dashboard
