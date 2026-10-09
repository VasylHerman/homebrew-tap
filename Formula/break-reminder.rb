class BreakReminder < Formula
  desc "Menu bar app that counts work and rest time and reminds you to take a break"
  homepage "https://github.com/VasylHerman/break-reminder"
  url "https://github.com/VasylHerman/break-reminder/archive/refs/tags/v0.22.1.tar.gz"
  sha256 "912a02a5d50ad451370d9a9e1c2b5b61be4d59792c6953dafbfff29358f0a158"
  license "MIT"
  head "https://github.com/VasylHerman/break-reminder.git", branch: "main"

  bottle do
    root_url "https://github.com/VasylHerman/homebrew-tap/releases/download/break-reminder-0.22.1"
    sha256                               arm64_sequoia: "d9a235b31a7ef6e226802335e9ba2c9981931c1abfd2c925b754adcf2f7344b2"
    sha256                               arm64_sonoma:  "ddf2f01e0981dd5a666a02b929e484ea27b51fd048a6d3bd20aa4261686c1a26"
    sha256 cellar: :any_skip_relocation, sequoia:       "efec59ac36dd1139679e917449e74ac4c538693552d1b86b5d94682e577c51cd"
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
