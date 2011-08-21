function! CompleteMuttAliases(findstart, base)
    if a:findstart
        " locate the start of the word
        " we stop when we encounter space character
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        " find aliases matching with "a:base"
        let result = []
        for line_alias in readfile(expand('~/.mutt/aliases'))
            let words = split(line_alias, '\s')
            if words[0] == "alias" && len(words) >= 3
                if words[1] =~ '^' . a:base
                    " get the alias part
                    let alias = join(words[2:-1], ' ')
                    " mutt uses '\' to escape '"', we need to remove it!
                    alias = substitue(alias, '\\', '', 'g')
                    " add to the complete list
                    call add(result, alias)
                endif
            endif
        endfor
        return result
    endif
endfun
