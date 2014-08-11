scriptencoding utf-8


function! unite#sources#quickfix#define()
	return s:source
endfunction


let s:source = {
\	"name" : "quickfix",
\	"description" : "output quickfix",
\	"syntax" : "uniteSource__QuickFix",
\	"hooks" : {},
\	"converters" : "converter_quickfix_default"
\}

function! s:qflist_to_unite(val)
	let bufnr = a:val.bufnr
	let fname = bufnr == 0 ? "" : bufname(bufnr)
	let line  = bufnr == 0 ? 0 : a:val.lnum

	return extend({
\		"source": "quickfix",
\		"kind": "jump_list",
\		"action__line" : line,
\		"action__pattern" : a:val.pattern,
\		"action__quickfix_val" : a:val,
\		"action__quickfix_type" : "quickfix",
\		},
\		(!filereadable(fname) ? { "action__buffer_nr" : bufnr } : { "action__path" : fname }),
\		)
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


function! unite#sources#quickfix#color_tag_syntax(name, first, last)
" 	syntax match uniteSource__QuickFix_Bold  /|B>.*<B|/
" \		contained containedin=uniteSource__QuickFix
" \		contains
" \			= uniteSource__QuickFix_BoldHiddenBegin
" \			, uniteSource__QuickFix_BoldHiddenEnd

" 	syntax match uniteSource__QuickFix_BoldHiddenBegin '|B>' contained conceal
" 	syntax match uniteSource__QuickFix_BoldHiddenEnd   '<B|' contained conceal

	let begin = "uniteSource__QuickFix_".a:name."HiddenBegin"
	let end   = "uniteSource__QuickFix_".a:name."HiddenEnd"
	let pattern = a:first.'.*'.a:last

	execute "syntax match uniteSource__QuickFix_".a:name." /".pattern."/ "
\		. "contained containedin=uniteSource__QuickFix "
\		. "contains=" . begin .",". end

	execute "syntax match ".begin." '".a:first."'  contained conceal"
	execute "syntax match ".end  ." '".a:last ."'  contained conceal"
endfunction


function! unite#sources#quickfix#hl_candidates()
	call unite#sources#quickfix#color_tag_syntax("Bold", "|B>", "<B|")
	highlight uniteSource__QuickFix_Bold term=bold gui=bold

	call unite#sources#quickfix#color_tag_syntax("Red", "|R>", "<R|")
	highlight uniteSource__QuickFix_Red ctermfg=1 guifg=Red

	call unite#sources#quickfix#color_tag_syntax("Purple", "|P>", "<P|")
	highlight uniteSource__QuickFix_Purple ctermfg=1 guifg=Purple


	syntax match uniteSource__QuickFix_PurplehiddenBegin '|P>' contained conceal
	syntax match uniteSource__QuickFix_PurpleHiddenEnd   '<P|' contained conceal

	syntax match uniteSource__QuickFix_File /[^|]\+|\d*[| ]/
\		contained containedin=uniteSource__QuickFix
\		contains
\			= uniteSource__QuickFix_LineNr

	highlight default link uniteSource__QuickFix_File Directory

	syntax match uniteSource__QuickFix_LineNr /|\d\+ col \d\+[| ]\||\d\+[| ]/hs=s+1,he=e-1
\		contained containedin=uniteSource__QuickFix

	highlight default link uniteSource__QuickFix_LineNr LineNr
endfunction


function! s:source.hooks.on_syntax(args, context)
	call unite#sources#quickfix#hl_candidates()
	let self.source__old_concealcursor = &l:concealcursor
	setlocal concealcursor=incv
endfunction


function! s:source.hooks.on_close(args, context)
	if &l:concealcursor == "incv"
		let &l:concealcursor = self.source__old_concealcursor
	endif
endfunction




