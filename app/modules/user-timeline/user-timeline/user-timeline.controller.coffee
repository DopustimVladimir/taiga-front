###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

mixOf = @.taiga.mixOf

class UserTimelineController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "tgUserTimelineService"
    ]

    constructor: (@userTimelineService) ->
        @.timelineList = Immutable.List()
        @.scrollDisabled = false

        @.timeline = null
        @.filterValue = null

        if @.projectId
            @.timeline = @userTimelineService.getProjectTimeline(@.projectId)
        else if @.currentUser
            @.timeline = @userTimelineService.getProfileTimeline(@.user.get("id"))
        else
            @.timeline = @userTimelineService.getUserTimeline(@.user.get("id"))

        @.loadTimeline()

    loadTimeline: () ->
        @.scrollDisabled = true

        return @.timeline
            .next()
            .then (response) =>
                @.timelineList = @.timelineList.concat(response.get("items"))
                if not @.filterValue
                    @.timelineListVisible = @.timelineList
                else
                    @.filterTimelineList(@.filterValue)

                if response.get("next")
                    @.scrollDisabled = false

                return @.timelineList

    filterTimelineList: (filterValue) ->

        if not filterValue
            @.timelineListVisible = @.timelineList
        else
            @.timelineListVisible = @.timelineList.filter (it) ->

                if filterValue.match(/\#\d+/)
                    value = parseInt(filterValue.slice(1))
                    if it.getIn([ 'data', 'userstory' ])
                        matchedUserstoryRef =
                            it.getIn([ 'data', 'userstory', 'ref' ]) is value
                    if it.getIn([ 'data', 'task' ])
                        matchedTaskRef =
                            it.getIn([ 'data', 'task', 'ref' ]) is value
                    if it.getIn([ 'data', 'issue' ])
                        matchedIssueRef =
                            it.getIn([ 'data', 'issue', 'ref' ]) is value
                else
                    value = filterValue
                    if it.getIn([ 'data', 'userstory' ])
                        matchedUserstorySubject =
                            it.getIn([ 'data', 'userstory', 'subject' ]).includes(value)
                    if it.getIn([ 'data', 'task' ])
                        matchTaskSubject =
                            it.getIn([ 'data', 'task', 'subject' ]).includes(value)
                    if it.getIn([ 'data', 'issue' ])
                        matchIssueSubject =
                            it.getIn([ 'data', 'issue', 'subject' ]).includes(value)

                return matchedUserstoryRef or matchedTaskRef or matchedIssueRef or
                    matchedUserstorySubject or matchTaskSubject or matchIssueSubject or false

        @.filterValue = filterValue

angular.module("taigaUserTimeline")
    .controller("UserTimeline", UserTimelineController)
