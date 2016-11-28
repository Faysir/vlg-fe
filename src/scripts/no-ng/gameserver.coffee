window.GameServer = (gamecallback) ->
  # this.wsurl = "ws://#{window.location.hostname}:8080/vlgsocket/game"
  this.wsurl = "ws://localhost:8080/vlgsocket/game"
  that = this
  stat = 0
  user = null
  passwd_en = null
  passwd = null
  isspeaking = false
  putongplayernum = null
  jiazuplayernum = null
  game_role = null
  game_number = null
  game_specs = 0 # count of cops or killers
  game_partners = []
  enable_record = false
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

  this.query_roomputong = ()->
    if stat == 0
      return 1
    ws.send "query roomputong"
    return 0

  this.query_roomjiazu = ()->
    if stat == 0
      return 1
    ws.send "query roomjiazu"
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
  on_shangzuo = gamecallback.onshangzuo
  on_xiazuo = gamecallback.onxiazuo
  on_shangmai = gamecallback.onshangmai
  on_xiamai = gamecallback.onxiamai
  on_gamestart = gamecallback.ongamestart
  on_gameover = gamecallback.ongameover
  on_speakover = gamecallback.onspeakover
  on_baofei = gamecallback.onbaofei
  on_killed = gamecallback.ondaylight # informed when night ends, if someone is killed, the number will be passed
  on_checked = gamecallback.onchecked # cops are informed when someone is checked
  on_voted = gamecallback.onvoted
  on_startvote = gamecallback.onstartvote
  on_startvoteinsidepk = gamecallback.onstartvoteinsidepk
  on_startvoteoutsidepk = gamecallback.onstartvoteoutsidepk
  on_sha = gamecallback.onsha # a signal for killers to kill
  on_yan = gamecallback.onyan # a signal for cops to check
  on_shayan = gamecallback.onshayan # a signal for villagers that night is comming

  sendaudio = (blob)->
    if enable_record then ws.send(blob)

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
      audio = new Audio()
      audio.src = window.URL.createObjectURL(bb)
      # console.log "evt.data", bb
      # console.log "audio.src: ", audio.src
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
            if k.length == 0 then continue
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
        on_shangzuo(r)
      when "xiazuo"
        r = Number(mess[1])
        if(r == 0)
          if stat == 4
            stat = 2
          else if stat == 5
            stat = 3
        on_xiazuo(r)
      when "shangmai"
        r = Number(mess[1])
        if r == 0
          if stat == 2
            stat = 3
          else if stat == 4
            stat = 5
        on_shangmai(r)
      when "xiamai"
        r = Number(mess[1])
        if r == 0
          if stat == 3
            stat = 2
          else if stat == 5
            stat = 4
        on_xiamai(r)
      when "speakover"
        if stat == 3
          stat = 2
        else if stat == 5
          stat =4
        else if stat == 7
          stat =6
        on_speakover()
      when "speaker"
        r = mess[1]
        t = Number mess[2]
        if r == '#'
          if stat == 3
            stat = 2
          else if stat == 5
            stat = 4
          else if stat == 7
            stat = 6
        on_speaker(r, t)
      when "gamestart"
        game_specs = Number mess[1]
        player_list = mess[2].split "_"
        game_role = Number(mess[3])
        game_number = Number(mess[4])
        game_partners = if (mess[5] and (mess[5].length > 0)) then (Number n for n in mess[5].split('_')) else []
        if (stat == 4 || stat == 5)
          stat = 6
        on_gamestart()
      when "gameover"
        x = Number mess[1]
        s = Number mess[2]
        game_role = null
        game_number = null
        if (stat == 6 || stat == 7 || stat == 8)
          stat = 2
        on_gameover x, s
      when "sha"
        on_sha()
      when "yan"
        on_yan()
      when "shayan"
        on_shayan()
      when "someonebaofei"
        x = Number mess[1]
        if (x == game_number) && (stat == 6 || stat == 7)
          stat = 8
        on_baofei x
      when "killed"
        x = Number mess[1]
        if x > 0
          if (x == game_number) && (stat == 6 || stat == 7)
            stat = 8
          on_killed x
        else
          on_killed null
      when "voted"
        x = Number mess[1]
        if (x == game_number) && (stat == 6 || stat == 7)
          stat = 8
        equal_list = undefined
        if x is 0
          equal_list = (num for num in mess[2].split('_'))
          x = null
        on_voted x, equal_list
      when "checked"
        x = Number mess[1] or null
        r = Number mess[2]
        on_checked x, r
      when "startvote"
        on_startvote()
      when "startvoteinsidepk"
        xx = (Number n for n in mess[1].split('_'))
        # xx = [1, 2]
        on_startvoteinsidepk(xx)
      when "startvoteoutsidepk"
        xx = (Number n for n in mess[1].split('_'))
        # xx = [1, 2]
        on_startvoteoutsidepk(xx)
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

  this.isLoggedIn = ()->
    return is_connected and (stat != 0)

  this.isShangzuo = ()->
    return ((stat == 4) || (stat == 5) || (stat == 6) || (stat == 7) || (stat == 8))
  this.isShangmai = ()->
    return ((stat == 3) || (stat == 5) || (stat == 7))

  this.myRole = () ->
    return game_role
  this.myNumber = () ->
    return game_number
  this.inGame = () ->
    return (stat == 6 || stat == 7 || stat == 8)
  this.gameInfo = ()->
    info =
      role: game_role
      number: game_number
      specs: game_specs
      partners: game_partners
    return info
  this.isDead = () ->
    return (stat == 8)

  this.kill = (number) ->
    if not (game_role == window.GameServer.ROLE_KILLER) then return 2
    if this.isDead() then return 1
    ws.send("action sha #{number}")
    return 0
  this.check = (number) ->
    if not (game_role == window.GameServer.ROLE_COP) then return 2
    if this.isDead() then return 1
    ws.send("action yan #{number}")
    return 0
  this.vote = (number) ->
    if this.isDead() then return 1
    ws.send("action vote #{number}")
    return 0
  this.baofei = () ->
    ws.send("action baofei")
    return 0
  this.end_speak = () ->
    ws.send("action speakend")
    return 0

  this.startrec = () ->
    if enable_record then rec.startrec()
  this.stoprec = () ->
    if enable_record then rec.stoprec()

  return

# `function GameServer() { _GameServer.apply(undefined, arguments); }`

window.GameServer.ROLE_COP = 0
window.GameServer.ROLE_KILLER = 1
window.GameServer.ROLE_VILLAGER = 2

window.GameServer.RESULT_KILLERS_DIED = 1
window.GameServer.RESULT_COPS_DIED = 2
window.GameServer.RESULT_VILLAGERS_DIED = 3
