scriptencoding utf-8

function! unite#sources#quickfix#define()
	return s:source
endfunction


function! unite#sources#quickfix#word_formatter(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? "" : a:val.lnum
	let text  = a:val.text
	let fname_short = g:unite_quickfix_filename_is_pathshorten ? pathshorten(fname) : fname
	let error = a:val.type == "e" ? "|error ":""
	return fname_short."|".line.error."| ".text
endfunction

function! unite#sources#quickfix#yank_text_formatter(val)
	return a:val.text
endfunction


let g:unite_quickfix_filename_is_pathshorten =
	\ get(g:, "unite_quickfix_filename_is_pathshorten", 1)

let g:unite_quickfix_is_multiline =
	\ get(g:, "unite_quickfix_is_multiline", 1)

let g:Unite_quickfix_word_formatter =
	\ get(g:, "Unite_quickfix_word_formatter", function("unite#sources#quickfix#word_formatter"))

let g:Unite_quickfix_yank_text_formatter =
	\ get(g:, "Unite_quickfix_yank_text_formatter", function("unite#sources#quickfix#yank_text_formatter"))


let s:source = {
\	"name" : "quickfix",
\	"description" : "output quickfix",
\}

function! s:qflist_to_unite(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? 0 : a:val.lnum

	let word = g:Unite_quickfix_word_formatter(a:val)
	let yank_text = g:Unite_quickfix_word_formatter == g:Unite_quickfix_yank_text_formatter
\			 ? word
\			 : g:Unite_quickfix_yank_text_formatter(a:val)

	return {
\		"word": word,
\		"source": "quickfix",
\		"kind": "jump_list",
\		"action__path" : fname,
\		"action__line" : line,
\		"action__pattern" : a:val.pattern,
\		"action__text" : yank_text,
\		"is_multiline" : g:unite_quickfix_is_multiline,
\		}
endfunction

function! s:source.gather_candidates(args, context)
	let qfolder = empty(a:args) ? 0 : a:args[0]
	if qfolder == 0
		return map(getqflist(), "s:qflist_to_unite(v:val)")
	else
		try
			execute "colder" qfolder
			return map(getqflist(), "s:qflist_to_unite(v:val)")
		finally
			execute "cnewer" qfolder
		endtry
	endif
endfunction

