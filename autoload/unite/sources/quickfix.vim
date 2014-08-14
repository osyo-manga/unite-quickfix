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
\		"kind": ["common", "jump_list"],
\		"action__line" : line,
\		"action__pattern" : a:val.pattern,
\		"action__quickfix_val" : a:val,
\		"action__quickfix_type" : "quickfix",
\		},
\		(!filereadable(fname) ? { "action__buffer_nr" : bufnr } : { "action__path" : fname }),
\		)
endfunction


function! unite#sources#quickfix#get_quickfix_title(...)
	let tabnr = tabpagenr()
	let is_location_list = get(a:, 1, 0)
	let result = ""
	try
		noautocmd tabnew
		execute "noautocmd" is_location_list ? "lopen" : "copen"
		silent! let result = w:quickfix_title
	finally
		execute "noautocmd" is_location_list ? "lclose" : "cclose"
		noautocmd bdelete
		execute "tabnext" tabnr
	endtry
	return result
endfunction


function! s:source.gather_candidates(args, context)
	call unite#print_source_message(strtrans(unite#sources#quickfix#get_quickfix_title()), "quickfix")
	
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


function! s:default_highlight()
	if !hlexists("UniteQuickFixError")
		highlight UniteQuickFixError ctermfg=1 guifg=Red term=bold gui=bold
	endif
	if !hlexists("UniteQuickFixWarning")
		highlight UniteQuickFixWarning ctermfg=1 guifg=Purple
	endif
endfunction



let s:Highlight = vital#of("unite_quickfix").import("Coaster.Highlight")
let s:highlighter = s:Highlight.make()
call s:highlighter.add("file", "Directory", '^\s*\zs[^|]\+\ze|', 0)
call s:highlighter.add("line", "LineNr", '^.\{-}|\zs[^|]\+\ze|', 0)
call s:highlighter.add("error", "UniteQuickFixError", '^.\{-}|.\{-}\zserror\ze|', 0)
call s:highlighter.add("warning", "UniteQuickFixWarning", '^.\{-}|.\{-}\zswarning\ze|', 0)


function! unite#sources#quickfix#highlight_enable()
	call s:highlighter.enable_all()
endfunction


function! unite#sources#quickfix#highlight_disable()
	call s:highlighter.disable_all()
endfunction


function! unite#sources#quickfix#hl_candidates(context)
	call s:default_highlight()
	call unite#sources#quickfix#color_tag_syntax("Bold", "|B>", "<B|")
	highlight uniteSource__QuickFix_Bold term=bold gui=bold


	call unite#sources#quickfix#color_tag_syntax("Red", "|R>", "<R|")
	highlight uniteSource__QuickFix_Red ctermfg=1 guifg=Red

	call unite#sources#quickfix#color_tag_syntax("Purple", "|P>", "<P|")
	highlight uniteSource__QuickFix_Purple ctermfg=1 guifg=Purple

	call unite#sources#quickfix#color_tag_syntax("Error", ">E|", "|E<")
	highlight default link uniteSource__QuickFix_Error UniteQuickFixError

	call unite#sources#quickfix#color_tag_syntax("Warning", ">W|", "|W<")
	highlight default link uniteSource__QuickFix_Warning UniteQuickFixWarning

	let marked_icon = unite#util#escape_pattern(a:context.marked_icon)
	call s:highlighter.add("uniteMarkedLine", "uniteMarkedLine", '^' . marked_icon . '.*$', 5)
	call unite#sources#quickfix#highlight_enable()
endfunction


function! s:source.hooks.on_syntax(args, context)
	call unite#sources#quickfix#hl_candidates(a:context)
	let self.source__old_concealcursor = &l:concealcursor
	setlocal concealcursor=incv
endfunction


function! s:source.hooks.on_close(args, context)
	if &l:concealcursor == "incv"
		let &l:concealcursor = self.source__old_concealcursor
	endif
	call unite#sources#quickfix#highlight_disable()
endfunction




