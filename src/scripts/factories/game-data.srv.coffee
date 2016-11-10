angular.module('vlg')

.factory 'GameDataService', ['GameService', '$rootScope', (GameService, $rootScope)->

  dataVendor =
    putongRooms: []
    jiazuRooms:  []
    roomPlayers:  # current room
      shangzuo:  []
      shangmai:  []
      guanzhong: []


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
    $rootScope.$broadcast('$onPutongRoomLoaded')

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
    $rootScope.$broadcast('$onJiazuRoomLoaded')

  GameService.$on 'roomplayer', (players, status) ->
    playerTypes = Object.keys(dataVendor.roomPlayers)
    for playerType, i in playerTypes
      return

  return dataVendor
]