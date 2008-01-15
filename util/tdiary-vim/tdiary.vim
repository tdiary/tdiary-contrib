" Copyright (C) 2004 UECHI Yasumasa

" Author: UECHI Yasumasa <uechi@potaway.net>

" $Revision: 1.8 $

" This program is free software; you can redistribute it and/or
" modify it under the terms of the GNU General Public License as
" published by the Free Software Foundation; either version 2, or (at
" your option) any later version.

" This program is distributed in the hope that it will be useful, but
" WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
" General Public License for more details.

" You should have received a copy of the GNU General Public License
" along with this program; see the file COPYING.  If not, write to the
" Free Software Foundation, Inc., 59 Temple Place - Suite 330,
" Boston, MA 02111-1307, USA.


if !exists("g:tdiary_site1_url")
	finish
endif

command! -nargs=0 TDiaryNew call <SID>TDiaryNew()
command! -nargs=0 TDiaryReplace call <SID>TDiaryReplace()
command! -nargs=0 TDiaryUpdate call <SID>TDiaryUpdate()
command! -nargs=0 TDiarySelect call <SID>TDiarySelect()
command! -nargs=0 TDiaryTrackback call <SID>EditTrackBackExcerpt()

let s:curl_cmd = "curl"
let s:user = ''

function! s:TDiaryNew()
	call s:CreateBuffer("append")
	execute ":" . (s:body_start + 1)
	normal dG
	redraw!
endfunction

function! s:TDiaryReplace()
	call s:CreateBuffer("replace")

	let save_pat = @/
	let @/ = 'input.\+name="title"[^>]\+>'
	normal ggn
	let title = substitute(getline("."), '.\+value="\(.*\)".\+', '\1', '')

	let @/ = 'textarea \+name="body"[^>]\+>'
	execute ":" . s:body_start
	normal dndf>
	let @/ = '</textarea'
	normal ndG
	silent! %s///

	silent! %s/&quot;/\"/g
	silent! %s/&gt;/>/g
	silent! %s/&lt;/</g
	silent! %s/&amp;/\&/g

	normal gg
	let @/ = '^Title:'
	normal n
	execute "normal A" . title . "\<Esc>"

	normal G
	redraw!
	let @/ = save_pat
endfunction

function! s:TDiaryUpdate()
	" move to _tdiary_ buffer
	let n = bufwinnr(substitute(bufname("%"), "_.\\+_", "_tdiary_", ""))
	execute "normal " . n . "\<C-W>w"
	
	" set parameters
	let data = s:SetParams()

	" set body & csrf protection key
	let data = data . "&body=" . s:MultiLineURLencode(s:body_start)
	let data = data . s:csrf_protection_key

	" debug mode
	if exists("g:tdiary_vim_debug") && g:tdiary_vim_debug
		call append("$", data)
		return
	endif

	" redirect data to tmpfile
	let tmpfile = tempname()
	execute "redir! > " . tmpfile
	silent echo data
	redir END

	" update diary
	let result = system(s:curl_cmd . s:user . " -d @" . tmpfile . " -e ". s:tdiary_update_url . " " . s:tdiary_update_url)
	call delete(tmpfile)
	redraw!
	if match(result, 'Wait or.\+Click here') != -1
		echo "SUCCESS"
	else
		echo result
	endif
endfunction


function! s:TDiarySelect()
	split tDiary_select
	set buftype=nofile
	set nobuflisted
	set noswapfile

	let i = 1
	while exists("g:tdiary_site{i}_url")
		let site_name = ''
		if exists("g:tdiary_site{i}_name")
			let site_name = g:tdiary_site{i}_name . " "
		endif
		call append(i - 1, site_name . g:tdiary_site{i}_url)
		let i = i + 1
	endwhile
	normal gg

	nnoremap <buffer> <silent> <CR> :call <SID>SetURL()<CR>
endfunction


function! s:EditTrackBackExcerpt()
	let save_line = line(".")
	normal gg
	call search("^TrackBackURL:")
	let tb_url = s:ParamValue(getline("."))

	let tb_url = input("TrackBackURL: ", tb_url)
	delete
	call append(line(".") - 1, "TrackBackURL: " . tb_url)
	execute ":" . save_line

	let tb_bufname = substitute(bufname("%"), "_tdiary_", "_trackback_", "")
	split
	execute "normal \<C-W>w"
	execute "edit " . tb_bufname
	set buftype=nofile
	set noswapfile
	set bufhidden=hide
endfunction


function! s:SetParams()
	let data = ''
	let i = 1

	while i < s:body_start
		let l = getline(i)
		let r = s:ParamValue(l)

		if l =~ "^Editing mode"
			let mode = r
			let data = data . "&" . r . "=" . r
		elseif l =~ "^Date:"
			let data = data . s:Date2PostDate(r, mode)
		elseif l =~ "^Title:"
			let data = data . "&title=" . s:URLencode(r)
		elseif l =~ "^TrackBackURL:"
			if r != ""
				let data = data . "&plugin_tb_url=" . s:URLencode(r)
				let data = data . s:TrackBackExcerpt()
			endif
		endif
			
		let i = i + 1
	endwhile

	return data
