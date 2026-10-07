class BreakReminder < Formula
  desc "Menu bar app that counts work and rest time and reminds you to take a break"
  homepage "https://github.com/VasylHerman/break-reminder"
  url "https://github.com/VasylHerman/break-reminder/archive/refs/tags/v0.13.0.tar.gz"
  sha256 "249c697e22806d27fd6b2219eb7cd3dfb44b092e0e6dce73b1ef03c6db9c0b7f"
  license "MIT"
  head "https://github.com/VasylHerman/break-reminder.git", branch: "main"

  depends_on macos: :ventura

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    app = prefix/"BreakReminder.app"
    (app/"Contents/MacOS").install ".build/release/BreakReminder"
    (app/"Contents").install "Support/Info.plist"
    system "codesign", "--force", "--sign", "-", app

    (bin/"break-reminder").write <<~SH
      #!/bin/sh
      exec open -a "#{opt_prefix}/BreakReminder.app" "$@"
    SH
  end

  service do
    run [opt_prefix/"BreakReminder.app/Contents/MacOS/BreakReminder"]
    keep_alive true
    process_type :interactive
    log_path var/"log/break-reminder.log"
    error_log_path var/"log/break-reminder.log"
  end

  def caveats
    <<~EOS
      Launch it with:
        break-reminder

      To start it at login, either enable "Launch at Login" in the app menu or run:
        brew services start break-reminder

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
