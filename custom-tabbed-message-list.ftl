<#--
Get Active Tab From URL query parameter
tab=unsolved
tab=unanswered
tab=advanced
default tab = all
-->
<#assign activeTab = http.request.parameters.name.get("tab", "all") />


<#--Tabbed Menu ->  ALL TOPICS | UNSOLVED | UNANSWERED | ADVANCED  -->
<div class="lia-tabs-standard-wrapper lia-component-tabs">
    <ul role="tablist" class="lia-tabs-standard">
        <#if activeTab == "all">
            <li class="lia-tabs lia-tabs-active">
        <#else>
            <li class="lia-tabs lia-tabs-inactive">
        </#if>
            <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}">All Topics</a></span>           
        </li>
        <#if activeTab == "unsolved">
            <li class="lia-tabs lia-tabs-active">
        <#else>
            <li class="lia-tabs lia-tabs-inactive">
        </#if>   
            <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=unsolved">Unsolved</a></span>
        </li>
        <#if activeTab == "unanswered">
            <li class="lia-tabs lia-tabs-active">
        <#else>
            <li class="lia-tabs lia-tabs-inactive">
        </#if>  
            <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=unanswered">Unanswered</a></span>
        </li>
        <#if activeTab == "advanced">
            <li class="lia-tabs lia-tabs-active">
        <#else>
            <li class="lia-tabs lia-tabs-inactive">
        </#if> 
            <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=advanced">Advanced</a></span>
        </li>
    </ul>
</div>
<#--END TABBED MENU-->


<#--All TOPICS TAB-->
<#--message-list added to page quilt with override component and paging added to quilt with custom paging component. Both only show if active tab is all topics-->
<#if activeTab == "all">
    <@component id="custom.thread-info-column-script"/>
    <@component id="custom.label.toggle"/>
</#if>
<#--END ALL TOPICS TAB-->


