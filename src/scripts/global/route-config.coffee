
angular.module('vlg')

.config(['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

  $stateProvider
  .state('login', {
    url: '/login'
    templateUrl: "pages/login/login.html"
  })
  .state('hall', {
    url: '/hall'
    templateUrl: "pages/hall/hall.html"
  })
  .state('profile', {
    url: '/profile'
    templateUrl: "pages/profile/profile.html"
    abstract: true
  })
  .state('profile.statistics', {
    url: '/statistics',
    templateUrl: "pages/profile/statistics.html"
  })
  .state('profile.inventory', {
    url: '/inventory',
    templateUrl: "pages/profile/inventory.html"
  })

  $urlRouterProvider.otherwise('/login')

  return
])