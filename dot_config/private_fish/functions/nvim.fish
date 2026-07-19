    function nvim
        if test -f ./uv.lock
            echo "→ Detected uv.lock, running in uv environment"
            uv run --frozen nvim $argv
        else
            command nvim $argv
        end
    end

