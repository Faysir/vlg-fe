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

  serviceObj.onSpeak = (playerIdx) ->
    playerIdx = parseInt playerIdx
    if isNaN(playerIdx) then return
    serviceObj.playAudio "speak-#{playerIdx+1}"
    return

  return serviceObj
]