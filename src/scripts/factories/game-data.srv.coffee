angular.module('vlg')

.factory('GameDataService', ['GameService', '$rootScope', (GameService, $rootScope)->

  dataVendor =
    putongRooms: []
    jiazuRooms:  []
    roomPlayers:  # current room only
      shangmai:  []
      shangzuo:  []
      guanzhong: []
    roomInfo:
      type: null
      id: null
    currentSpeaker: null
    currentSpeakTimeLimit: null
    loginName: null
    diedList: []
    gameInfo: null

  GameService.$on 'roomputong_playernum', (player_nums)->
    dataVendor.putongRooms.splice(0)
    for player_num, i in player_nums
      dataVendor.putongRooms.push {
        playerCount: player_num
        maxPlayerCount: 20
        name: "普通房"
        type: "putong"
        id: i
      }
    $rootScope.$broadcast '$putongRoomLoaded'

  GameService.$on 'roomjiazu_playernum', (player_nums)->
    dataVendor.jiazuRooms.splice(0)
    for player_num, i in player_nums
      dataVendor.jiazuRooms.push {
        playerCount: player_num
        maxPlayerCount: 20
        name: "家族房"
        type: "jiazu"
        id: i
      }
    $rootScope.$broadcast '$jiazuRoomLoaded'

  GameService.$on 'roomplayer', (players, status) ->
    playerTypes = Object.keys(dataVendor.roomPlayers)
    for playerType, i in playerTypes
      dataVendor.roomPlayers[playerType].splice 0
      for playerName, j in players[i]
        playerStatus = status[i][j]
        dataVendor.roomPlayers[playerType].push
          name: playerName
          status: parseInt(playerStatus)
          imageUrl: "vendor/images/login/bg.png"
    $rootScope.$broadcast '$roomPlayersLoaded'

  GameService.$on 'speaker', (speaker_player_name, speak_time_limit) ->
    if speaker_player_name == "#"
      speaker_player_name = null
      dataVendor.currentSpeaker = null
      $rootScope.$broadcast '$speakerChanged'
      return
    speakerPlayer = null
    for player in [].concat(dataVendor.roomPlayers.shangmai, dataVendor.roomPlayers.shangzuo, dataVendor.roomPlayers.guanzhong)
      if player.name == speaker_player_name
        speakerPlayer = player
        break
    if not speakerPlayer
      console.warn "[GameDataService] [on $speakerChanged] cannot find the corresponding player"
      return
    dataVendor.currentSpeaker = speakerPlayer
    dataVendor.currentSpeakTimeLimit = speak_time_limit
    $rootScope.$broadcast '$speakerChanged'
    return

  GameService.$on 'gamestart', () ->
    if GameService.gameServer.inGame()
      dataVendor.gameInfo = GameService.gameServer.gameInfo()
      dataVendor.diedList.splice(0)
    $rootScope.$broadcast '$gameStarted'
    return

  GameService.$on 'gameover', (result, score) ->
    dataVendor.gameInfo = null
    $rootScope.$broadcast '$gameOver', result, score
    return

  GameService.$on 'daylight', (killed_number) ->
    if killed_number
      dataVendor.diedList.push(killed_number)
    $rootScope.$broadcast '$daylight', killed_number

  GameService.$on 'voted', (kicked_number) ->
    if kicked_number
      dataVendor.diedList.push(kicked_number)
    $rootScope.$broadcast '$voteOver', kicked_number

  GameService.$on 'checked', (number, role) ->
    $rootScope.$broadcast 'checked', number, role

  return dataVendor
])

.factory('GameConstant', [() ->
  constants =
    ROLE_COP: window.GameServer.ROLE_COP
    ROLE_KILLER: window.GameServer.ROLE_KILLER
    ROLE_VILLAGER: window.GameServer.ROLE_VILLAGER
    RESULT_KILLERS_DIED: window.GameServer.RESULT_KILLERS_DIED
    RESULT_COPS_DIED: window.GameServer.RESULT_COPS_DIED
    RESULT_VILLAGERS_DIED: window.GameServer.RESULT_VILLAGERS_DIED
  return constants
])