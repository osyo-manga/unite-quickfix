scriptencoding utf-8

function! unite#sources#quickfix#define()
	return s:source
endfunction


function! s:unite_quickfix_word_formatter(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? "" : a:val.lnum
	let text  = a:val.text
	let fname_short = g:unite_quickfix_filename_is_pathshorten ? pathshorten(fname) : fname
	let error = a:val.type == "e" ? "|error ":""
	return fname_short."|".line.error."| ".text
endfunction

function! s:unite_quickfix_abbr_formatter(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? "" : a:val.lnum
	let text  = a:val.text
	let fname_short = g:unite_quickfix_filename_is_pathshorten ? pathshorten(fname) : fname
	let error = a:val.type == "e" ? "|error ":""
	return fname_short."|".line.error."| ".text
endfunction


let g:unite_quickfix_filename_is_pathshorten =
	\ get(g:, "unite_quickfix_filename_is_pathshorten", 1)

let g:unite_quickfix_is_multiline =
	\ get(g:, "unite_quickfix_is_multiline", 1)

let g:Unite_quickfix_word_formatter =
	\ get(g:, "Unite_quickfix_word_formatter", function("s:unite_quickfix_word_formatter"))

let g:Unite_quickfix_abbr_formatter =
	\ get(g:, "Unite_quickfix_abbr_formatter", function("s:unite_quickfix_abbr_formatter"))


let s:source = {
\	"name" : "quickfix",
\	"description" : "output quickfix",
\}

function! s:qflist_to_unite(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? 0 : a:val.lnum

	let word = g:Unite_quickfix_word_formatter(a:val)
	let abbr = g:Unite_quickfix_word_formatter == g:Unite_quickfix_abbr_formatter
\			 ? word
\			 : g:Unite_quickfix_abbr_formatter(a:val)

	return {
	\ "word": word,
	\ "abbr": abbr,
	\ "source": "quickfix",
	\ "kind": "jump_list",
	\ "action__path": fname,
	\ "action__line": line,
	\ "action__pattern": a:val.pattern,
	\ "is_multiline" : g:unite_quickfix_is_multiline,
	\ }
endfunction

function! s:source.gather_candidates(args, context)
	return map(getqflist(), "s:qflist_to_unite(v:val)")
endfunction

