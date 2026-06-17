# assets

## sysyphus.gif → milli.nvim splash

`sysyphus.gif` is the source for the animated mini.starter splash (milli.nvim).
milli renders **frames generated from the gif**, not the gif itself, so the gif
must be converted to a Lua frames module once. This needs the milli CLI, which
must be installed manually (Claude's sandbox blocks global npm installs of
third-party packages — a supply-chain guard).

### One-time setup

```sh
npm install -g @amansingh-afk/milli
cd ~/.config/nvim
milli export assets/sysyphus.gif /tmp/sysyphus-out -t lua -w 60 --no-bg
cp /tmp/sysyphus-out/frames.lua lua/milli/splashes/sysyphus.lua
```

Restart nvim. `lua/config/plugins.lua` auto-detects the `sysyphus` splash: if
`lua/milli/splashes/sysyphus.lua` loads, it becomes the animated starter header;
otherwise the config falls back to the `AESV` ASCII banner. No config edit needed.

Tune `-w` (width in columns) and try `--no-bg` on/off to taste. `milli list` /
`:MilliPreview <name>` previews the bundled splashes (fire, blackhole, spinner, …).
