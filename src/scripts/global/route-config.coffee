
angular.module('vlg')

.config(['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

  $stateProvider
  .state('login', {
    url: '/login'
    templateUrl: "pages/login/login.html"
  })

  $urlRouterProvider.otherwise('/login')

  return
])