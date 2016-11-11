
angular.module('vlg')

.config(['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

  _makeState = (cfg) ->
    return $.extend {
      url: '/login'
      templateUrl: "pages/login/login.html"
      onEnter: ['GameService', '$state', (GameService, $state) ->
        if not GameService.gameServer.isLoggedIn() then $state.go('login')
      ]
    }, cfg

  $stateProvider
  .state('login', _makeState {
    url: '/login'
    templateUrl: "pages/login/login.html"
    onEnter: null
  })
  .state('hall', _makeState {
    url: '/hall'
    templateUrl: "pages/hall/hall.html"
  })
  .state('profile', _makeState {
    url: '/profile'
    templateUrl: "pages/profile/profile.html"
    abstract: true
  })
  .state('profile.statistics', _makeState {
    url: '/statistics',
    templateUrl: "pages/profile/statistics.html"
  })
  .state('profile.inventory', _makeState {
    url: '/inventory',
    templateUrl: "pages/profile/inventory.html"
  })
  .state('room', _makeState {
#    url: '/room/:roomType/:roomId',
    url: '/room',
    templateUrl: "pages/room/room.html"
  })

  $urlRouterProvider.otherwise('/login')

  return
])