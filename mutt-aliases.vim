function! FindMuttAliasesFile()
    let file = readfile(expand('~/.muttrc'))
    for line in file
        let words = split(line, '\s')
	let divw  = split(line, '=')
        if len(words) >= 3 && words[0] == "set" && len(divw) >= 2 && CleanWord(words[1]) == "alias_file"
            return Strip(divw[1])
        endif
    endfor
    return ""
endfunction

function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! CleanWord(word)
	return substitute(Strip(a:word), "=", "", "")
endfunction

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
        let file = FindMuttAliasesFile()

        if file == ""
            return result
        endif
        if file[0] == '"'
		let file = expand(file[1:-2])
	else
		let file = expand(file)
        endif
        for line_alias in readfile(file)
            let words = split(line_alias, '\s')
            if len(words) >= 3 && words[0] == "alias"  
                if words[1] =~ '^' . a:base
                    " get the alias part
                   " mutt uses '\' to escape '"', we need to remove it!
                    let alias = substitute(join(words[2:-1], ' '), '\\', '', 'g')
                    let dict = {}
                    let dict['word'] = alias
                    let dict['abbr'] = words[1]
                    let dict['menu'] = alias
                    " add to the complete list
                    call add(result, dict)
                endif
            endif
        endfor
        return result
    endif
endfunction

" we only enable this auto complete function when editting Mutt mails
autocmd BufRead,BufNewFile /tmp/mutt-* setlocal completefunc=CompleteMuttAliases
