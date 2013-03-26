scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#converter_quickfix_highlight#define()
	return s:converter
endfunction


let s:converter = {
\	"name" : "converter_quickfix_highlight",
\	"description" : "unite-quickfix highlight converter"
\}


function! s:convert(val)
	if a:val.bufnr && !empty(bufname(a:val.bufnr))
		if g:unite_quickfix_filename_is_pathshorten
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
	let line  = fname == "" ? "" : a:val.lnum
	let text  = a:val.text
	let error
\	  = a:val.type == "e" ? "||R>error <R|"
\	  : a:val.type == "w" ? "||P>warning <P|"
\	  : "|"
	return fname."|".line.error."|".(error == "|" ? text : "|B>".text. "<B|")
endfunction


function! s:converter.filter(candidates, context)
	for candidate in a:candidates
		let word = s:convert(candidate.action__quickfix_val)
		let candidate.word = word
		let candidate.action__text = word
		let candidate.is_multiline = g:unite_quickfix_is_multiline
	endfor
	return a:candidates
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
