window.GameServer = (gamecallback) ->
  this.wsurl = "ws://localhost:8080/vlgsocket/game"
  that = this
  stat = 0
  user = null
  passwd_en = null
  passwd = null
  isspeaking = false
  putongplayernum = null
  jiazuplayernum = null
  # 0--not log in
  # 1--loged and in hall
  # 2--entered room , xiazuo , not mai
  # 3--entered room , xiazuo , mai
  # 4--entered room , shangzuo , game not started, not mai
  # 5--entered room , shangzuo , game not started, mai
  # 6--entered room , game started , not speaking
  # 7--entered room , game started , speaking
  # 8--entered room , game started , dead
  ws = null
  is_connected = false

  this.enterputong = (roomid)->
    roomid = Number(roomid);
    if (stat == 1 && roomid >= 0 && roomid < putongplayernum)
      ws.send("action enter putong "+roomid)
      return 0
    else
      return 1

  this.enterjiazu = (roomid)->
    roomid = Number(roomid);
    if (stat == 1 && roomid>=0 && roomid<jiazuplayernum)
      ws.send("action enter jiazu "+roomid)
      return 0
    else
      return 1

  this.shangmai = ()->
    if(stat!=2&&stat!=4)
      return 1
    ws.send("action shangmai")
    return 0

  this.xiamai = ()->
    if(stat!=3&&stat!=5)
      return 1
    ws.send("action xiamai")
    return 0

  this.shangzuo = ()->
    if(stat!=2&&stat!=3)
      return 1
    ws.send("action shangzuo")
    return 0

  this.xiazuo = ()->
    if(stat!=4&&stat!=5)
      return 1
    ws.send("action xiazuo")
    return 0

  this.quitroom = ()->
    if(stat!=2)
      return 1
    stat = 1
    ws.send("action quit")
    return 0

  this.login = (u,p)->
    if(stat!=0)
      return 1
    user = u
    passwd = p
    ws.send("query key")
    return 0

  on_login = gamecallback.onlogin
  on_putong = gamecallback.onputong
  on_jiazu = gamecallback.onjiazu
  on_enterroom = gamecallback.onenterroom
  on_roomplayer = gamecallback.onroomplayer
  on_speaker = gamecallback.onspeaker
  on_open = gamecallback.onopen
  on_close = gamecallback.onclose
  on_error = gamecallback.onerror

  sendaudio = (blob)->
    ws.send(blob)

  rec = new Qrecorder(sendaudio)

  wsopen = (evt)->
    is_connected = true
    on_open(evt)
    return

  wsclose = (evt)->
    is_connected = false
    on_close(evt)
    return

  wsmessage = (evt)->
    if typeof(evt.data) != "string"
      bb = evt.data
      audio = new Audio();
      audio.src = window.URL.createObjectURL(bb)
      audio.play()
      return
    mess = evt.data.split(" ");
    switch mess[0]
      when "pubkey"
        passwd_en = passwd
        ws.send("login #{user} #{passwd_en}")
      when "login"
        ss = Number(mess[1])
        on_login(ss)
        if ss == 0
          stat = 1
          ws.send("query roomputong")
          ws.send("query roomjiazu")
      when "roomputong"
        n = new Array()
        nn = mess[1].split('_')
        n.push(Number(k)) for k in nn
        putongplayernum = n.length
        on_putong(n)
      when "roomjiazu"
        n = new Array()
        nn = mess[1].split('_')
        n.push(Number(k)) for k in nn
        jiazuplayernum = n.length
        on_jiazu(n)
      when "enter"
        ss = Number(mess[1])
        on_enterroom(ss);
        if ss == 0
          stat = 2
      when "roomplayer"
        p = new Array()
        s = new Array()
        m = mess[1].split("#")
        for i in [0..2]
          ss = m[i].split(";")
          players = new Array()
          playerstatus = new Array()
          for k in ss
            t = k.split(",")
            players.push(t[0])
            playerstatus.push(t[1])
          p.push(players)
          s.push(playerstatus)
        on_roomplayer(p,s)
      when "shangzuo"
        r = Number(mess[1])
        if r == 0
          if stat == 2
            stat = 4
          else if stat == 3
            stat = 5
      when "xiazuo"
        r = Number(mess[1])
        if(r == 0)
          if stat == 4
            stat = 2
          else if stat == 5
            stat = 3
      when "shangmai"
        r = Number(mess[1])
        if r == 0
          if stat == 2
            stat = 3
          else if stat == 4
            stat = 5
      when "xiamai"
        r = Number(mess[1])
        if r == 0
          if stat == 3
            stat = 2
          else if stat == 5
            stat = 4
      when "speakover"
        if stat == 3
          stat = 2
        else if stat == 5
          stat =4
        else if stat == 7
          stat =6
      when "speaker"
        r = mess[1]
        if r == '#'
          if stat == 3
            stat = 2
          else if stat == 5
            stat = 4
          else if stat == 7
            stat = 6
        on_speaker(mess[1])
      when "gamestart"
        if (stat == 4 || stat == 5)
          stat = 6
      else
        break

  wserror = (evt)->
    is_connected = false
    on_error(evt)
    return

  this.connect = (wsurl) ->
    ws = new WebSocket(wsurl || this.wsurl)
    ws.onopen = wsopen
    ws.onclose = wsclose
    ws.onmessage = wsmessage
    ws.onerror = wserror
    ws.binaryType = "blob"
    return

  this.isConnected = () ->
    return is_connected

  return

# `function GameServer() { _GameServer.apply(undefined, arguments); }`
