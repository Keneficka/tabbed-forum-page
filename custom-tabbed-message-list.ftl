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


<#if activeTab == "all">
    <@component id="custom.label.toggle"/>
</#if>
