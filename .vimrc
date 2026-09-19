" ==============================================================================
"                               cmr vimrc
" ==============================================================================
" Tuned up 2026-09-19. Same daily feel, half the lines, no settings fighting
" each other. Original sources, for the archaeology:
"   https://spf13.com/post/perfect-vimrc-vim-config-file/
"   http://blog.sanctum.geek.nz/vim-annoyances/
"   http://blog.sanctum.geek.nz/vim-command-typos/
"   https://github.com/square/maximum-awesome
"   https://github.com/mathiasbynens/dotfiles
"   https://vi.stackexchange.com/a/3877   (,o / ,O)
"   http://dotfiles.org/~brendano/.vimrc  (wildmode)

" ------------------------------------------------------------------------------
" Core
" ------------------------------------------------------------------------------
set nocompatible          " iMproved. Set ONCE - setting it again resets other options.
filetype plugin indent on
syntax on
set encoding=utf-8
set nofoldenable          " never fold anything

" Extremely Important Fix: no one-second delay after Esc / O.
" (5ms wait for the rest of a key code. This is the actual fix; noesckeys was
"  being undone by a second `set nocompatible` and would break arrow keys.)
set ttimeoutlen=5

" Persistent undo + swap files live out of the way.
" `//` on the swap dir encodes the full path so same-named files don't collide.
set directory=~/.vim/swap//
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" Respect modelines in files
set modeline
set modelines=4

" All autocmds in one group so re-sourcing this file doesn't stack duplicates.
augroup vimrc
  autocmd!
augroup END

" Never persist undo history or swap for secret-shaped files.
augroup vimrc
  autocmd BufReadPre,BufNewFile
    \ ~/.aws/*,*/credentials*,*/.ssh/*,*.pem,*.key,*/.*_history,*/.*_token,*.env,*/.env.*,*/secrets.toml,*/.netrc,*/.npmrc,*/.pypirc
    \ setlocal noundofile noswapfile
augroup END

" ------------------------------------------------------------------------------
" Look & feel
" ------------------------------------------------------------------------------
set number                " line numbers
set ruler                 " show where you are
set showcmd               " show (partial) command / leader as it's typed
set cursorline            " highlight current line
set laststatus=2          " always show status line
set scrolloff=5           " start scrolling 5 lines before the window edge
set title                 " filename in the terminal titlebar
set shortmess+=atI        " no splash screen, shorter messages
set noerrorbells
set nostartofline         " don't jump to col 0 when moving around
set splitbelow            " new horizontal splits go below
set splitright            " new vertical splits go right
set nowrap                " no line wrapping ...
set linebreak             " ... but if wrap is turned on, don't break mid-word
set synmaxcol=200         " don't syntax highlight past this column (speed)
set maxmempattern=5000    " raise from 1000 KB to avoid maxmempattern errors on large syntax regions
set redrawtime=10000      " give syntax more time before it gives up and disables highlighting
set mouse=a               " mouse in all modes
let &guicursor .= ',a:blinkon0'  " murder that cursed blinking cursor (gvim)

" Terminal cursor shape: bar in insert, underline in replace, block otherwise.
" DECSCUSR sequences - work in iTerm2, Terminal.app, Ghostty, Alacritty, tmux.
" Steady (not blinking) variants, see above re: murder.
let &t_SI = "\e[6 q"
let &t_SR = "\e[4 q"
let &t_EI = "\e[2 q"

" Automatically rebalance windows on vim resize
augroup vimrc
  autocmd VimResized * wincmd =
augroup END

" ------------------------------------------------------------------------------
" Search
" ------------------------------------------------------------------------------
set hlsearch              " highlight matches
set incsearch             " ... as they're typed
set ignorecase            " case-insensitive ...
set smartcase             " ... unless the pattern has an upper-case letter
hi IncSearch cterm=none ctermfg=blue ctermbg=green
" Space after a search turns off highlights and clears the message line
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" ------------------------------------------------------------------------------
" Editing
" ------------------------------------------------------------------------------
" tabs are 4 spaces: the *correct* way
set tabstop=4 shiftwidth=4 expandtab
set autoindent
set nosmartindent         " die die die
set backspace=indent,eol,start   " backspace over everything in insert mode
set virtualedit=block     " visual block can extend past end of line
set clipboard=unnamed     " yank and paste with the system clipboard

" IMPORTANT - textwidth auto-wraps prose as you type and may drive you mad.
" Code filetypes set textwidth=0 below.
set textwidth=115

" ------------------------------------------------------------------------------
" Command line / files
" ------------------------------------------------------------------------------
set wildmenu
set wildmode=longest,list " :e <Tab> completes longest; <Tab> again lists
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.pyc
if exists('+autochdir')
  set autochdir           " :e is relative to the current file
endif

" ------------------------------------------------------------------------------
" Filetypes
" ------------------------------------------------------------------------------
" Everything here is `setlocal` - a plain `set` inside an autocmd changes the
" global value too, and the next buffer you open inherits it.

" Kill auto-indentation for filetypes where it only gets in the way.
function! s:NoIndent() abort
  setlocal noautoindent nocindent nosmartindent indentexpr=
endfunction

