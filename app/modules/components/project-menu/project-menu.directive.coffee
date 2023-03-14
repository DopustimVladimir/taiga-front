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
            project = projectService.project.toJS()
            if project.is_issues_activated and 'modify_issue' in project.my_permissions
                newIssueButton = document.createElement('button')
                newIssueButton.textContent = $translate.instant('ISSUES.ACTION_NEW_ISSUE')
                newIssueButton.style.cssText = 'cursor: pointer;' +
                    'display: inline-flex; justify-content: center; align-items: center;' +
                    'box-sizing: border-box; padding: .75rem 1.5rem; margin: 10px;' +
                    'border: 0; border-radius: 4px;' +
                    'color: #2E3440; background-color: #83EEDE;' +
                    'font: inherit; font-size: .8rem; line-height: initial;' +
                    'text-align: center; text-transform: uppercase; white-space: nowrap;' +
                    'transition: all .3s linear;'
                newIssueButton.addEventListener 'mouseover', () ->
                    @.style.backgroundColor = '#008AA8'
                    @.style.color = '#FFFFFF'
                newIssueButton.addEventListener 'mouseleave', () ->
                    @.style.backgroundColor = '#83EEDE'
                    @.style.color = '#2E3440'
                newIssueButton.addEventListener 'click', () ->
                    $rootScope.$broadcast 'genericform:new',
                        objType: 'issue',
                        project: project
                navInner = document.querySelector('tg-legacy-loader').shadowRoot.querySelector('.nav-inner')
                menu = navInner.querySelector('.main-menu')
                navInner.insertBefore(newIssueButton, menu.nextSibling)
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
