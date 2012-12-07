module.exports =
  rtrim: (str, substr) ->
    i = str.length - 1
    
    while i >= 0
      search = str.substring i, str.length
      if substr is search
        str = str.substring 0, i
        break
      i--
    
    return str

  timedChunk: (list, fn, callback) ->
    i = 0
    
    tick = ->
      start = new Date().getTime()

      while i < list.length and (new Date().getTime()) - start < 50
        fn list[i]
        i++
      
      if i < list.length
        setTimeout tick, 1
      else
        callback() if callback?

    setTimeout tick, 25