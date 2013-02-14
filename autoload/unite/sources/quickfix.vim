scriptencoding utf-8

function! unite#sources#quickfix#define()
	return s:source
endfunction


function! unite#sources#quickfix#word_formatter(val)
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
\	  = a:val.type == "e" ? "|error "
\	  : a:val.type == "w" ? "|warning "
\	  : "|"
	return fname."|".line.error."|".(error == "|" ? text : "|B>".text. "<B|")
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
\	"syntax" : "uniteSource__QuickFix",
\	"hooks" : {},
\	"converters" : "converter_quickfix_default"
\}

function! s:qflist_to_unite(val)
	let bufnr = a:val.bufnr
	let fname = bufnr == 0 ? "" : bufname(bufnr)
	let line  = bufnr == 0 ? 0 : a:val.lnum

	let word = g:Unite_quickfix_word_formatter(a:val)
	let yank_text = g:Unite_quickfix_word_formatter == g:Unite_quickfix_yank_text_formatter
\			 ? word
\			 : g:Unite_quickfix_yank_text_formatter(a:val)

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
\		"action__quickfix_val" : a:val,
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


function! s:hl_candidates()
	syntax match uniteSource__QuickFix_Bold  /|B>.*<B|/
\		contained containedin=uniteSource__QuickFix
\		contains
\			= uniteSource__QuickFix_BoldHiddenBegin
\			, uniteSource__QuickFix_BoldHiddenEnd

	highlight uniteSource__QuickFix_Bold term=bold gui=bold

	syntax match uniteSource__QuickFix_BoldHiddenBegin '|B>' contained conceal
	syntax match uniteSource__QuickFix_BoldHiddenEnd   '<B|' contained conceal

	syntax match uniteSource__QuickFix_Red /|R>.*<R|/
\		contained containedin=uniteSource__QuickFix
\		contains
\			= uniteSource__QuickFix_RedHiddenBegin
\			, uniteSource__QuickFix_RedHiddenEnd

	highlight uniteSource__QuickFix_Red ctermfg=1 guifg=Red

	syntax match uniteSource__QuickFix_RedhiddenBegin '|R>' contained conceal
	syntax match uniteSource__QuickFix_RedHiddenEnd   '<R|' contained conceal

	syntax match uniteSource__QuickFix_Purple /|P>.*<P|/
\		contained containedin=uniteSource__QuickFix
\		contains
\			= uniteSource__QuickFix_PurpleHiddenBegin
\			, uniteSource__QuickFix_PurpleHiddenEnd

	highlight uniteSource__QuickFix_Purple ctermfg=1 guifg=Purple

	syntax match uniteSource__QuickFix_PurplehiddenBegin '|P>' contained conceal
	syntax match uniteSource__QuickFix_PurpleHiddenEnd   '<P|' contained conceal

	syntax match uniteSource__QuickFix_File /[^|]\+|\d*|/
\		contained containedin=uniteSource__QuickFix
\		contains
\			= uniteSource__QuickFix_LineNr

	highlight default link uniteSource__QuickFix_File Directory


	syntax match uniteSource__QuickFix_LineNr /|\d\+|/hs=s+1,he=e-1
\		contained containedin=uniteSource__QuickFix

	highlight default link uniteSource__QuickFix_LineNr LineNr

endfunction

function! s:source.hooks.on_syntax(args, context)
	call s:hl_candidates()
endfunction
