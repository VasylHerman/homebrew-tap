class BreakReminder < Formula
  desc "Menu bar app that counts work and rest time and reminds you to take a break"
  homepage "https://github.com/VasylHerman/break-reminder"
  url "https://github.com/VasylHerman/break-reminder/archive/refs/tags/v0.23.0.tar.gz"
  sha256 "1551b37314690f9f93beb5f979fdba928f5b05953dac25987ecb62fba3bd0ae6"
  license "MIT"
  head "https://github.com/VasylHerman/break-reminder.git", branch: "main"

  bottle do
    root_url "https://github.com/VasylHerman/homebrew-tap/releases/download/break-reminder-0.23.0"
    sha256                               arm64_sequoia: "6e852a29f419928054b9096a73a49657924e1823beb10e98f2f1c1a404afb61e"
    sha256                               arm64_sonoma:  "3a5058359c7ef7d4cb0210a8bb76c9decc4e41a9472233dc52516cac4d673578"
    sha256 cellar: :any_skip_relocation, sequoia:       "f62439bbe6b9af797a9430f73911c68d282acebbdaffcd7bf2fee7b6df84b4ce"
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
