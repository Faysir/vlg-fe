angular.module('vlg')

.factory 'DialogService', [()->

  serviceObj = {}

  serviceObj.alert = (message) ->
    window.alert(message)

  return serviceObj
]