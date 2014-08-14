scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let g:unite_quickfix_filename_is_pathshorten =
	\ get(g:, "unite_quickfix_filename_is_pathshorten", 1)


let g:unite_quickfix_is_multiline =
	\ get(g:, "unite_quickfix_is_multiline", 1)


function! unite#filters#converter_quickfix_default#define()
	return s:converter
endfunction


let s:converter = {
\	"name" : "converter_quickfix_default",
\	"description" : "unite-quickfix default converter"
\}


function! unite#filters#converter_quickfix_default#to_message(fname, line, col, error, text)
	let pos = join(filter([
\			  a:line > 0 ? a:line : ""
\			, a:col > 0  ? "col " . a:col : ""
\			, a:error
\	], "len(v:val)"), " ")
	return a:fname . "|" . pos . "|" . (a:text == "" || a:text[0] ==# " " ? "" : " ") . a:text
endfunction


function! s:convert(val, is_pathshorten)
	if a:val.bufnr && !empty(bufname(a:val.bufnr))
		if a:is_pathshorten
			let fname = pathshorten(bufname(a:val.bufnr))
		else
			let fname = bufname(a:val.bufnr)
		endif
	else
		if a:val.bufnr
			let fname = "bufnr[".a:val.bufnr."]"
		else
			let fname = ""
		endif
	endif
	let line  = a:val.lnum
	let text  = substitute(a:val.text, '\s*\n\s*', ' ', "g")
	
	let error
\	  = a:val.type ==? "e" ? "error"
\	  : a:val.type ==? "w" ? "warning"
\	  : ""
	return unite#filters#converter_quickfix_default#to_message(fname, line, a:val.col, error, text)
" 	return fname . "|" . line . error . "|" . text
endfunction


function! s:converter.filter(candidates, context)
	for candidate in a:candidates
		let abbr = s:convert(candidate.action__quickfix_val, g:unite_quickfix_filename_is_pathshorten)
		let candidate.abbr = abbr
		let candidate.action__text = candidate.action__quickfix_val.text
		let candidate.word = s:convert(candidate.action__quickfix_val, 0)
		let candidate.is_multiline = g:unite_quickfix_is_multiline
	endfor
	return a:candidates
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
