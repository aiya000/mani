Mani.new(window_manager: :xmonad) do
  window :urxvt, launch: 'urxvt' do
    # Copy the most recent report id
    run %q(
      ssh 127.0.0.1 -p 49154
        psql -h localhost -U web_dev web_development <<<
        'SELECT id FROM reports order by id desc limit 1;'
      | grep -m 1 \[0-9\] | xclip -selection c
    ).strip.gsub(/\s+/, ' ')
    run 'exit'
  end

  window :chrome, launch: 'google-chrome-stable', delay: 1 do
    # Paste the report id within the url
    visit 'localhost:8080/reports/{{ctrl+v}}/preview'
  end
end
