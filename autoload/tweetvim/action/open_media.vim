let s:save_cpo = &cpo
set cpo&vim


function! tweetvim#action#open_media#define() abort
  return {
        \ 'description' : 'open media',
        \}
endfunction


function! tweetvim#action#open_media#execute(tweet) abort
  let media_type = tweetvim#action#base_media#get_media_type(a:tweet)
  if !empty(media_type)
    call s:open_{media_type}.do(a:tweet)
  endif
endfunction


function! s:open_url() abort
  if has('win32')
    if executable('cmd.exe')
      return {urls -> map(urls, {_, url -> tweetvim#action#base_media#job('cmd.exe /c start "" "' . url . '"')})}
    else
      return {urls -> execute('echo "open_media: not found cmd.exe"', '')}
    endif
  elseif has('unix')
    if executable('xdg-open')
      return {urls -> map(urls, {_, url -> tweetvim#action#base_media#job(['xdg-open', url])})}
    else
      return {urls -> execute('echo "open_media: not found xdg-open"', '')}
    endif
  endif
endfunction


"
" type: photo
"


let s:open_photo = tweetvim#action#base_media#get_module('photo')


function! s:open_photo.func() abort
  return get(b:, 'tweetvim_action_open_media_photo', s:open_url())
endfunction


"
" type: video
"


let s:open_video = tweetvim#action#base_media#get_module('video')


function! s:open_video.func() abort
  return get(b:, 'tweetvim_action_open_media_video', s:open_url())
endfunction


"
" type: animated_gif
"


let s:open_animated_gif = tweetvim#action#base_media#get_module('animated_gif')


function! s:open_animated_gif.func() abort
  return get(b:, 'tweetvim_action_open_media_animated_gif', s:open_url())
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
