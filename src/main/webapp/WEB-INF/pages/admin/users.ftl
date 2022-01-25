<#escape x as x?html>
    <#include "/WEB-INF/pages/inc/header.ftl">
    <title><@s.text name="admin.home.manageUsers"/></title>
    <script>

        $(document).ready(function(){
            //Hack needed for Internet Explorer
            $('#create').click(function() {
                window.location='user.do';
            });
            $('#cancel').click(function() {
                window.location='home.do';
            });
        });
    </script>
    <#assign currentMenu = "admin"/>
    <#include "/WEB-INF/pages/inc/menu.ftl">
    <#include "/WEB-INF/pages/macros/usersTable.ftl"/>
    <script src="${baseURL}/js/jquery/jquery-3.5.1.min.js"></script>
    <script src="${baseURL}/js/jquery/jquery.dataTables-1.10.23.min.js"></script>
    <script src="${baseURL}/js/jquery/dataTables.bootstrap5-1.10.23.min.js"></script>

    <main class="container">
        <div class="my-3 p-3 bg-body rounded shadow-sm">
            <#include "/WEB-INF/pages/inc/action_alerts.ftl">

            <h5 class="border-bottom pb-2 mb-2 mx-md-4 mx-2 pt-2 text-gbif-header fw-400 text-center">
                <@s.text name="admin.home.manageUsers"/>
            </h5>

            <@usersTable numUsersShown=20 sEmptyTable="dataTables.sEmptyTable.users" columnToSortOn=0 sortOrder="asc" />
            <div id="tableContainer" class="table-responsive text-smaller mx-md-4 mx-2 pt-2"></div>

            <div class="mx-md-4 mx-2 mt-2">
                <button id="create" class="btn btn-outline-gbif-primary"><@s.text name="button.create"/></button>
                <button id="cancel" class="btn btn-outline-secondary"><@s.text name="button.cancel"/></button>
            </div>

        </div>
    </main>

    <#include "/WEB-INF/pages/inc/footer.ftl">

</#escape>
