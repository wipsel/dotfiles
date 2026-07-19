function rename
    set from $argv[1]
    set to $argv[2]
    for file in $argv[3..-1]
        perl -i -p -e "s{$from}{$to}g;" $file
        echo "Changing $from to $to in $file"
    end
end
