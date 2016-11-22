angular.module('vlg')

.factory 'GameAudioService', ['GameService', 'GameAudioValue', (GameService, GameAudioValue)->
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

  serviceObj.onSpeak = (playerIdx, callback) ->
    playerIdx = parseInt playerIdx
    if isNaN(playerIdx) then return
    serviceObj.playAudio "speak-#{playerIdx+1}", callback
    return

  serviceObj.onBaofei = (playerIdx, callback) ->
    playerIdx = parseInt playerIdx
    if isNaN(playerIdx) then return
    serviceObj.playAudio "baofei-#{playerIdx+1}", callback
    return

  serviceObj.onLastwords = (playerIdx, callback) ->
    playerIdx = parseInt playerIdx
    if isNaN(playerIdx) then return
    serviceObj.playAudio "lastwords-#{playerIdx+1}", callback
    return

  serviceObj.onOut = (playerIdx, callback) ->
    playerIdx = parseInt playerIdx
    if isNaN(playerIdx) then return
    serviceObj.playAudio "out-#{playerIdx+1}", callback
    return

  return serviceObj
]