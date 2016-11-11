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
    currentSpeakerId: -1


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
    $rootScope.$broadcast '$onPutongRoomLoaded'

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
    $rootScope.$broadcast '$onJiazuRoomLoaded'

  GameService.$on 'roomplayer', (players, status) ->
    playerTypes = Object.keys(dataVendor.roomPlayers)
    for playerType, i in playerTypes
      dataVendor.roomPlayers[playerType].splice 0
      for playerName, j in players[i]
        playerStatus = status[i][j]
        dataVendor.roomPlayers[playerType].push
          name: playerName
          status: playerStatus
          imageUrl: "vendor/images/login/bg.png"
    $rootScope.$broadcast '$onRoomPlayersLoaded'

  GameService.$on 'speaker', (speaker_player_id) ->
    speaker_player_id = parseInt(speaker_player_id)
    if isNaN(speaker_player_id)
      speaker_player_id = -1
    dataVendor.currentSpeakerId = speaker_player_id
    $rootScope.$broadcast '$onRoomPlayersLoaded'

  return dataVendor
]