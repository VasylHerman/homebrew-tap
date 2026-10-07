class BreakReminder < Formula
  desc "Menu bar app that counts work and rest time and reminds you to take a break"
  homepage "https://github.com/VasylHerman/break-reminder"
  url "https://github.com/VasylHerman/break-reminder/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "4e491c938e3e1614559e3e739cd9501b4f4fdb677829b4576933d8aa5b0a4ae4"
  license "MIT"
  head "https://github.com/VasylHerman/break-reminder.git", branch: "main"

  bottle do
    root_url "https://github.com/VasylHerman/homebrew-tap/releases/download/break-reminder-0.20.0"
    sha256                               arm64_sequoia: "ffc764230a0e6c4a6e86e4d40b3904037e2ab766a38d5a7b2ccc72dbf86db602"
    sha256                               arm64_sonoma:  "74ca7e05b9eaca696119e08a23d4feb340b7a705159cda4ce02d5edc8eebdec3"
    sha256 cellar: :any_skip_relocation, sequoia:       "af66d7702bf2153faf521cb8e1b2daa54618167ccd6a5e24ff1b9d8e8ecd5822"
  end

  depends_on macos: :ventura

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    app = prefix/"BreakReminder.app"
    (app/"Contents/MacOS").install ".build/release/BreakReminder"
    (app/"Contents").install "Support/Info.plist"
    (app/"Contents/Resources").install "Support/Assets.car", "Support/AppIcon.icns"
    system "codesign", "--force", "--sign", "-", app

    (bin/"break-reminder").write <<~SH
      #!/bin/sh
      exec open -a "#{opt_prefix}/BreakReminder.app" "$@"
    SH
  end

  service do
    run [opt_prefix/"BreakReminder.app/Contents/MacOS/BreakReminder"]
    keep_alive successful_exit: false
    process_type :interactive
    log_path var/"log/break-reminder.log"
    error_log_path var/"log/break-reminder.log"
  end

  def caveats
    <<~EOS
      If the install failed with "Your Command Line Tools are too outdated", update them:
        softwareupdate --all --install --force
      or reinstall: sudo rm -rf /Library/Developer/CommandLineTools && xcode-select --install

      Launch it with:
        break-reminder

      To start it at login and restart it after a crash, run it as a service:
        brew services start break-reminder
      Or enable "Launch at login" in the app's settings (no crash restart).

      To show it in /Applications:
        ln -sf #{opt_prefix}/BreakReminder.app /Applications/BreakReminder.app
    EOS
  end

  test do
    assert_predicate prefix/"BreakReminder.app/Contents/MacOS/BreakReminder", :executable?
    plist = prefix/"BreakReminder.app/Contents/Info.plist"
    assert_match "BreakReminder", shell_output("defaults read #{plist} CFBundleName")
  end
end
