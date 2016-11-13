angular.module('vlg')

.factory 'GameDataService', ['GameService', '$rootScope', (GameService, $rootScope)->

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
    loginName: null


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

  GameService.$on 'speaker', (speaker_player_name) ->
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
    $rootScope.$broadcast '$speakerChanged'
    return

  return dataVendor
]