<#--UNSOLVED TAB-->
<#if activeTab == "unsolved">

    <style>
        .lia-list-wide {
            border-top: 0;
        }
    </style>

    <#--Pagination Part One-->
    <#assign boardId = coreNode.id />
    <#assign count = liql("SELECT count(*) FROM messages WHERE board.id = '${boardId}' AND depth = 0 AND conversation.solved = false").data.count />
    <#assign results_list_size = settings.name.get("layout.messages_per_page_linear")?number />
    <#assign page_number = webuisupport.path.rawParameters.name.get('page', '1')?number />
    <#assign offSet = results_list_size * (page_number - 1) />
    <#--End Pagination Part One-->

        <#assign unsolvedMessageCall = restBuilder()
            .method("POST")
            .path("/search")
            .body(
                [
                    {
                        "messages": {
                            "fields": [
                                "author.avatar.message",
                                "author.login",
                                "author.view_href",
                                "author.rank.name",
                                "author.rank.icon_right",
                                "author.rank.color",
                                "author.rank.bold",
                                "subject",
                                "post_time",
                                "post_time_friendly",
                                "view_href",
                                "replies.count(*)",
                                "metrics.views",
                                "user_context.read",
                                "replies"
                            ],
                            "constraints": [
                                {
                                    "board.id": "${boardId}",
                                    "depth":0,
                                    "conversation.solved": false
                                }
                            ],
                            "limit":results_list_size,
                            "offset":offSet,
                            "subQueries": {
                                "replies": {
                                    "fields": [
                                        "author.login",
                                        "author.view_href",
                                        "author.rank.name",
                                        "author.rank.icon_right",
                                        "author.rank.color",
                                        "author.rank.bold",
                                        "post_time"
                                    ],
                                    "limit": 1
                                }
                            }
                        }
                    }
                ]
            ) />

        <#assign resp = unsolvedMessageCall.call() />

        <div id="messageList" class="MessageList lia-component-forums-widget-message-list lia-forum-message-list lia-component-message-list">
            <span id="message-listmessageList"> </span>
            <div class="t-data-grid thread-list" id="grid">
                <table role="presentation" class="lia-list-wide">
                    <thead class="lia-table-head" id="columns">
                        <tr>
                            <th scope="col" class="cMessageAuthorAvatarColumn lia-data-cell-secondary lia-data-cell-text t-first">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="cThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="customThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="cRepliesCountColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="cViewsCountColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="triangletop lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                        </tr>
                    </thead>
                    <tbody>

                    <#list resp.data.items as message>
                        <#if message?counter == 1>
                            <tr class="lia-list-row lia-row-odd t-first">
                        <#else>
                            <tr class="lia-list-row lia-row-odd">
                        </#if>
                            <td class="cMessageAuthorAvatarColumn lia-data-cell-secondary lia-data-cell-icon">
                                <div class="UserAvatar lia-user-avatar lia-component-messages-column-message-author-avatar">
                                    <a class="UserAvatar lia-link-navigation" target="_self" href="${message.author.view_href!''}"><img class="lia-user-avatar-message" title="${message.author.login!''}" alt="${message.author.login!''}" src="${message.author.avatar.message!''}">
                                    </a>
                                </div>
                            </td>
                            <td class="cThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-messages-column-message-info">
                                    <div class="MessageSubjectCell">
                                        <div class="MessageSubject">
                                            <div class="MessageSubjectIcons ">
                                                <h2 itemprop="name" class="message-subject">
                                                    <#if message.user_context.read>
                                                        <span class="lia-message-read">
                                                    <#else>
                                                        <span class="lia-message-unread lia-message-unread-windows">
                                                    </#if>
                                                    <a class="page-link lia-link-navigation lia-custom-event" href="${message.view_href!''}">
                                                    ${message.subject!''}
                                                    </a>
                                                    </span>
                                                </h2>
                                            </div>
                                        </div>
                                    </div>
                                    <#if message.replies.count == 0>
                                        <div class="lia-info-area">
                                            <span class="lia-info-area-item">
                                            by <span class="UserName lia-user-name lia-component-common-widget-user-name">
                                            <#if message.author.rank.color??>
                                                <a class="lia-link-navigation lia-page-link lia-user-name-link" style="color:#${message.author.rank.color!''}" target="_self" aria-label="View Profile of ${message.author.login!''}" itemprop="url"  href="${message.author.view_href!''}">
                                                <#if message.author.rank.bold>
                                                <span class="login-bold">
                                                <#else>
                                                <span>
                                                </#if>
                                                ${message.author.login!''}</span></a>
                                            <#else>
                                                <a class="lia-link-navigation lia-page-link lia-user-name-link" target="_self" aria-label="View Profile of ${message.author.login!''}" itemprop="url"  href="${message.author.view_href!''}">
                                                <#if message.author.rank.bold>
                                                <span class="login-bold">
                                                <#else>
                                                <span>
                                                </#if>
                                                ${message.author.login!''}</span></a>
                                            </#if>
                                            <#if message.author.rank.icon_right??>
                                                <img class="lia-user-rank-icon lia-user-rank-icon-right" title="${message.author.rank.name!''}" alt="${message.author.rank.name!''}" src="${message.author.rank.icon_right!''}">
                                            </#if>
                                            </span> on <span class="DateTime lia-component-common-widget-date">
                                            <span class="local-date">${message.post_time?date?string!''}</span>
                                            <span class="local-time">${message.post_time?time?string.short!''}</span>
                                            </span>
                                            </span>
                                        </div>
                                    <#else>
                                        <div class="lia-info-area">
                                            <span class="lia-info-area-item">
                                            by <span class="UserName lia-user-name lia-component-common-widget-user-name">
                                            <#if message.author.rank.color??>
                                                <a class="lia-link-navigation lia-page-link lia-user-name-link" style="color:#${message.author.rank.color!''}" target="_self" aria-label="View Profile of ${message.author.login!''}" itemprop="url"  href="${message.author.view_href!''}">
                                                <#if message.author.rank.bold>
                                                <span class="login-bold">
                                                <#else>
                                                <span>
                                                </#if>
                                                ${message.author.login!''}</span></a>
                                            <#else>
                                                <a class="lia-link-navigation lia-page-link lia-user-name-link" target="_self" aria-label="View Profile of ${message.author.login!''}" itemprop="url"  href="${message.author.view_href!''}">
                                                <#if message.author.rank.bold>
                                                <span class="login-bold">
                                                <#else>
                                                <span>
                                                </#if>
                                                ${message.author.login!''}</span></a>
                                            </#if>
                                            <#if message.author.rank.icon_right??>
                                                <img class="lia-user-rank-icon lia-user-rank-icon-right" title="${message.author.rank.name!''}" alt="${message.author.rank.name!''}" src="${message.author.rank.icon_right!''}">
                                            </#if>
                                            </span> on <span class="DateTime lia-component-common-widget-date">
                                            <span class="local-date">${message.post_time?date?string!''}</span>
                                            <span class="local-time">${message.post_time?time?string.short!''}</span>
                                            </span>
                                            </span>
                                            <span class="lia-dot-separator"></span>
                                            <span cssclass="lia-info-area-item" class="lia-info-area-item">
                                            Latest post on <span class="DateTime lia-component-common-widget-date">
                                            <span class="local-date">${message.replies.items[0].post_time?date?string!''}</span>
                                            <span class="local-time">${message.replies.items[0].post_time?time?string.short!''}</span>
                                            </span> by <span class="UserName lia-user-name lia-component-common-widget-user-name">
                                            <#if message.replies.items[0].author.rank.color??>
                                                <a class="lia-link-navigation lia-page-link lia-user-name-link" style="color:#${message.replies.items[0].author.rank.color!''}" target="_self" aria-label="View Profile of ${message.replies.items[0].author.login!''}" itemprop="url" href="${message.replies.items[0].author.view_href!''}">
                                                <#if message.replies.items[0].author.rank.bold>
                                                <span class="login-bold">
                                                <#else>
                                                <span>
                                                </#if>
                                                ${message.replies.items[0].author.login!''}</span></a>
                                            <#else>
                                                <a class="lia-link-navigation lia-page-link lia-user-name-link" target="_self" aria-label="View Profile of ${message.replies.items[0].author.login!''}" itemprop="url" href="${message.replies.items[0].author.view_href!''}">
                                                <#if message.replies.items[0].author.rank.bold>
                                                <span class="login-bold">
                                                <#else>
                                                <span>
                                                </#if>
                                                ${message.replies.items[0].author.login!''}</span></a>
                                            </#if>
                                            <#if message.replies.items[0].author.rank.icon_right??>
                                                <img class="lia-user-rank-icon lia-user-rank-icon-right" title="${message.replies.items[0].author.rank.name!''}" alt="${message.replies.items[0].author.rank.name!''}" src="${message.replies.items[0].author.rank.icon_right!''}">
                                            </#if>
                                            </span>
                                            </span>
                                        </div>
                                    </#if>
                                    <div class="lia-stats-area">
                                        <span class="lia-stats-area-item">
                                        <span class="lia-message-stats-count">${message.replies.count!''}</span><span class="lia-message-stats-label"> Replies</span>
                                        </span>
                                        <span class="lia-dot-separator"></span>
                                        <span class="lia-stats-area-item">
                                        <span class="lia-message-stats-count">${message.metrics.views!''}</span>
                                        <span class="lia-message-stats-label">
                                        Views
                                        </span>
                                        </span>
                                    </div>
                                </div>
                            </td>
                            <td class="customThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="custom-thread-info-column hide">
                                    <div class="content"></div>
                                    <div class="tooltip-bg"></div>
                                </div>
                            </td>
                            <td class="cRepliesCountColumn lia-data-cell-secondary lia-data-cell-integer">
                                <div class="lia-component-messages-column-message-replies-count">
                                    <span class="lia-message-stats-count">${message.replies.count!''}</span> Replies
                                </div>
                            </td>
                            <td class="cViewsCountColumn lia-data-cell-secondary lia-data-cell-integer">
                                <div class="lia-component-messages-column-message-views-count">
                                    <span class="lia-message-stats-count">${message.metrics.views!''}</span>
                                    Views
                                </div>
                            </td>
                            <td class="triangletop lia-data-cell-secondary lia-data-cell-icon">
                                <div class="lia-component-common-column-empty-cell" role="img" aria-label="unsolved"></div>
                            </td>
                        </tr>
                    </#list>

                    </tbody>
                </table>
            </div>
        </div>

    <#--Pagination Part Two-->
        <#assign pageable_item = webuisupport.paging.pageableItem.setCurrentPageNumber(page_number)
        .setItemsPerPage(results_list_size).setTotalItems(count)
        .setPagingMode("enumerated").build />
        <@component id="common.widget.pager" pageableItem=pageable_item />
    <#--End Pagination Part Two-->
