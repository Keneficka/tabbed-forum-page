<#assign activeTab = http.request.parameters.name.get("tab", "all") />

<#if activeTab == "all">
    <@component id="paging"/>
</#if>