angular.module('vlg')

.factory 'GameAudioService', ['GameService', 'GameAudioValue', 'GameConstant', (GameService, GameAudioValue, GameConstant)->
  audioItems = [].concat(GameAudioValue)
  for item, i in audioItems
    item.player = new Audio()
    item.player.preload = "auto"
    item.player.src = item.path

  serviceObj = {}

  serviceObj.playAudio = (name, callback) ->
    audioItem = null
    for item in audioItems
      if item.name == name
        audioItem = item
        break
    if not audioItem then return
    audioItem.player.load()
    audioItem.player.play()
    setTimeout callback, audioItem.player.duration
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