endfunction


function! s:ParamValue(str)
	let r = substitute(a:str, '^[^:]\+ *: *\(.*\)', '\1', '')
	let r = substitute(r, ' *$', '', '')
	return r
endfunction


function! s:TrackBackExcerpt()
	let data = "&plugin_tb_excerpt="
	let n = bufwinnr(substitute(bufname("%"), "_.\\+_", "_trackback_", ""))
	if n > 0
		execute "normal " . n . "\<C-W>w"
		let data = data . s:MultiLineURLencode(1)
		execute "normal \<C-W>p"
	endif
	return data
endfunction


function! s:MultiLineURLencode(start_line)
	let i = a:start_line
	let lastline = line("$")
	let data = ""

	while i <= lastline
		let data = data . s:URLencode(getline(i) . "\r\n")
		let i = i + 1
	endwhile

	return data
endfunction


function! s:SetURL(...)
	if a:0 == 0
		let i = line(".")
	else
		let i = a:1
	endif
	let s:tdiary_url = substitute(g:tdiary_site{i}_url, "/\\+$", "", "") . "/"
	if exists("g:tdiary_site{i}_updatescript")
		let update_script = g:tdiary_site{i}_updatescript
	elseif exists("g:tdiary_update_script_name")
		let update_script = g:tdiary_update_script_name
	else
		let update_script = "update.rb"
	endif
	let s:tdiary_update_url = s:tdiary_url . update_script

	let s:user = ""
	call s:SetUser()

	"echo selected site
	let site_name = ""
	if exists("g:tdiary_site{i}_name")
		let site_name = g:tdiary_site{i}_name
	endif
	echo site_name s:tdiary_url

	if a:0 == 0
		close
	endif
endfunction


function! s:SetUser()
	if exists("g:tdiary_use_netrc") && g:tdiary_use_netrc
		let s:user = " --netrc "
	elseif s:user == ''
		let s:user = input("User Name: ")
		let password = inputsecret("Password: ")
		if s:user != ''
			let  s:user = " -u '" . s:user . ":" . password . "' "
		endif
	endif
endfunction


function! s:CreateBuffer(mode)
	if !exists("s:tdiary_update_url")
		call s:SetURL(1)
	endif

	let date = input("Date: ", strftime("%Y%m%d", localtime()))
	execute "edit _tdiary_" . date
	set buftype=nofile
	set noswapfile
	set bufhidden=hide
	"set fileformat=dos

	let s:body_start = 0
	
	call append(s:body_start, "Editing mode (append or replace): " . a:mode)
	let s:body_start = s:body_start + 1
	
	call append(s:body_start, "TrackBackURL: ")
	let s:body_start = s:body_start + 1

	call append(s:body_start, "Date: " . date)
	let s:body_start = s:body_start + 1

	call append(s:body_start, "Title: ")
	let s:body_start = s:body_start + 1

	let s:body_start = s:body_start + 1


	let data = ""
	if a:mode == "replace"
		let data = ' -d "'
		let data = data . s:Date2PostDate(date, a:mode)
		let data = data . '&edit=edit" '
	endif
	execute 'r !' . s:curl_cmd . ' -s ' . s:user . data . s:tdiary_update_url

	normal gg
	let s:csrf_protection_key = ""
	if search('input.\+name="csrf_protection_key"') > 0
		silent! s/&quot;/\"/g
		silent! s/&gt;/>/g
		silent! s/&lt;/</g
		silent! s/&amp;/\&/g
		let k = substitute(getline("."), '.\+value="\(.*\)".\+', '\1', '')
		let s:csrf_protection_key = "&csrf_protection_key=" . s:URLencode(k)
	endif
endfunction


function! s:Date2PostDate(date, mode)
	let year = strpart(a:date, 0, 4)
	let month = strpart(a:date, 4, 2)
	let day = strpart(a:date, 6, 2)

	let old = ''
	if a:mode == "replace"
		let old = "&old=" . a:date
	endif

	return  "&year=" . year . "&month=" . month . "&day=" . day . old
endfunction


function! s:URLencode(str)
	let r = iconv(a:str, &encoding, 'euc-jp')
	let save_enc = &encoding
	let &encoding = 'japan'
	let r = substitute(r, '[^ a-zA-Z0-9_.-]', '\=s:Char2Hex(submatch(0))', 'g')
	let &encoding = save_enc
	let r = substitute(r, ' ', '+', 'g')
	return r
endfunction


function! s:Char2Hex(c)
	let n = char2nr(a:c)
	let r = ''

	while n
		let r = '0123456789ABCDEF'[n % 16] . r
		let n = n / 16
	endwhile

	if strlen(r) % 2 == 1
		let r = '0' . r
	endif

	let r = substitute(r, '..', '%\0', 'g')

	return r
endfunction

