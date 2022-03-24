<#include "/WEB-INF/pages/inc/header.ftl">
<title><@s.text name="admin.home.manageLogs"/></title>
<#assign currentMenu = "admin"/>
<script>
    $(document).ready(function(){
        $.get("${baseURL}/admin/logfile.do", {log:"admin"}, function(data){
            $("#logs").text(data);
        });
    });
</script>
<#include "/WEB-INF/pages/inc/menu.ftl">

<main class="container">
    <div class="my-3 p-3 border rounded shadow-sm">
        <#include "/WEB-INF/pages/inc/action_alerts.ftl">

        <h5 class="border-bottom pb-2 mb-2 mx-md-4 mx-2 pt-2 text-gbif-header fw-400 text-center">
            <@s.text name="admin.home.manageLogs"/>
        </h5>

        <p class="mx-md-4 mx-2">
            <strong><@s.text name="admin.logs.warn"/></strong>
        </p>
        <p class="mx-md-4 mx-2">
            <@s.text name="admin.logs.download"><@s.param>logfile.do?log=debug</@s.param></@s.text>
        </p>

        <pre id="logs" class="mx-md-4 mx-2"></pre>
    </div>
</main>

<#include "/WEB-INF/pages/inc/footer.ftl">
