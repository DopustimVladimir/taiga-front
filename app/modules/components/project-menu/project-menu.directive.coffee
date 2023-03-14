###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

ProjectMenuDirective = (projectService, lightboxFactory, $timeout, $rootScope, $translate) ->
    link = (scope, el, attrs, ctrl) ->
        projectChange = () ->
            if projectService.project
                ctrl.show()
            else
                ctrl.hide()

        scope.$watch ( () ->
            return projectService.project
        ), projectChange

        fixed = false
        topBarHeight = 48

        window.addEventListener "scroll", () ->
            position = $(window).scrollTop()

            if position > topBarHeight && fixed == false
                el.find('.sticky-project-menu').addClass('unblock')
                fixed = true
            else if position == 0 && fixed == true
                el.find('.sticky-project-menu').removeClass('unblock')
                fixed = false

        $timeout ( ->
            newIssueButton = document.querySelector('tg-legacy-loader').shadowRoot.querySelector('.new-issue-button')
            if newIssueButton
                newIssueButton.addEventListener 'click', () ->
                    $rootScope.$broadcast 'genericform:new',
                        objType: 'issue',
                        project: projectService.project.toJS()
        ), 10

    return {
        scope: {},
        controller: "ProjectMenu",
        controllerAs: "vm",
        templateUrl: "components/project-menu/project-menu.html",
        link: link
    }

ProjectMenuDirective.$inject = [
    "tgProjectService",
    "tgLightboxFactory",
    '$timeout',
    '$rootScope',
    '$translate'
]

angular.module("taigaComponents").directive("tgProjectMenu", ProjectMenuDirective)
