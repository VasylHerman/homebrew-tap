class BreakReminder < Formula
  desc "Menu bar app that counts work and rest time and reminds you to take a break"
  homepage "https://github.com/VasylHerman/break-reminder"
  url "https://github.com/VasylHerman/break-reminder/archive/refs/tags/v0.21.2.tar.gz"
  sha256 "05160cd77b52a478556f44b0344069881fecf71577e75ae3a6b6e0881b1f50ac"
  license "MIT"
  head "https://github.com/VasylHerman/break-reminder.git", branch: "main"

  bottle do
    root_url "https://github.com/VasylHerman/homebrew-tap/releases/download/break-reminder-0.21.2"
    sha256                               arm64_sequoia: "74a4a5924d527127d8fc4c4cc5e79f59c38a4706cad5a716b2348f8c33498bd7"
    sha256                               arm64_sonoma:  "009b8a74539ff5b4d57cb3e0bab40daa7760fb5dad23bc3aac33527683f670af"
    sha256 cellar: :any_skip_relocation, sequoia:       "c73c99369b3e08dece02a0dc47abf69e517085b5b85c417060b5f31640b5d895"
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
