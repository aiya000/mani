Mani.new(window_manager: :xmonad) do
  window :hello, launch: 'urxvt' do
    run 'echo "Hello, world."'
  end
end
