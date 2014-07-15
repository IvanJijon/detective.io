angular.module('detective.config').config [
    "$stateProvider", "$urlRouterProvider", "$locationProvider",
    ($stateProvider, $urlRouterProvider, $locationProvider)->
        # HTML5 Mode yeah!
        $locationProvider.html5Mode true
        # Not found URL
        $urlRouterProvider.otherwise("/404");
        # ui-router configuration
        $stateProvider
            # Core
            .state('tour',
                url : "/"
                controller : HomeCtrl
                templateUrl : '/partial/home.html'
            )
            .state('404-page',
                url : "/404/"
                controller : NotFoundCtrl
                templateUrl : '/partial/404.html'
            )
            .state('404',
                controller : NotFoundCtrl
                templateUrl : '/partial/404.html'
            )
            .state('403',
                controller : NotFoundCtrl
                templateUrl : '/partial/403.html'
            )
            .state('contact-us',
                url : "/contact-us/"
                controller : ContactUsCtrl
                templateUrl : '/partial/contact-us.html'
            )
            # Accounts
            .state('activate',
                url : "/account/activate/?token"
                controller : UserCtrl
                templateUrl : '/partial/account.activate.html'
            )
            .state('reset-password',
                url : "/account/reset-password/?token"
                controller : UserCtrl
                templateUrl : '/partial/account.reset-password.html'
            )
            .state('reset-password-confirm',
                url : "/account/reset-password-confirm/"
                controller : UserCtrl
                templateUrl : '/partial/account.reset-password-confirm.html'
            )
            .state('login',
                url : "/login/"
                controller : UserCtrl
                templateUrl : '/partial/account.login.html'
            )
            .state('signup',
                url : "/signup/"
                controller : UserCtrl
                templateUrl : '/partial/account.signup.html'
            )
            # Pages
            .state('page',
                url : "/page/:slug/"
                controller : PageCtrl
                # Allow a dynamic loading by setting the templateUrl within controller
                template : "<div ng-include src='templateUrl'></div>"
            )
            # User-related url
            .state('user',
                url : "/:username/"
                controller : ProfileCtrl
                templateUrl : "/partial/account.html"
                resolve : UserCtrl.resolve
            )
            # Topic-related url
            .state('user-topic',
                url : "/:username/:topic/"
                controller : ExploreCtrl
                resolve :
                    topic: UserTopicCtrl.resolve.topic
                # Allow a dynamic loading by setting the templateUrl within controller
                template : "<div ng-include src='templateUrl' ng-if='templateUrl'></div>"
            )
            .state('user-topic-search',
                url: '/:username/:topic/search/?q&page'
                controller: IndividualSearchCtrl
                templateUrl: "/partial/topic.list.html"
                reloadOnSearch: true
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
             # Topic-related url
            .state('user-topic-article',
                url: '/:username/:topic/p/:slug/'
                controller: ArticleCtrl
                templateUrl: "/partial/topic.article.html"
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
            .state('user-topic-contribute',
                url: '/:username/:topic/contribute/'
                controller: ContributeCtrl
                templateUrl: "/partial/topic.contribute.html"
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                auth: true
            )
            .state('user-topic-contribute-upload',
                url: '/:username/:topic/contribute/upload/'
                controller: BulkUploadCtrl
                templateUrl: "/partial/topic.contribute.bulk-upload.html"
                resolve:
                    topic: UserTopicCtrl.resolve.topic
                auth: true
            )
            .state('user-topic-list',
                url: '/:username/:topic/:type/?page'
                controller: IndividualListCtrl
                templateUrl: "/partial/topic.list.html"
                reloadOnSearch: true
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
            .state('user-topic-detail',
                url: '/:username/:topic/:type/:id/'
                controller: IndividualSingleCtrl
                templateUrl: "/partial/topic.single.html"
                reloadOnSearch: true
                resolve:
                    topic: UserTopicCtrl.resolve.topic
            )
]