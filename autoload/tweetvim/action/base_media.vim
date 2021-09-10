let s:save_cpo = &cpo
set cpo&vim


function! tweetvim#action#base_media#get_module(media_type) abort
  return deepcopy(s:base_{a:media_type})
endfunction


function! tweetvim#action#base_media#find_entity_tweet(tweet) abort
  let tweet = a:tweet

  if has_key(tweet, 'extended_entities') && !empty(tweet.extended_entities.media)
    return [v:true, tweet]
  endif

  if has_key(tweet, 'retweeted_status')
    return tweetvim#action#base_media#find_entity_tweet(tweet.retweeted_status)
  elseif has_key(tweet, 'quoted_status')
    return tweetvim#action#base_media#find_entity_tweet(tweet.quoted_status)
  endif

  return [v:false, tweet]
endfunction


function! tweetvim#action#base_media#get_media_type(tweet) abort
  let tweet = a:tweet

  if !has_key(tweet, 'extended_entities') || empty(tweet.extended_entities.media)
    echohl Comment
    echo 'no media'
    echohl None
    return ''
  end

  let media_type = tweet.extended_entities.media[0].type
  if media_type !~# '^\%(photo\|video\|animated_gif\)$'
    echo printf('unknown media type: %s', media_type)
    return ''
  endif

  return media_type
endfunction


function! tweetvim#action#base_media#job(cmdlns) abort
  if has('nvim') && exists('*jobstart')
    call jobstart(a:cmdlns)
  elseif has('job')
    call job_start(a:cmdlns)
  else
    echoerr 'require Vim +job feature'
  endif
endfunction


"
" abstract:
"


let s:base = {}


function! s:base.do(tweet) abort
  let self.tweet = a:tweet
  call call(self.func(), [self.urls()])
endfunction


function! s:base.urls() abort
  return []
endfunction


function! s:base.func() abort
  return {urls -> execute('echo "base_media: func() is not implemented"', '')}
endfunction


"
" type: photo
"


let s:base_photo = deepcopy(s:base)


function! s:base_photo.urls() abort
  let media_list = self.tweet.extended_entities.media
  return map(copy(media_list), 'v:val.media_url')
endfunction


"
" type: video
"


let s:base_video = deepcopy(s:base)


function! s:base_video.urls() abort
  let media_list = self.tweet.extended_entities.media
  return map(copy(media_list), {_, media -> get(map(sort(filter(copy(media.video_info.variants), {_, val -> has_key(val, 'bitrate')}), {i1, i2 -> i2.bitrate - i1.bitrate}), {_, val -> val.url}), 0, '')})
endfunction


"
" type: animated_gif
"


let s:base_animated_gif = deepcopy(s:base_video)


let &cpo = s:save_cpo
unlet s:save_cpo
