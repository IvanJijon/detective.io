class TopicBannerCtrl
    # Injects dependencies
    @$inject: ['$scope', '$stateParams', 'Summary']

    constructor: (@scope, @stateParams, @Summary)->
        # ──────────────────────────────────────────────────────────────────────
        # Scope methods
        # ──────────────────────────────────────────────────────────────────────
        @scope.toggleGraphNavigation  = @toggleGraphNavigation
        @scope.toggleFiltersSelection = @toggleFiltersSelection
        @scope.toggleSelectAll        = @toggleSelectAll
        # ──────────────────────────────────────────────────────────────────────
        # Scope attributes
        @scope.graphNavigationEnabled = false
        @scope.filtersSelected        = []
        @scope.filtersNames           = []
        @scope.isLoading              = yes

        # ──────────────────────────────────────────────────────────────────────
        # Get the current topic as default topic
        @scope.topic_selected = @stateParams.topic
        # get forms classes
        @Summary.get({id: "forms"}, @retrieveTopicForms)
        # render the graph on filters change
        @scope.$watch("filtersSelected", @renderGraph, true) # From angular doc : 
        # true means that inequality of the watchExpression is determined according to the angular.equals function. 
        # To save the value of the object for later comparison, the angular.copy function is used.
        # This therefore means that watching complex objects will have adverse memory and performance implications.

    retrieveTopicForms: (forms) =>
        @scope.forms            = _.filter(_.values(forms), ((f)-> f.rules? && f.rules.is_searchable))
        @scope.filtersNames     = _.map(@scope.forms, ((form) -> form.name))
        @scope.filtersSelected  = angular.copy(@scope.filtersNames)
        # FIXME: a lot of methods depend of these data

    # on the "Show all" checkbox click
    toggleSelectAll: =>
        # deselect all
        if @scope.filtersSelected.length == @scope.filtersNames.length
            @scope.filtersSelected = []
        # select all
        else
            @scope.filtersSelected = angular.copy(@scope.filtersNames)

    # on a checkbox click
    toggleFiltersSelection: (filter_name) =>
        idx = @scope.filtersSelected.indexOf(filter_name)
        # is currently selected
        if idx > -1
            @scope.filtersSelected.splice(idx, 1)
        # is newly selected
        else
            @scope.filtersSelected.push(filter_name)

    # show/hide the graph navigation
    toggleGraphNavigation: =>
        @scope.graphNavigationEnabled = not @scope.graphNavigationEnabled
        if @scope.graphNavigationEnabled and not @scope.graphnodes?
            @Summary.get {id: "graph", topic: @scope.topic_selected}, (data) =>
                # save graph data used by @renderGraph
                @data = data
                # hide loading indicator
                @scope.isLoading = no
                @renderGraph()

    # filter the data and render the graph via @scope.graphnodes
    # shared with detective/js/directives/topic.single.graph.coffee
    renderGraph: =>
        if @data?
            data = angular.copy(@data)
            # filter by filtersSelected
            data.leafs = _.object(_.filter(_.pairs(@data.leafs), (leaf) =>
                @scope.filtersSelected.indexOf(leaf[1]._type.toLowerCase()) > -1
            ))
            @scope.graphnodes = data

angular.module('detective.controller').controller 'TopicBannerCtrl', TopicBannerCtrl

# EOF
