filetype indent on

set background=dark
set belloff=all
set hlsearch
set incsearch
set lazyredraw
set magic
set mat=2
set noerrorbells
set novisualbell
set nu rnu
set shiftwidth=4
set smartcase
set softtabstop=4
set tabstop=4
set path+=**

syntax on

let mapleader=" "

function! ToggleZoom()
    let g:zoom_status = get(g:, 'zoom_status', 0)
    if g:zoom_status == 0
        " Not currently zoomed, so lets zoom in
        wincmd _
        wincmd |
        let g:zoom_status = 1
    else
        " Currently zoomed in, so lets zoom out
        wincmd =
        let g:zoom_status = 0
    endif
endfunction

nnoremap <leader>0 :call ToggleZoom()<CR>


function! RetainZoomStatus()
    " Assume that if we haven't called ToggleZoom() before then all windows
    " are probably meant to be equal (set g:zoom_status to 0)
    let g:zoom_status = get(g:, 'zoom_status', 0)
    if g:zoom_status == 0
        wincmd =
    else
        wincmd _
        wincmd |
    endif
endfunction

augroup zoom
    autocmd!
    autocmd VimResized * call RetainZoomStatus()
augroup END

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! s:DiffOffFunc()
	diffoff
	q
	diffoff
endfunction
com! Diffoffcomplex call s:DiffOffFunc()


map py <leader>run :!python %<cr>
map <leader>vimrc :tabe ~/.vimrc<cr>
map <leader>zsh :tabe ~/.zshrc<cr>
map <leader>diff :DiffSaved<cr>
map <leader>doff :Diffoffcomplex<cr>

autocmd bufwritepost .vimrc source $MYVIMRC
nnoremap <F3> :set list!<CR>
nnoremap <F4> :set paste!<CR>

