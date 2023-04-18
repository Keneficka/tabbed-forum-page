<#assign userRoles = (restBuilder().admin(true).liql("SELECT name FROM roles WHERE users.id = '${user.id?c}' LIMIT 100").data.items)![]/>
<#assign admin = "false">
<#assign rankTabs = "false">
<#list userRoles as role>
    <#if (role.name == "Champion" || role.name == "Administrator")>
        <#assign admin = "true" />
    </#if>
    <#if (role.name == "Rank Tab Access")>
        <#assign rankTabs = "true" />
    </#if>
</#list>

<#--
Get Active Tab From URL query parameter
tab=solved
tab=unsolved
tab=unanswered
tab=advanced
default tab = all
-->
<#assign activeTab = http.request.parameters.name.get("tab", "all") />


<#--Tabbed Menu ->  ALL TOPICS | SOLVED | UNSOLVED | UNANSWERED | ADVANCED  -->
<div class="lia-tabs-standard-wrapper lia-component-tabs">
    <ul role="tablist" class="lia-tabs-standard">
        <#if activeTab == "all">
            <li class="lia-tabs lia-tabs-active">
        <#else>
            <li class="lia-tabs lia-tabs-inactive">
        </#if>
            <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}" id="all-topics-link-ak">All Topics</a></span>           
        </li>
        <#if activeTab == "solved">
            <li class="lia-tabs lia-tabs-active">
        <#else>
            <li class="lia-tabs lia-tabs-inactive">
        </#if>   
            <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=solved" id="solved-link-ak">Solved</a></span>
        </li>

        <#if admin == "true" || rankTabs = "true" >
            <#if activeTab == "unsolved">
                <li class="lia-tabs lia-tabs-active">
            <#else>
                <li class="lia-tabs lia-tabs-inactive">
            </#if>   
                <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=unsolved" id="unsolved-link-ak">Unsolved</a></span>
            </li>
            <#if activeTab == "unanswered">
                <li class="lia-tabs lia-tabs-active">
            <#else>
                <li class="lia-tabs lia-tabs-inactive">
            </#if>  
                <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=unanswered" id="unanswered-link-ak">Unanswered</a></span>
            </li>
        </#if>

        <#if admin == "true" >
            <#if activeTab == "advanced">
                <li class="lia-tabs lia-tabs-active" id="adv-tab-ak">
            <#else>
                <li class="lia-tabs lia-tabs-inactive" id="adv-tab-ak">
            </#if> 
                <span><a class="lia-link-navigation tab-link" href="${coreNode.webUi.url}?tab=advanced" id="advanced-link-ak">Advanced</a></span>
            </li>
        </#if>
    </ul>
</div>

<style>
    @media screen and (max-width: 540px) {
        #adv-tab-ak {
            display: none;
        }
    }
</style>
<#--END TABBED MENU-->


<#--All TOPICS TAB-->
<#--message-list added to page quilt with override component and paging added to quilt with custom paging component. Both only show if active tab is all topics-->
<#if activeTab == "all">
    <@component id="custom.thread-info-column-script"/>
    <@component id="custom.label.toggle"/>
</#if>
<#--END ALL TOPICS TAB-->


<#--SOLVED TAB-->
<#if activeTab == "solved">

    <style>
        .lia-list-wide {
            border-top: 0;
        }
    </style>

    <#--Pagination Part One-->
    <#assign boardId = coreNode.id />
    <#assign count = liql("SELECT count(*) FROM messages WHERE board.id = '${boardId}' AND depth = 0 AND conversation.solved = true").data.count />
    <#assign results_list_size = settings.name.get("layout.messages_per_page_linear")?number />
    <#assign page_number = webuisupport.path.rawParameters.name.get('page', '1')?number />
    <#assign offSet = results_list_size * (page_number - 1) />
    <#--End Pagination Part One-->

        <#assign solvedMessageCall = restBuilder()
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
                                    "conversation.solved": true
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

        <#assign resp = solvedMessageCall.call() />

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
                            <tr class="lia-list-row lia-row-odd t-first lia-list-row-thread-solved">
                        <#else>
                            <tr class="lia-list-row lia-row-odd lia-list-row-thread-solved">
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
                                    <div class="lia-component-common-column-empty-cell" role="img"></div>
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
<#--END SOLVED TAB-->