</#if>            
<#--END UNSOLVED TAB-->


<#--UNANSWERED TAB-->
<#if activeTab == "unanswered">

    <style>
        .lia-list-wide {
            border-top: 0;
        }
    </style>

    <#--Pagination Part One-->
    <#assign boardId = coreNode.id />
    <#assign count = liql("SELECT count(*) FROM messages WHERE board.id = '${boardId}' AND depth = 0 AND replies.count(*) = 0").data.count />
    <#assign results_list_size = settings.name.get("layout.messages_per_page_linear")?number />
    <#assign page_number = webuisupport.path.rawParameters.name.get('page', '1')?number />
    <#assign offSet = results_list_size * (page_number - 1) />
    <#--End Pagination Part One-->

        <#assign unansweredMessageCall = restBuilder()
            .method("POST")
            .path("/search")
            .body(
                [
                    {
                        "messages": {
                            "fields": [
                                "author.avatar.message",
                                "author.login",
                                "author.view_href",
                                "author.rank.name",
                                "author.rank.icon_right",
                                "author.rank.color",
                                "author.rank.bold",
                                "subject",
                                "post_time",
                                "post_time_friendly",
                                "view_href",
                                "replies.count(*)",
                                "metrics.views",
                                "user_context.read"
                            ],
                            "constraints": [
                                {
                                    "board.id": "${boardId}",
                                    "depth":0,
                                    "replies.count(*)":0
                                }
                            ],
                            "limit":results_list_size,
                            "offset":offSet
                        }
                    }
                ]
            ) />

        <#assign resp = unansweredMessageCall.call() />

        <div id="messageList" class="MessageList lia-component-forums-widget-message-list lia-forum-message-list lia-component-message-list">
            <span id="message-listmessageList"> </span>
            <div class="t-data-grid thread-list" id="grid">
                <table role="presentation" class="lia-list-wide">
                    <thead class="lia-table-head" id="columns">
                        <tr>
                            <th scope="col" class="cMessageAuthorAvatarColumn lia-data-cell-secondary lia-data-cell-text t-first">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="cThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="customThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="cRepliesCountColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="cViewsCountColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                            <th scope="col" class="triangletop lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-common-column-empty-cell"></div>
                            </th>
                        </tr>
                    </thead>
                    <tbody>

                    <#list resp.data.items as message>
                        <#if message?counter == 1>
                            <tr class="lia-list-row lia-row-odd t-first">
                        <#else>
                            <tr class="lia-list-row lia-row-odd">
                        </#if>
                            <td class="cMessageAuthorAvatarColumn lia-data-cell-secondary lia-data-cell-icon">
                                <div class="UserAvatar lia-user-avatar lia-component-messages-column-message-author-avatar">
                                    <a class="UserAvatar lia-link-navigation" target="_self" href="${message.author.view_href!''}"><img class="lia-user-avatar-message" title="${message.author.login!''}" alt="${message.author.login!''}" src="${message.author.avatar.message!''}">
                                    </a>
                                </div>
                            </td>
                            <td class="cThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="lia-component-messages-column-message-info">
                                    <div class="MessageSubjectCell">
                                        <div class="MessageSubject">
                                            <div class="MessageSubjectIcons ">
                                                <h2 itemprop="name" class="message-subject">
                                                    <#if message.user_context.read>
                                                        <span class="lia-message-read">
                                                    <#else>
                                                        <span class="lia-message-unread lia-message-unread-windows">
                                                    </#if>
                                                    <a class="page-link lia-link-navigation lia-custom-event" href="${message.view_href!''}">
                                                    ${message.subject!''}
                                                    </a>
                                                    </span>
                                                </h2>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="lia-info-area">
                                        <span class="lia-info-area-item">
                                        by <span class="UserName lia-user-name lia-component-common-widget-user-name">
                                        <#if message.author.rank.color??>
                                            <a class="lia-link-navigation lia-page-link lia-user-name-link" style="color:#${message.author.rank.color!''}" target="_self" aria-label="View Profile of ${message.author.login!''}" itemprop="url"  href="${message.author.view_href!''}">
                                            <#if message.author.rank.bold>
                                            <span class="login-bold">
                                            <#else>
                                            <span>
                                            </#if>
                                            ${message.author.login!''}</span></a>
                                        <#else>
                                            <a class="lia-link-navigation lia-page-link lia-user-name-link" target="_self" aria-label="View Profile of ${message.author.login!''}" itemprop="url"  href="${message.author.view_href!''}">
                                            <#if message.author.rank.bold>
                                            <span class="login-bold">
                                            <#else>
                                            <span>
                                            </#if>
                                            ${message.author.login!''}</span></a>
                                        </#if>
                                        <#if message.author.rank.icon_right??>
                                            <img class="lia-user-rank-icon lia-user-rank-icon-right" title="${message.author.rank.name!''}" alt="${message.author.rank.name!''}" src="${message.author.rank.icon_right!''}">
                                        </#if>
                                        </span> on <span class="DateTime lia-component-common-widget-date">
                                        <span class="local-date">${message.post_time?date?string!''}</span>
                                        <span class="local-time">${message.post_time?time?string.short!''}</span>
                                        </span>
                                        </span>
                                    </div>
                                    <div class="lia-stats-area">
                                        <span class="lia-stats-area-item">
                                        <span class="lia-message-stats-count">${message.replies.count!''}</span><span class="lia-message-stats-label"> Replies</span>
                                        </span>
                                        <span class="lia-dot-separator"></span>
                                        <span class="lia-stats-area-item">
                                        <span class="lia-message-stats-count">${message.metrics.views!''}</span>
                                        <span class="lia-message-stats-label">
                                        Views
                                        </span>
                                        </span>
                                    </div>
                                </div>
                            </td>
                            <td class="customThreadInfoColumn lia-data-cell-secondary lia-data-cell-text">
                                <div class="custom-thread-info-column hide">
                                    <div class="content"></div>
                                    <div class="tooltip-bg"></div>
                                </div>
                            </td>
                            <td class="cRepliesCountColumn lia-data-cell-secondary lia-data-cell-integer">
                                <div class="lia-component-messages-column-message-replies-count">
                                    <span class="lia-message-stats-count">${message.replies.count!''}</span> Replies
                                </div>
                            </td>
                            <td class="cViewsCountColumn lia-data-cell-secondary lia-data-cell-integer">
                                <div class="lia-component-messages-column-message-views-count">
                                    <span class="lia-message-stats-count">${message.metrics.views!''}</span>
                                    Views
                                </div>
                            </td>
                            <td class="triangletop lia-data-cell-secondary lia-data-cell-icon">
                                <div class="lia-component-common-column-empty-cell" role="img" aria-label="unsolved"></div>
                            </td>
                        </tr>
                    </#list>

                    </tbody>
                </table>
            </div>
        </div>

    <#--Pagination Part Two-->
        <#assign pageable_item = webuisupport.paging.pageableItem.setCurrentPageNumber(page_number)
        .setItemsPerPage(results_list_size).setTotalItems(count)
        .setPagingMode("enumerated").build />
        <@component id="common.widget.pager" pageableItem=pageable_item />
    <#--End Pagination Part Two-->
</#if>            
<#--END UNANSWERED TAB-->