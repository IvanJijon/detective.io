angular.module('detective.directive').directive "ttTypeahead", ($rootScope, $filter, $compile, $stateParams, User)->
    lastDataset = []
    template =
        compile: (template) ->
            compiled = $compile(template)
            render: (context) ->
                $scope = $rootScope.$new yes
                $scope = angular.extend($scope, context)
                $scope.getModel = ->
                    if context.model?
                        context.model
                    else if context.predicate? and context.predicate.name is '<<INSTANCE>>'
                        context.object
                    else if context.subject?
                        context.subject.label
                    else
                        no
                $scope.getFigureBg = -> $filter("strToColor") $scope.getModel()
                $scope.isList = -> !context.predicate or context.predicate.name isnt '<<INSTANCE>>'

                element = compiled $scope
                do $scope.$apply
                html = do element.html
                do $scope.$destroy
                html

    scope:
        model     : "=ttModel"
        individual: "&ttIndividual"
        topic     : "&ttTopic"
        create    : "&ttCreate"
        submit    : "&ttSubmit"
        endpoint  : "&ttEndpoint"
        valueKey  : "@"
        value     : '=?'
        limit     : "@"
        change    : "&"

    link: (scope, element, attrs) ->
        # Helper to save the search response
        saveResponse = (response) ->
            lastDataset = response.objects

        # Set a default value
        element.val scope.model.name if scope.model?
        element.val scope.value if scope.value?

        scope.$watch 'value', (val, old)->
            element.typeahead('val', val)
        , yes

        start = =>
            # Select the individual to look for
            individual = (scope.individual() or "").toLowerCase()
            itopic     = (scope.topic() or $stateParams.topic or "common").toLowerCase()
            iendpoint  = (do scope.endpoint) or 'search'

            lastDataset = []
            element.typeahead 'destroy'

            bh = new Bloodhound
                datumTokenizer : Bloodhound.tokenizers.obj.whitespace
                queryTokenizer : Bloodhound.tokenizers.whitespace
                dupDetector : (a, b) ->
                    a_id = a.id || a.subject.name
                    b_id = b.id || b.subject.name
                    a_id is b_id
                prefetch :
                    url : "/api/#{itopic}/v1/#{individual}/mine/"
                    filter : saveResponse
                remote :
                    url : "/api/#{itopic}/v1/#{individual}/#{iendpoint}/?q=%QUERY"
                    filter : saveResponse

            bh.storage = null # Hack to disable localStorage caching
            do bh.initialize

            options =
                # Create the typehead
                hint : yes
                highlight : yes

            element.typeahead options,
                displayKey : (scope.valueKey or "name")
                name : 'suggestions-' + do scope.topic
                source : do bh.ttAdapter
                templates :
                    suggestion : (template.compile [
                        '<div>',
                            '<div class="tt-suggestion__line" ng-class="{\'tt-suggestion__line--with-model\': getModel()}">',
                                '[[name||label]]',
                                '<div class="tt-suggestion__line__model" ng-show="getModel()">',
                                    '<div class="tt-suggestion__line__model__figure" ng-style="{ background: getFigureBg()}">',
                                        '<i ng-show="isList()" class="fa fa-list"></i>',
                                    '</div>',
                                    '[[getModel()]]',
                                '</div>',
                            '</div>',
                        '</div>'
                    ].join "").render

            # Unbind all events
            (((element.off "keyup").off "change").off "typeahead:selected").off "typeahead:uservalue"

            # Watch keys
            element.on "keyup", (event)->
                # Enter is pressed
                if event.keyCode is 13 and scope.submit?
                    # Apply the scope change
                    scope.$apply =>
                        do scope.submit

            # Watch select event
            element.on "typeahead:selected", (input, individual)->
                if scope.model?
                    scope.$apply =>
                        angular.copy(individual, scope.model);
                do scope.change if scope.change?

            # Watch user value event
            element.on "typeahead:uservalue", ()->
                return unless scope.model?
                # Empty selected model
                delete scope.model.id
                # Record the value
                scope.model.name = $(this).val()
                # Evaluate the 'create' expression
                do scope.create if typeof(scope.create) is "function"
                # Apply the scope change
                do scope.$apply

            # Watch change event
            element.on "change", (input)->
                # Filter using the current value
                datum = _.findWhere lastDataset, "name": element.val()
                # If datum exist, use the selected event
                ev = "typeahead:" + (if datum then "selected" else "uservalue")
                # Trigger this even
                element.trigger ev, datum

        scope.$watch =>
            do scope.topic
        , (newValue, oldValue) =>
            if newValue? and newValue isnt oldValue
                do start
        , yes

        do start