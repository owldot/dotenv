-- GH open prs
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "p", function()
  hs.alert.show("Open my PRs")
  hs.urlevent.openURL("https://github.com/shop/world/pulls?q=is%3Apr+author%3Alanadz+")
end)

-- TTS

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function run(cmd, input, onComplete)
  local task = hs.task.new("/bin/zsh", function(exitCode, stdout, stderr)
    print("tts exit:", exitCode)

    if stdout and stdout ~= "" then
      print("stdout:", stdout)
    end

    if stderr and stderr ~= "" then
      print("stderr:", stderr)
    end

    if exitCode ~= 0 then
      hs.alert.show("TTS failed, check Hammerspoon console and ~/tts/tts.log")
    end

    if onComplete then
      onComplete(exitCode, stdout, stderr)
    end
  end, {"-lc", cmd})

  if input then
    task:setInput(input)
  end

  if not task:start() then
    hs.alert.show("Could not start TTS")
    return
  end

  -- Send EOF so the script's `cat` finishes reading stdin.
  if input then
    task:closeInput()
  end
end

local ttsModifiers = {"ctrl", "alt", "cmd", "shift"}

local function adjustPlaybackRate(option)
  run(string.format([[
    export PATH="$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    "$HOME/bin/tts" %s
  ]], option), nil, function(exitCode, stdout)
    if exitCode == 0 then
      hs.alert.show(trim(stdout or "Playback rate updated"))
    end
  end)
end

hs.hotkey.bind(ttsModifiers, "Z", function()
  local old = hs.pasteboard.getContents()

  hs.pasteboard.setContents("")
  hs.eventtap.keyStroke({"cmd"}, "c")

  hs.timer.doAfter(0.2, function()
    local selected = hs.pasteboard.getContents()

    if old then
      hs.pasteboard.setContents(old)
    end

    if not selected or selected == "" then
      hs.notify.new({title="TTS", informativeText="No selected text found."}):send()
      return
    end

    hs.notify.new({title="TTS", informativeText="Generating speech…"}):send()

    run([[
      export PATH="$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
      "$HOME/bin/tts"
    ]], selected)
  end)
end)

hs.hotkey.bind(ttsModifiers, "X", function()
  run([[
    export PATH="$HOME/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    "$HOME/bin/tts" --stop
  ]])
end)

hs.hotkey.bind(ttsModifiers, "-", function()
  adjustPlaybackRate("--rate-down")
end)

-- Shift is already a modifier, so the physical + key is named "=" here.
hs.hotkey.bind(ttsModifiers, "=", function()
  adjustPlaybackRate("--rate-up")
end)

-- Keep Kokoro resident so the shortcut avoids model-load latency.
run([[
  export PATH="$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
  "$HOME/bin/tts" --warm
]])
