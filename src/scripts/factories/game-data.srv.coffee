angular.module('vlg')

.factory 'GameDataService', ['GameService', (GameService)->

  dataVendor =
    putongRooms: []
    jiazuRooms: []

  GameService.$on 'roomputong_playernum', (player_nums)->
    dataVendor.putongRooms.splice(0)
    for player_num, i in player_nums
      dataVendor.putongRooms.push {
        playerCount: player_num
        maxPlayerCount: 20
        name: "普通房"
        id: i
      }

  GameService.$on 'roomjiazu_playernum', (player_nums)->
    dataVendor.jiazuRooms.splice(0)
    for player_num, i in player_nums
      dataVendor.jiazuRooms.push {
        playerCount: player_num
        maxPlayerCount: 20
        name: "家族房"
        id: i
      }

  return dataVendor
]