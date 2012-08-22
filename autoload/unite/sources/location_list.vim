scriptencoding utf-8

function! unite#sources#location_list#define()
	return s:source
endfunction


function! s:unite_location_list_word_formatter(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? "" : a:val.lnum
	let text  = a:val.text
	let fname_short = g:unite_location_list_filename_is_pathshorten ? pathshorten(fname) : fname
	let error = a:val.type == "e" ? "|error ":""
	return fname_short."|".line.error."| ".text
endfunction

function! s:unite_location_list_abbr_formatter(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? "" : a:val.lnum
	let text  = a:val.text
	let fname_short = g:unite_location_list_filename_is_pathshorten ? pathshorten(fname) : fname
	let error = a:val.type == "e" ? "|error ":""
	return fname_short."|".line.error."| ".text
endfunction


let g:unite_location_list_filename_is_pathshorten =
	\ get(g:, "unite_location_list_filename_is_pathshorten", 1)

let g:unite_location_list_is_multiline =
	\ get(g:, "unite_location_list_is_multiline", 1)

let g:Unite_location_list_word_formatter =
	\ get(g:, "Unite_location_list_word_formatter", function("s:unite_location_list_word_formatter"))

let g:Unite_location_list_abbr_formatter =
	\ get(g:, "Unite_location_list_abbr_formatter", function("s:unite_location_list_abbr_formatter"))


let s:source = {
\	"name" : "location_list",
\	"description" : "output location_list",
\}

function! s:location_list_to_unite(val)
	let fname = a:val.bufnr == 0 ? "" : bufname(a:val.bufnr)
	let line  = fname == "" ? 0 : a:val.lnum

	let word = g:Unite_location_list_word_formatter(a:val)
	let abbr = g:Unite_location_list_word_formatter == g:Unite_location_list_abbr_formatter
\			 ? word
\			 : g:Unite_location_list_abbr_formatter(a:val)

	return {
	\ "word": word,
	\ "abbr": abbr,
	\ "source": "location_list",
	\ "kind": "jump_list",
	\ "action__path": fname,
	\ "action__line": line,
	\ "action__pattern": a:val.pattern,
	\ "is_multiline" : g:unite_location_list_is_multiline,
	\ }
endfunction

function! s:source.gather_candidates(args, context)
	echom "homu"
	let unite = get(b:, "unite", {})
	let winnr = get(unite, "prev_winnr", winnr())
	echom winnr
	return map(getloclist(winnr), "s:location_list_to_unite(v:val)")
endfunction


