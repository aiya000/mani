Mani.new(window_manager: :xmonad) do
  workspace 1 do
    window :top, launch: 'urxvt' do
      run 'top'
    end

    window :date, launch: 'urxvt' do
      run 'date'
    end
  end

  workspace 2 do
    window :firefox, launch: 'firefox', delay: 1.5 do
      # Type "F6" first so that the cursor is in the address bar before typing
      # the url.
      visit '{{F6}}gmail.com'
    end
  end

  workspace 3 do
    # Use "-f" to prevent vim from forking and detaching from the original
    # process.
    window :gvim, launch: 'gvim -f', delay: 2 do
      type 'GoHello, world.'
    end
  end

  workspace 4 do
    window :thunderbird, launch: 'thunderbird'

    window :hipchat, launch: 'hipchat', delay: 3
  end

  workspace 8 do
    window :chromium, launch: 'chromium', delay: 1.5 do
      visit 'localhost:8080'

      browser_tab :new do
        visit 'news.ycombinator.com'
      end

      # Switch back to the first tab (localhost)
      browser_tab 1
    end
  end
end
