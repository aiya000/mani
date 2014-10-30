# Mani

**Mani** is a window automation tool. Common tasks (such as launching programs,
visiting websites, and typing text) can be scripted using a simple Ruby DSL.

While [xmonad](http://xmonad.org/) is currently the only supported window
manager, Mani can support any window manager for the X Window System with just
a few lines of code. Please open an
[issue](https://github.com/NSinopoli/mani/issues) to add support for your
favorite window manager.

## Demo

[![Mani Demo](/demo.png?raw=true "Mani Demo")](https://vimeo.com/110445089)

## Installation

```bash
gem install mani
```

### xmonad

You'll have to do a few things to get Mani to work as expected under xmonad.

1. Install [xdotool](http://www.semicomplete.com/projects/xdotool/).
2. Add [XMonad.Hooks.EwmhDesktops](http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Hooks-EwmhDesktops.html)
   to your xmonad configuration, and then restart xmonad.

```haskell
import XMonad.Hooks.EwmhDesktops

main = xmonad $ ewmh defaultConfig{ handleEventHook =
           handleEventHook defaultConfig <+> fullscreenEventHook }
```

## Getting Started

Here's a simple example:

```ruby
# hello.rb
Mani.new(window_manager: :xmonad) do
  window :hello, launch: 'urxvt' do
    run 'echo "Hello, world."'
  end
end
```

Run it:

```bash
$ mani hello.rb
```

Provided you have
[rxvt-unicode](http://software.schmorp.de/pkg/rxvt-unicode.html) installed, a
new terminal will open and the command `echo "Hello, world."` will run inside
it.

## Examples

Check out the [examples](examples) directory for more examples.

## DSL Overview

`Mani.new` should be at the beginning of every script. It takes an options
hash, which can take the following keys:

* `:window_manager` - the window manager (currently only `:xmonad` is supported)
* `:switch_to_workspace` - an optional proc which, when called, returns a
  sequence which, when interpreted, will switch to the specified workspace
  (defaults to the default sequence used by the `:window_manager` to change
  workspaces)

```ruby
switcher = ->(space) { "super+#{space}" }
Mani.new(window_manager: :xmonad, switch_to_workspace: switcher) do
  # Switch to workspace 1
  workspace 1

  # Switch to workspace 2
  workspace 2
end
```

`workspace` switches to the specified workspace. If a block is supplied, it
will be called.

```ruby
Mani.new(window_manager: :xmonad) do
  # Switch to workspace 1, launch a terminal and run 'echo "Hello, world."'
  workspace 1 do
    window :hello, launch: 'urxvt' do
      run 'echo "Hello, world."'
    end
  end

  # Switch to workspace 2
  workspace 2
end
```

`window` serves as the container for window commands. Its first argument is the
window name. Its second (optional) argument is an options hash, which can take
the following keys:

* `:launch` - the program to be launched
* `:delay` - the amount of time, in seconds, to delay after launching the
  program (defaults to 0.5)

If a block is supplied, it will be called.

```ruby
Mani.new(window_manager: :xmonad) do
  # Create a new terminal window, wait one second, and then run 'ls'
  window :ls do
    launch 'urxvt', delay: 1 do
      run 'ls'
    end
  end

  # The same process can be accomplished using this condensed syntax:
  window :ls, launch: 'urxvt', delay: 1 do
    run 'ls'
  end

  # Just launch a program
  window :thunderbird, launch: 'thunderbird'

  # Return to the :ls window, and then run 'date'
  window :ls do
    run 'date'
  end
end
```

`launch` launches a program. It takes an optional options hash, which can take
the following keys:

* `:delay` - the amount of time, in seconds, to delay after launching the
  program (defaults to 0.5)

```ruby
Mani.new(window_manager: :xmonad) do
  # Create a new terminal window, wait one second, and then run 'ls'
  window :ls do
    launch 'urxvt', delay: 1 do
      run 'ls'
    end
  end
end
```

`run` executes a [combination](#combination-syntax) within a window. It takes
an optional options hash, which can take the following keys:

* `:delay` - the amount of time, in seconds, to delay after running the
  command (defaults to 0.5)

```ruby
Mani.new(window_manager: :xmonad) do
  # Run 'ls'
  window :ls, launch: 'urxvt', delay: 1 do
    run 'ls'
  end
end
```

`type` types a [combination](#combination-syntax) within a window. It takes an
optional options hash, which can take the following keys:

* `:delay` - the amount of time, in seconds, to delay after typing the text
  (defaults to 0.5)

```ruby
Mani.new(window_manager: :xmonad) do
  # Launch gvim
  window :gvim, launch: 'gvim -f', delay: 2 do
    # Wait two seconds, then move to the end of the buffer, start a new line,
    # and type "Hello, world."
    type 'GoHello, world.'
  end
end
```

`visit` is used to visit a website. It takes an optional options hash, which
can take the following keys:

* `:delay` - the amount of time, in seconds, to delay after entering the url
  (defaults to 0.5)

Note that depending on the browser, you may need to insert an "F6"
[keystroke](#combination-syntax) at the beginning of the url.

```ruby
Mani.new(window_manager: :xmonad) do
  window :chromium, launch: 'chromium', delay: 1.5 do
    visit 'localhost:8080'
  end

  window :firefox, launch: 'firefox', delay: 1.5 do
    # Type "F6" first so that the cursor is in the address bar before typing
    # the url.
    visit '{{F6}}gmail.com'
  end
end
```

`browser_tab` is used to either create a new browser tab or switch to a
specific tab. Its first argument, when `:new`, will create a new tab. If it is
an integer, the browser will instead switch to that tab. Its second argument
is an optional options hash, which can take the following keys:

* `:delay` - the amount of time, in seconds, to delay after handling the tab
  (defaults to 0.5)

If a block is supplied, it will be called.

```ruby
Mani.new(window_manager: :xmonad) do
  window :chromium, launch: 'chromium', delay: 1.5 do
    # Visit 'localhost:8080' within the initial tab
    visit 'localhost:8080'

    # Create a new tab and visit 'news.ycombinator.com'
    browser_tab :new do
      visit 'news.ycombinator.com'
    end

    # Switch back to the first tab (localhost:8080)
    browser_tab 1
  end
end
```

### Combination Syntax

Simulating keystrokes for function keys and modifiers requires the use of a
special syntax. The `{{` and `}}` tags are used to indicate a sequence.
Chording is achieved by separating keys with a `+` sign.

```ruby
Mani.new(window_manager: :xmonad) do
  window :firefox, launch: 'firefox', delay: 1.5 do
    # Type "F6" first so that the cursor is in the address bar before typing
    # the url.
    visit '{{F6}}gmail.com'

    # Paste the contents of the clipboard into the url.
    visit 'localhost:8080/reports/{{ctrl+v}}/preview'
  end
end
```

In the event a literal `{{` or `}}` is desired, a `%` sign can be added as a
prefix to escape the sequence.

```ruby
Mani.new(window_manager: :xmonad) do
  window :hello, launch: 'urxvt' do
    run 'echo "%{{literal opening brackets"'
    run 'echo "literal closing brackets%}}"'
    run 'echo "%{{literal opening and closing brackets%}}"'
  end
end
```

## Contributing

Please follow the guidelines below.

### Issue Reporting

* Use the [issue tracker](https://github.com/NSinopoli/mani/issues) to report
  any issues or ideas for improvements.
* Check that the issue has not already been reported.
* Check that the issue has not already been fixed in the latest code (i.e., on
  `master`).
* Be clear, concise, and precise in your description of the problem.
* Open an issue with a descriptive title and a summary in grammatically
  correct, complete sentences.
* Include any relevant code to the issue summary.

### Pull Requests

* Read [how to properly contribute to open source projects on Github](http://gun.io/blog/how-to-github-fork-branch-and-pull-request).
* Fork the project.
* Use a topic/feature branch to easily amend a pull request later, if
  necessary.
* Write [good commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
* Use the same [coding conventions](#code-conventions) as the rest of the
  project.
* Commit and push until you are happy with your contribution.
* Make sure to add [tests](#tests) for it. This is important so I don't break
  it in a future version unintentionally.
* Please try not to mess with the version or history. If you want to have your
  own version, please isolate the change to its own commit so I can cherry-pick
  around it.
* [Squash related commits together](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html).
* Open a [pull request](https://help.github.com/articles/using-pull-requests)
  that relates to *only* one subject with a clear title and description in
  grammatically correct, complete sentences.

### Code Conventions

**Mani** follows the conventions laid out in the
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide). These
conventions are enforced by [RuboCop](https://github.com/bbatsov/rubocop).

```
make install
make style
```

Please ensure that any contributed code does not produce any RuboCop offenses.

### Tests

```
make test
```
