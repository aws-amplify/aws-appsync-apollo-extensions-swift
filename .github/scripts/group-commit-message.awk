#!/usr/bin/awk -f

function add_to_group(key, value) {
    groups[key] = groups[key] "- " value "\n"
}

{
    if (NF > 0) {  # Skip empty lines
        if (tolower($1) == "feat:") {
            add_to_group("Features:", substr($0, index($0, $2)))
        } else if (tolower($1) == "fix:") {
            add_to_group("Fixes:", substr($0, index($0, $2)))
        } else {
            next
        }
    }
}

END {
    for (group in groups) {
        print "\n### " group
        print groups[group]
    }
    print "\n"
}
