
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
  })

  $urlRouterProvider.otherwise('/login')

  return
])