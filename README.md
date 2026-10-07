# homebrew-tap

Homebrew formulae for my macOS tools.

```sh
brew tap vasylherman/tap
brew install break-reminder
```

Bottles (prebuilt binaries) are published by the Bottle workflow for Apple Silicon on recent macOS,
so `brew install` normally downloads instead of compiling. Other configurations build from source
and need current Command Line Tools: if you see "Your Command Line Tools are too outdated", run
`softwareupdate --all --install --force` or reinstall them with `xcode-select --install`.

| Formula | Description |
| --- | --- |
| `break-reminder` | Menu bar app that counts work and rest time and reminds you to take a break. Built from source. |
