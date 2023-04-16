files=($PWD/log/bkpp_filter.log
        $PWD/log/bkp_output.log)

body=$PWD/bb
for f in "${files[@]}"; do
    [[ -f "$f" ]] && attachments+=(-a "$f")
done

echo "$(cat $body)" | mailx -s "The files" "${attachments[@]}" naveenvk88@gmail.com
