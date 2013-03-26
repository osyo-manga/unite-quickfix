scriptencoding utf-8

function! unite#sources#location_list#define()
	return s:source
endfunction


let s:source = {
\	"name" : "location_list",
\	"description" : "output location_list",
\	"syntax" : "uniteSource__QuickFix",
\	"hooks" : {},
\	"converters" : "converter_quickfix_default",
\}


function! s:location_list_to_unite(val)
	let bufnr = a:val.bufnr
	let fname = bufnr == 0 ? "" : bufname(bufnr)
	let line  = bufnr == 0 ? 0 : a:val.lnum

	return {
\		"source": "location_list",
\		"kind": "jump_list",
\		"action__buffer_nr" : bufnr,
\		"action__path" : fname,
\		"action__line" : line,
\		"action__pattern" : a:val.pattern,
\		"action__quickfix_val" : a:val,
\		"action__quickfix_type" : "location_list",
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

function! s:source.hooks.on_syntax(args, context)
	call unite#sources#quickfix#hl_candidates()
endfunction

