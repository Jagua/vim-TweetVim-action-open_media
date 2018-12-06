let s:save_cpo = &cpo
set cpo&vim


function! tweetvim#action#download_media#define() abort
  return {
        \ 'description' : 'download media',
        \}
endfunction


function! tweetvim#action#download_media#execute(tweet) abort
  let media_type = tweetvim#action#base_media#get_media_type(a:tweet)
  if !empty(media_type)
    call s:download_{media_type}.do(a:tweet)
  endif
endfunction


function! s:filepath(tweet, idx, url) abort
  let tweet = a:tweet
  let home_dir = empty($HOME) ? $USERPFORILE : $HOME
  if empty(home_dir)
    echoerr 'download_media: $HOME (or %USERPFORILE% on MS Windows) is empty'
  endif
  let path_sep = has('win32') ? '\' : '/'
  let dir = join([home_dir, 'Downloads'], path_sep)
  if !isdirectory(dir)
    echoerr 'download_media: ~/Downloads directory does not exist'
  endif

  if has_key(tweet, 'retweeted_status')
    let screen_name = tweet.retweeted_status.user.screen_name
    let created_at = tweet.retweeted_status.created_at
  else
    let screen_name = tweet.user.screen_name
    let created_at = tweet.created_at
  endif

  let name_head = ''
  if executable('sh') && executable('date')
    let name_head .= get(systemlist(printf('sh -c "date --date=''%s'' +%%F"', created_at)), 0, '')
    let name_head .= '_'
  endif
  let name_head .= screen_name
  let name_tail = fnamemodify(a:url, ':t')
  " Note: remove ':orig' suffix if exists. see s:base_photo.urls()
  let name_tail = substitute(name_tail, '^\(.*\):orig$', '\1', '')

  return join([dir, printf('%s_%d_%s', name_head, a:idx, name_tail)], path_sep)
endfunction


function! s:download(tweet) abort
  if executable('curl')
    return {urls -> map(urls, {idx, url ->
          \ tweetvim#action#base_media#job(['curl', url, '--output', s:filepath(a:tweet, idx, url)])})}
  else
    echoerr 'download_media: curl does not found'
  endif
endfunction


"
" type: photo
"


let s:download_photo = tweetvim#action#base_media#get_module('photo')


function! s:download_photo.func() abort
  return get(b:, 'tweetvim_action_download_media_photo', s:download(self.tweet))
endfunction


"
" type: video
"


let s:download_video = tweetvim#action#base_media#get_module('video')


function! s:download_video.func() abort
  return get(b:, 'tweetvim_action_download_media_video', s:download(self.tweet))
endfunction


"
" type: animated_gif
"


let s:download_animated_gif = tweetvim#action#base_media#get_module('animated_gif')


function! s:download_animated_gif.func() abort
  return get(b:, 'tweetvim_action_download_media_animated_gif', s:download(self.tweet))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