<#--UNSOLVED TAB-->
<#if activeTab == "unsolved">

    <style>
        .lia-list-wide {
            border-top: 0;
        }
    </style>

    <#--Pagination Part One-->
    <#assign boardId = coreNode.id />
    <#assign count = liql("SELECT count(*) FROM messages WHERE board.id = '${boardId}' AND depth = 0 AND conversation.solved = false AND replies.count(*) > 0").data.count />
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
                                    "conversation.solved": false,
                                    "replies.count(*)": {
                                        ">":0
                                    }
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


<#--ADVANCED TAB-->
<#if activeTab == "advanced">
    <style>
        div#advanced-options-container {
            display: flex;
            flex-wrap: wrap;
            padding-bottom: 3px;
            margin-bottom: 10px;
            justify-content: space-between;
            border-bottom: solid 1px #c4c4c4;
        }

        div#advanced-options-left {
            white-space: nowrap;
        }

        div#advanced-options-right {
            white-space: nowrap;
        }

        button#filter-button-ak {
            padding-top: 0;
            padding-bottom: 0;
            margin-top: -5px;
        }

        label.label-chkbox-label {
            font-size: 14px;
            padding: 0 5px;
            border-radius: 5px;
            font-weight: 400;
        }

        #advanced-label-ul {
            display: flex;
            flex-wrap: wrap;
            margin-bottom: 0;
        }

        li.advanced-label-li {
            width: 18%;
            margin-right: 2%;
        }

        .label-chkbox-label {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .advanced-label-li [type=checkbox]:checked + label {
            /*outline: 3px solid red;*/
            background-color: #e8e8e8;
            outline: 1px lightgrey solid;
        }

        .advanced-label-li [type=checkbox] + label {
            cursor: pointer;
        }

        input.AKLabelCheckBox {
            display: none;
        }

        div#advanced-filter-menu {
            border-bottom: 1px solid #c4c4c4;
            padding-left: 13px;
            padding-right: 13px;
        }
    </style>

    <#--Get selected advanced filtering options and labels from url params-->
    <#assign labelList = http.request.parameters.name.get("label_list", "") />
    <#assign labelOption = http.request.parameters.name.get("label_option", "") />
    <#assign unsolvedAdv = http.request.parameters.name.get("unsolved", "") />
    <#assign unansweredAdv = http.request.parameters.name.get("unanswered", "") />


    <#--Create Constraints for API Calls-->
    <#assign constraints = '"board.id": "${coreNode.id}","depth":0' />
    <#if labelOption?has_content>

        <#if unsolvedAdv == "true" && unansweredAdv == "true" >
            <#assign constraints+= ',"conversation.solved": false' />
        <#elseif unsolvedAdv == "true">
            <#assign constraints+= ',"conversation.solved": false,"replies.count(*)":{">":0}' />
        <#elseif unansweredAdv == "true">
            <#assign constraints+= ',"replies.count(*)":0' />
        </#if>

        <#if labelList?has_content>
            <#list labelList?split(",") as lab>
                <#if lab?counter == 1>
                    <#assign formattedLabels = '"${lab}"' />
                <#else>
                    <#assign formattedLabels+= ',"${lab}"' />
                </#if>
            </#list>

            <#if labelOption == "any">
                <#assign constraints+= ',"labels.text":{"in":[${formattedLabels}]}' />
            <#else>
                <#list labelList?split(",") as lab>
                    <#if lab?counter == 1>
                        <#assign constraints+= ',"labels.text":"${lab}"' />
                    <#else>
                        <#assign constraints+= '},{"labels.text":"${lab}","depth":0' />
                    </#if>
                </#list>
            </#if>
        </#if>

    </#if>
    <#assign constraints = "[{" + constraints + "}]" />
    <#assign constraints = constraints?eval />
    <#--END Create Constraints for API Calls-->


    <#--Pagination Part One-->
    <#assign boardId = coreNode.id />
    <#--Fix this<#assign count = liql("SELECT count(*) FROM messages WHERE board.id = '${boardId}' AND depth = 0 AND conversation.solved = false").data.count />Fix this-->
    <#--Get Count Based On Constraints From Above-->
    <#assign countMessageCall = restBuilder()
    .method("POST")
    .path("/search")
    .body(
        [
            {
                "messages": {
                    "fields": [
                        "count(*)"
                    ],
                    "constraints": constraints
                }
            }
        ]
    ) />

    <#assign count = countMessageCall.call().data.count />

    <#assign results_list_size = settings.name.get("layout.messages_per_page_linear")?number />
    <#assign page_number = webuisupport.path.rawParameters.name.get('page', '1')?number />
    <#assign offSet = results_list_size * (page_number - 1) />
    <#--End Pagination Part One-->


    <#--ADVANCED FILTER MENU-->
    <div class="advanced-filter-menu" id="advanced-filter-menu">

        <div id="advanced-options-container">
            <div id="advanced-options-left">
                Return topics with:&nbsp;
                <#if labelOption == "all">
                    <input type="radio" id="any-label" name="any-or-all" value="any">
                    <label for="any-label">any</label> / 
                    <input type="radio" id="all-labels" name="any-or-all" value="all" checked>
                    <label for="all-labels">all</label> of the selected labels. &nbsp; 	&nbsp;
                <#else>
                    <input type="radio" id="any-label" name="any-or-all" value="any" checked>
                    <label for="any-label">any</label> / 
                    <input type="radio" id="all-labels" name="any-or-all" value="all">
                    <label for="all-labels">all</label> of the selected labels.
                </#if>
            </div>
            <div id="advanced-options-right">
                Additional Options:&nbsp;
                <#if unsolvedAdv == "true" >
                    <input type="checkbox" value="unsolved" id="unsolved-option" class="options-checkbox" checked>
                <#else>
                    <input type="checkbox" value="unsolved" id="unsolved-option" class="options-checkbox">
                </#if>
                <label class="options-chkbox-label" for="unsolved-option">Unsolved&nbsp;</label>
                <#if unansweredAdv == "true" >
                    <input type="checkbox" value="unanswered" id="unanswered-option" class="options-checkbox" checked>
                <#else>
                    <input type="checkbox" value="unanswered" id="unanswered-option" class="options-checkbox">
                </#if>
                <label class="options-chkbox-label" for="unanswered-option">Unanswered</label> &nbsp; &nbsp;
                <button class="lia-button lia-button-primary" id="filter-button-ak">Go</button>
            </div>
        </div>

        <div class="advanced-filter-labels">
            <#--Get Available Labels For Board-->
            <#assign availableLabels = rest("/boards/id/${coreNode.id}/labels/predefined").labels.label/>
            <ul id="advanced-label-ul">
                <#list availableLabels as label>
                    <li class="advanced-label-li">
                        <#if labelList?split(",")?seq_contains("${label.text}") >
                            <input type="checkbox" value="${label.text}" id="${label.text}" class="AKLabelCheckBox" checked>
                        <#else>
                            <input type="checkbox" value="${label.text}" id="${label.text}" class="AKLabelCheckBox">
                        </#if>
                        <label class="label-chkbox-label" for="${label.text}">${label.text}</label>
                    </li>
                </#list>
            </ul>
        </div>
    </div>
    <#--END ADVANCED FILTER MENU-->


    <#if count gt 0>
        <#assign advancedMessageCall = restBuilder()
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
                                "replies",
                                "conversation.solved"
                            ],
                            "constraints":constraints,
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

        <#assign resp = advancedMessageCall.call() />

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
                                <#if message.conversation.solved>
                                    <tr class="lia-list-row lia-row-odd t-first lia-list-row-thread-solved">
                                <#else>
                                    <tr class="lia-list-row lia-row-odd t-first">
                                </#if>
                            <#else>
                                <#if message.conversation.solved>
                                    <tr class="lia-list-row lia-row-odd lia-list-row-thread-solved">
                                <#else>
                                    <tr class="lia-list-row lia-row-odd">
                                </#if>
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
                                    <div class="lia-component-common-column-empty-cell" role="img"></div>
                                </td>
                            </tr>
                        </#list>

                        </tbody>
                    </table>
                </div>
            </div>
    <#else>
    <div align="center" style="margin-top: 20px;font-size: 16px;"><strong>Your Filters Returned No Results</strong></div>      
    </#if>

    <#--Pagination Part Two-->
        <#assign pageable_item = webuisupport.paging.pageableItem.setCurrentPageNumber(page_number)
        .setItemsPerPage(results_list_size).setTotalItems(count)
        .setPagingMode("enumerated").build />
        <@component id="common.widget.pager" pageableItem=pageable_item />
    <#--End Pagination Part Two-->

    <#--Script to get advanced filter selections and add as URL parameters-->
    <@liaAddScript>
    ;(function($) {
        console.log('add script worked');
        //Global Variables
        var labelOption;
        var labelList = [];
        var unsolved = "false";
        var unanswered = "false";
        var advURL;

        document.getElementById("filter-button-ak").addEventListener("click", advancedFilter);

        function advancedFilter() {
            console.log('button clicked');

            //get all selections
            var labelOptionCheck = document.getElementById('any-label');
            if(labelOptionCheck.checked) {
                labelOption = "any";
            } else {
                labelOption = "all";
            }

            var labelListCheck = document.getElementsByClassName('AKLabelCheckBox');
            for(var i = 0; i < labelListCheck.length; i++) {
                if(labelListCheck[i].checked) {
                    labelList.push(labelListCheck[i].value);
                }
            }

            if(document.getElementById('unsolved-option').checked) {
                unsolved = "true";
            }

            if(document.getElementById('unanswered-option').checked) {
                unanswered = "true";
            }


            //Create URL and navigate to URL
            advURL = location.origin + location.pathname;
            var pageIndex = advURL.indexOf("page");
            console.log(pageIndex);
            if (pageIndex > 0) {
                advURL = advURL.slice(0, (pageIndex - 1));
                console.log(advURL);
            }
            advURL = advURL + '?tab=advanced';
            advURL = advURL + "&label_option=" + labelOption + "&label_list=" + encodeURIComponent(labelList.toString()) + "&unsolved=" + unsolved + "&unanswered=" + unanswered;
            window.location.replace(advURL);

        }

    })(LITHIUM.jQuery);
    </@liaAddScript>

</#if>
<#--END ADVANCED TAB-->

<#--GOOGLE TRACKING-->
<@liaAddScript>
    ;(function($) {
        
        document.getElementById("all-topics-link-ak").addEventListener("click", function (){
            console.log('all_tab_click')
            gtag('event', 'all_tab_click');
        });

        document.getElementById("solved-link-ak").addEventListener("click", function (){
            console.log('solved_tab_click')
            gtag('event', 'solved_tab_click');
        });

        document.getElementById("unsolved-link-ak").addEventListener("click", function (){
            console.log('unsolved_tab_click')
            gtag('event', 'unsolved_tab_click');
        });

        document.getElementById("unanswered-link-ak").addEventListener("click", function (){
            console.log('unanswered_tab_click')
            gtag('event', 'unanswered_tab_click');
        });

        document.getElementById("advanced-link-ak").addEventListener("click", function (){
            console.log('advanced_tab_click')
            gtag('event', 'advanced_tab_click');
        });

        
    })(LITHIUM.jQuery);
    </@liaAddScript>
<#--END GOOGLE TRACKING-->