augroup vimrc
  " python: don't move a comment # to column 1; smartindent is pointless here
  autocmd FileType python setlocal textwidth=0 nosmartindent
  autocmd FileType go setlocal textwidth=0 noexpandtab
  autocmd FileType make setlocal textwidth=0 noexpandtab
  autocmd BufRead,BufNewFile *.make setfiletype make
  autocmd FileType c,cpp setlocal textwidth=0 tabstop=4 shiftwidth=4 softtabstop=4 nowrap
  autocmd BufRead,BufNewFile *.sh setlocal textwidth=0 noexpandtab
  autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType yaml,markdown call s:NoIndent()
  autocmd FileType javascript setlocal textwidth=0 tabstop=2 shiftwidth=2 softtabstop=2 nowrap

  " When editing a file, jump to the last known cursor position.
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
augroup END

" ------------------------------------------------------------------------------
" Black on ,bb  (python only)
" ------------------------------------------------------------------------------
" Plugin-free: this vim has no +python3 so the upstream black.vim can't load.
"   ,bb in normal mode  -> black the whole buffer
"   ,bb on a visual selection -> black only those lines, in context
"                                (--line-ranges; the thing macchiato used to fake)
" Never clobbers the buffer on a syntax error - black's message is shown instead.
" One undo step, so `u` reverts the whole format.
"
" Future options if "linting on the fly" is wanted:
"   - ALE (github.com/dense-analysis/ale), pure vimscript, async, install with
"     git clone into ~/.vim/pack/plugins/start/ale ; ruff as linter, black as fixer.
"   - `ruff format --range` is a faster drop-in for black in the function below.
function! s:Black(line1, line2) abort
  let l:cmd = 'black -q --stdin-filename=' . shellescape(expand('%:p')) . ' -'
  if a:line1 != 1 || a:line2 != line('$')
    let l:cmd .= ' --line-ranges=' . a:line1 . '-' . a:line2
  endif
  let l:out = systemlist(l:cmd, getline(1, '$'))
  if v:shell_error
    echohl ErrorMsg | echo join(l:out, ' ') | echohl None
    return
  endif
  let l:view = winsaveview()
  call setline(1, l:out)
  if line('$') > len(l:out)
    silent execute (len(l:out) + 1) . ',$delete _'
  endif
  call winrestview(l:view)
endfunction
augroup vimrc
  autocmd FileType python nnoremap <buffer> <silent> <Leader>bb :call <SID>Black(1, line('$'))<CR>
  autocmd FileType python xnoremap <buffer> <silent> <Leader>bb :<C-u>call <SID>Black(line("'<"), line("'>"))<CR>
augroup END

" ------------------------------------------------------------------------------
" Mappings
" ------------------------------------------------------------------------------
" <Leader> is , (default \ is a stretch, and nobody uses ,)
let mapleader = ','

" ; works like : to save us from Shift
nnoremap ; :

" don't make these keys do annoying things
nnoremap <F1> <nop>
nnoremap Q <nop>
" keep the match / paragraph in the middle of the screen
nnoremap n nzz
nnoremap } }zz
" j and k move among display lines, not just file lines
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" Move Faster: J and K move 7 lines, L joins (default J is now on L)
nnoremap J 7j
nnoremap K 7k
xnoremap J 7j
xnoremap K 7k
nnoremap L :join<CR>

" Bubble text up/down with Ctrl-k / Ctrl-j (single line or visual selection).
" Uses :move so it doesn't clobber the unnamed register / system clipboard.
nnoremap <silent> <C-k> :move .-2<CR>
nnoremap <silent> <C-j> :move .+1<CR>
xnoremap <silent> <C-k> :move '<-2<CR>gv
xnoremap <silent> <C-j> :move '>+1<CR>gv

" Ctrl-h / Ctrl-l move between vertical splits
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" insert a blank line below/above without leaving normal mode
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

" Shift+Tab de-indents in insert mode
inoremap <S-Tab> <C-d>

" Paste over a selection without copying the overwritten text (vim 9 native P)
xnoremap p P

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" TwiddleCase: cycle a visual selection through lower / UPPER / Capital Case
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str, '\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
" (You have to have a visual selection first!!!)
xnoremap <C-p> y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" Strip trailing whitespace (,ss)
function! StripWhitespace()
  let save_cursor = getpos('.')
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
nnoremap <Leader>ss :call StripWhitespace()<CR>

" Strip annoying windows newline characters ^M (,sn)
function! StripWinLineBreaks()
  let save_cursor = getpos('.')
  let old_query = getreg('/')
  :%s/\r//ge
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
nnoremap <Leader>sn :call StripWinLineBreaks()<CR>

" ------------------------------------------------------------------------------
" Fat fingers
" ------------------------------------------------------------------------------
" quit / save via double keypress (normal mode only)
nnoremap XX :q!<CR>
nnoremap QQ :wq<CR>
nnoremap WQ :wq<CR>
nnoremap WW :w<CR>

" :W :Q :E etc. - shift held a beat too long
command! -bang -nargs=? -complete=file E e<bang> <args>
command! -bang -nargs=? -complete=file W w<bang> <args>
command! -bang -nargs=? -complete=file Wq wq<bang> <args>
command! -bang -nargs=? -complete=file WQ wq<bang> <args>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>

" ------------------------------------------------------------------------------
" Abbreviations
" ------------------------------------------------------------------------------
" correct my common typos without me even noticing them (insert mode only)
iabbrev teh the
iabbrev hte the
iabbrev reccommend recommend
iabbrev reccomend recommend
iabbrev recomend recommend
iabbrev slef self
iabbrev paramters parameters
iabbrev exmaple example
iabbrev improt import
iabbrev impot import
iabbrev imrpot import
iabbrev surpress suppress
iabbrev supress suppress
