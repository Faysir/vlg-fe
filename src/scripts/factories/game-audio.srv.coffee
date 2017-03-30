angular.module('vlg')

.factory 'GameAudioService', ['GameService', 'GameAudioValue', 'GameConstant', (GameService, GameAudioValue, GameConstant)->
  audioItems = [].concat(GameAudioValue)
  for item, i in audioItems
    item.player = new Audio()
    item.player.preload = "auto"
    item.player.src = item.path

  serviceObj = {}

  playing = false
  playList = []

  playCallback = () ->
    if playList.length > 0
      playing = true
      playListItem = (playList.splice(0, 1))[0]
      audioItem = null
      for item in audioItems
        if item.name == playListItem.name
          audioItem = item
          break
      if not audioItem then return
      # console.log "play", audioItem.name
      audioItem.player.load()
      audioItem.player.play()
      audioItem.player.oncanplay = () ->
        setTimeout playCallback, (audioItem.player.duration * 1000)
      audioItem.player.onerror = () ->
        setTimeout playCallback, 0
    else
      playing = false
    return

  playAudio = (name, callback) ->
    playList.push({
      name: name
      callback: callback
    })
    if not playing then playCallback()
    return

  serviceObj.playAudio = (name, callback) ->
    playAudio(name, callback)
    return

  # ==============================================

  serviceObj.greetings = (callback) ->
    serviceObj.playAudio "greetings", callback
    return

  serviceObj.mvp = (callback) ->
    serviceObj.playAudio "mvp", callback
    return

  serviceObj.greetings = (callback) ->
    serviceObj.playAudio "greetings", callback
    return

  serviceObj.onOutsidePK = (callback) ->
    serviceObj.playAudio "out-field-pk", callback
    return

  serviceObj.onInsidePK = serviceObj.onPK = (callback) ->
    serviceObj.playAudio "pk", callback
    return

  serviceObj.onVote = (callback) ->
    serviceObj.playAudio "vote", callback
    return

  serviceObj.onWin = (resultCode, callback) ->
    if resultCode == GameConstant.RESULT_KILLERS_DIED
      serviceObj.playAudio "win-cops", callback
    else
      serviceObj.playAudio "win-killers", callback
    return

  serviceObj.onSpeak = (playerNumber, callback) ->
    playerNumber = parseInt playerNumber
    if isNaN(playerNumber) then return
    serviceObj.playAudio "speak-#{playerNumber}", callback
    return

  serviceObj.onBaofei = (playerNumber, callback) ->
    playerNumber = parseInt playerNumber
    if isNaN(playerNumber) then return
    serviceObj.playAudio "baofei-#{playerNumber}", callback
    return

  serviceObj.onLastwords = (playerNumber, callback) ->
    playerNumber = parseInt playerNumber
    if isNaN(playerNumber) then return
    serviceObj.playAudio "lastwords-#{playerNumber}", callback
    return

  serviceObj.onOut = (playerNumber, callback) ->
    playerNumber = parseInt playerNumber
    if isNaN(playerNumber) then return
    serviceObj.playAudio "out-#{playerNumber}", callback
    return

  return serviceObj
]