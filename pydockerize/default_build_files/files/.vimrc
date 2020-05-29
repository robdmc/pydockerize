"--- define a custom leader
let mapleader=","

"--- Hide a buffer rather than closing it when changing buffers
set hidden

"--- make it so omni complete closes when done
autocmd CompleteDone * pclose

"--- This is some standard stuff
syntax on
filetype plugin indent on
set autoindent
set backspace=2
set tabstop=4
set shiftwidth=4
set expandtab
set showmatch
set ruler
set incsearch
set nowrap
set mouse=a
set nohls
set modeline
set ls=2
set colorcolumn=79,119
filetype indent on
filetype plugin on
set number
set omnifunc=syntaxcomplete#Complete
set viminfo='100,f1
set ww=h,l,b,s,<,>
set cm=blowfish
set timeoutlen=500

"--- Make the mouse work on wide-screens
if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end


"--- This improves highlight colors in vimdiff
set t_Co=256
highlight DiffText term=standout ctermfg=0 ctermbg=11
highlight ColorColumn ctermbg=235 guibg=#2c2d27

"--- make search wraps more obvious
hi WarningMsg ctermfg=white ctermbg=red guifg=White guibg=Red gui=None

"--- add git branch to standard statusline
":set statusline=%<%F\ %h%m%r%=%-14.(%l,%c%V%)\ %P\ %{fugitive#statusline()}

"--- make vertical diffs the default
set diffopt+=vertical


"---These commands make windows-like copy/paste.
"   To get them to work, you must add the following to your .cshrc or .bashrc
"   stty stop ''
"   stty start''
"map <C-c> y
"map<C-x> x
"imap <C-v> <Esc>pi
imap <C-s> <Esc>:w<CR>i
nmap <C-s> :w<CR>
nmap <C-q> :q<CR>
imap <C-q> <Esc>:q<CR>

"--- this allows for repeated block indenting in v-mode like komodo
vmap <Tab> >`[v`]
vmap <S-Tab> <`[v`]

"--- this allows for some nice tab completion in insert mode
"#   shift-tab for file completion  tab for variable completion
imap <S-Tab> <C-x><C-f>
imap <Tab> <C-n>

"---- make control-P insert the full path of the current file
nmap <C-p> :let @" = expand("%:p")<CR>P

"---- This allows tab to switch windows in normal mode
"nmap <CR> <C-w>w
"nmap \ <C-w>w
nnoremap <Space> <C-w>w
nnoremap <S-Right> <C-w>l
nnoremap <S-Left> <C-w>h
nnoremap <S-Up> <C-w>k
nnoremap <S-Down> <C-w>j
nnoremap <Leader><Space> <C-w>w
nnoremap <Leader>l <C-w>l
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>W <C-w>= :vertical resize 130<CR>
nnoremap <Leader>w <C-w>=

"--- Temporarily highlight contents in parens/brackets/etc
nmap <Leader>p %v%:sleep 500m<CR>%

"---- This allows switching tabs in normal mode
nmap <S-Tab> :tabn<CR>

"---- This allows opening copy of this window in new tab
nmap <S-t> <C-w>s<C-w><S-T>


" --- This allows for multiple replacing of same word.
"     usage:  1)  viwy  --> select the word you want to use as replacement
"             2)        --> navigate cursor to word you want replaced
"             3)        --> <Leader>p to paste replacement
"             4)        --> navigate to next instance you want replaced
"             5) .       --> repeat the replacement
nnoremap <leader>p  "_ciw<C-R>"<Esc>

"--- This is a shortcut for copying a word
nnoremap <leader>y  viwy

"--- Shortcut to copy to mac clipboard
vnoremap Y  "+y


"---this remaps the numeric keypad to behave reasonably
if &term=="xterm" || &term=="xterm-color"
   set t_Sb=^[4%dm
   set t_Sf=^[3%dm
   :imap <Esc>Oq 1
   :imap <Esc>Or 2
   :imap <Esc>Os 3
   :imap <Esc>Ot 4
   :imap <Esc>Ou 5
   :imap <Esc>Ov 6
   :imap <Esc>Ow 7
   :imap <Esc>Ox 8
   :imap <Esc>Oy 9
   :imap <Esc>Op 0
   :imap <Esc>On .
   :imap <Esc>OQ /
   :imap <Esc>OR *
   :imap <Esc>Ol +
   :imap <Esc>OS -
endif

"---this sets vim to understand relative tag path
set tagrelative

"--- this makes pwd always be the dir of the current file
autocmd BufEnter * silent! lcd %:p:h

"--- set up vim-flake8
"--- autocmd FileType python map <buffer> <Leader>F :call Flake8()<CR>
"--- let g:flake8_show_in_file=1
"--- let g:flake8_quickfix_height=10
"--- nmap <Leader>f :cnext<CR>
"--- nmap <Leader>g :TagbarToggle<CR>

"--- show the full path of the current file
nmap <Leader>f :echo expand('%:p')<CR>

"--- disable standard python indenter so vim-python-pep8 can take over
let g:pymode_indent = 0

"--- make tagbar open the window on the left
"let g:tagbar_left = 1

"--- set up undo tree stuff
if has("persistent_undo")
    set undodir=~/.undodir/
    set undofile
endif
nmap <Leader>u :UndotreeToggle<CR>

"--- make it easy to find cursor by just hitting ; in normal mode
:nmap <Leader>; :set cursorline<CR>:set cursorcolumn<CR>:sleep 80m<CR>:set nocursorline<CR>:set nocursorcolumn<CR>


"---create ctags shortcut for opening definition in new tab or window
"---:nnoremap <Leader>d <C-w>g<C-]><C-w>T
"---:nnoremap <Leader>D <C-w>g<C-]><C-w>v
"---:nnoremap <Leader>d <C-w><C-v><C-w>T g<C-]>
:nnoremap <Leader>D <C-w><C-v><C-w>T:exec("tj ".expand("<cword>"))<CR>
:nnoremap <Leader>d <C-w><C-v><C-w>l:exec("tj ".expand("<cword>"))<CR>
":nnoremap <Leader>d :vsp <CR> <C-w>T :exec("ts ".expand("<cword>"))<CR>
":nnoremap <Leader>D :vsp <CR> <C-w>l :exec("ts ".expand("<cword>"))<CR>

"--- command to rebuild tags
:nnoremap <Leader>m :!make_tags<CR>

"---set the way vim searches for tag files
:set tags=./tags,tags;
