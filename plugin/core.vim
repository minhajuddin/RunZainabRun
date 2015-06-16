" TODO: Make this use a tmp file and the backgrounding process

" name of the output buffer
let s:OUTPUT_BUFFER_NAME="RunZainabRun"
" use a negative number to avoid conflicts with other buffers
let s:buffer_number = -1

" This function opens an output buffer if it doesn't
" exist, and makes it visible if it exists and then
" swiches to this scratch buffer
function! ShowOutputScratchBuffer()
  " if buffer is not present open it in a split view
  " and store buffer number for further perusal
  if(s:buffer_number == -1 || bufexists(s:buffer_number) == 0)
    exec "sp ". s:OUTPUT_BUFFER_NAME
    let s:buffer_number = bufnr('%')
    " set window height
    resize 5
  else
    " if the window of the scratch buffer is not visible
    let buffer_win=bufwinnr(s:OUTPUT_BUFFER_NAME)
    if(buffer_win == -1)
      " open a split view with that buffer
      exec 'sb '. s:buffer_number
    else
      " else switch to it if it is visible
      exec buffer_win.'wincmd w'
    endif
  endif
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  " clear the buffer for the new output
  " comment out this line if you don't want this behavior
  execute 'normal  ggdG'
endfunction

function! RunRawCommandOnCurrentBuffer(cmd)
  let original_bufnr = bufnr('%')
  let shellcommand = a:cmd . " 2>&1"
  call ShowOutputScratchBuffer()
  "call setline(1, '#OUTPUT for ' . shellcommand)
  execute "0read ! " . shellcommand
  " switch to original buffer
  let original_winnr =  bufwinnr(original_bufnr)
  exec original_winnr.'wincmd w'
  1
endfunction

function! RunCommandOnCurrentBuffer(cmd)
  call RunRawCommandOnCurrentBuffer(a:cmd . " " . bufname("%"))
endfunction

function! RunHandler()
  " to save the cursor position
  let l:winview = winsaveview()
  let currentfilename = expand('%:t')
  if &ft == "go"
    call RunCommandOnCurrentBuffer('go run')
    echo "triggered go run " . currentfilename
  elseif &ft == "javascript"
    call RunCommandOnCurrentBuffer('node')
    echo "triggered node " . currentfilename
  elseif &ft == "sh"
    call RunCommandOnCurrentBuffer('/bin/sh')
    echo "triggered /bin/sh " . currentfilename
  elseif &ft == "ruby"
    if match(currentfilename, 'spec') > 0
      let rspec_cmd = '!b bundle exec rspec ' . expand('%:p') . ':' . line('.')
      silent execute rspec_cmd
      redraw!
      echo "triggered ". rspec_cmd
    else
      call RunCommandOnCurrentBuffer('ruby')
      redraw!
      echo 'execd current file'
    endif
  elseif &ft == "c"
    let c_bn = bufname("%")
    let c_binary_path = expand("%:p:r")
    call RunRawCommandOnCurrentBuffer('cc '. rust_bn . '&& ' . binary_path)
    echo "triggered cc run" . currentfilename
  elseif &ft == "rust"
    let rust_bn = bufname("%")
    let binary_path = expand("%:p:r")
    call RunRawCommandOnCurrentBuffer('rustc '. rust_bn . '&& ' . binary_path)
    echo "triggered rust run" . currentfilename
  endif
  call winrestview(l:winview)
endfunction
nnoremap <C-d> :call RunHandler()<cr>

