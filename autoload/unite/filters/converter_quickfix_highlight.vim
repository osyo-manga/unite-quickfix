scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#converter_quickfix_highlight#define()
	return s:converter
endfunction


let g:unite#filters#converter_quickfix_highlight#enable_bold_for_message = get(g:, "unite#filters#converter_quickfix_highlight#enable_bold_for_message", 1)


let s:converter = {
\	"name" : "converter_quickfix_highlight",
\	"description" : "unite-quickfix highlight converter"
\}



function! s:to_message(fname, line, col, error, text)
	return unite#filters#converter_quickfix_default#to_message(a:fname, a:line, a:col, a:error, a:text)
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
\	  = a:val.type ==? "e" ? ">E|error|E<"
\	  : a:val.type ==? "w" ? ">W|warning|W<"
\	  : ""
	if g:unite#filters#converter_quickfix_highlight#enable_bold_for_message
		let text = (text == "" || text[0] ==# " " ? text[1:] : text)
		return s:to_message(fname, line, a:val.col, error, error == "" ? text : "|B>". text . "<B|")
	else
		return s:to_message(fname, line, a:val.col, error, text)
	endif
endfunction


function! s:converter.filter(candidates, context)
	for candidate in a:candidates
		let abbr = s:convert(candidate.action__quickfix_val, g:unite_quickfix_filename_is_pathshorten)
		let candidate.abbr = abbr
		let candidate.word = s:convert(candidate.action__quickfix_val, 0)
		let candidate.is_multiline = g:unite_quickfix_is_multiline
		let candidate.action__text = candidate.action__quickfix_val.text
	endfor
	return a:candidates
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
