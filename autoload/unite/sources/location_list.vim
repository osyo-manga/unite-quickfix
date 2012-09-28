scriptencoding utf-8

function! unite#sources#location_list#define()
	return s:source
endfunction


let g:unite_location_list_filename_is_pathshorten =
	\ get(g:, "unite_location_list_filename_is_pathshorten", 1)

let g:unite_location_list_is_multiline =
	\ get(g:, "unite_location_list_is_multiline", 1)

let g:Unite_location_list_word_formatter =
	\ get(g:, "Unite_location_list_word_formatter", function("unite#sources#quickfix#word_formatter"))

let g:Unite_location_list_yank_text_formatter =
	\ get(g:, "Unite_location_list_yank_text_formatter", function("unite#sources#quickfix#yank_text_formatter"))


let s:source = {
\	"name" : "location_list",
\	"description" : "output location_list",
\}

function! s:location_list_to_unite(val)
	let bufnr = a:val.bufnr
	let fname = bufnr == 0 ? "" : bufname(bufnr)
	let line  = bufnr == 0 ? 0 : a:val.lnum

	let word = g:Unite_location_list_word_formatter(a:val)
	let yank_text = g:Unite_location_list_word_formatter == g:Unite_location_list_yank_text_formatter
\			 ? word
\			 : g:Unite_location_list_yank_text_formatter(a:val)

	return {
\		"word": word,
\		"source": "quickfix",
\		"kind": "jump_list",
\		"action__buffer_nr" : bufnr,
\		"action__path" : fname,
\		"action__line" : line,
\		"action__pattern" : a:val.pattern,
\		"action__text" : yank_text,
\		"is_multiline" : g:unite_quickfix_is_multiline,
\		}

endfunction

function! s:source.gather_candidates(args, context)
	let unite = get(b:, "unite", {})
	let winnr = get(unite, "prev_winnr", winnr())

	let lolder = empty(a:args) ? 0 : a:args[0]
	if lolder == 0
		return map(getloclist(winnr), "s:location_list_to_unite(v:val)")
	else
		try
			execute "lolder" lolder
			return map(getloclist(winnr), "s:location_list_to_unite(v:val)")
		finally
			execute "lnewer" lolder
		endtry
	endif
endfunction


