angular.module('detective.config').config [
    "$urlRouterProvider", "$locationProvider",
    ($urlRouterProvider, $locationProvider)->
        # HTML5 Mode yeah!
        $locationProvider.html5Mode true
        # Not found URL
        $urlRouterProvider.otherwise("/embed/");
]