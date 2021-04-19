<#escape x as x?html>
    <#setting number_format="#####.##">
    <#include "/WEB-INF/pages/inc/header.ftl">
    <title><@s.text name='manage.metadata.citations.title'/></title>
    <script type="text/javascript">
        $(document).ready(function(){
            window.onLoad = populateCitationWithAutoGeneratedCitation();
            initHelp();

            function populateCitationWithAutoGeneratedCitation() {
                var isAutoGenerated = ${resource.isCitationAutoGenerated()?c};
                if (isAutoGenerated) {
                    // auto-generated citation string
                    var autoCitation = "${action.resource.generateResourceCitation(resource.getNextVersion()?string, cfg.getResourceVersionUri(resource.getShortname(), resource.getNextVersion().toPlainString()?string))!}";
                    $("#eml\\.citation\\.citation").val(autoCitation);
                    $('#cit').attr("value", "true");
                    $("#generateOff").show();
                    $("#generateOn").hide();
                }
            }

            $("#generateOn").click(function(event) {
                event.preventDefault();
                // auto-generated citation string
                var autoCitation = "${action.resource.generateResourceCitation(resource.getNextVersion()?string, cfg.getResourceVersionUri(resource.getShortname(), resource.getNextVersion().toPlainString()?string))!}";
                $("#eml\\.citation\\.citation").val(autoCitation);
                $('#cit').attr("value", "true");
                $("#generateOff").show();
                $("#generateOn").hide();
            });
            $("#generateOff").click(function(event) {
                event.preventDefault();
                $("#eml\\.citation\\.citation").val("")
                $('#cit').attr("value", "false");
                $("#generateOn").show();
                $("#generateOff").hide();
            });
        });
    </script>
    <#include "/WEB-INF/pages/macros/metadata.ftl"/>
    <#assign auxTopNavbar=true />
    <#assign auxTopNavbarPage = "metadata" />
    <#assign currentMenu="manage"/>
    <#include "/WEB-INF/pages/inc/menu.ftl">
    <#include "/WEB-INF/pages/macros/forms.ftl"/>

    <main class="container">
        <div class="row g-3">
            <div class="p-3 bg-body rounded shadow-sm">

                <#include "/WEB-INF/pages/inc/action_alerts.ftl">

                <h5 class="border-bottom pb-2 mb-2 mx-md-4 mx-2 pt-2 text-gbif-header text-center">
                    <@s.text name='manage.metadata.citations.title'/>:
                    <a href="resource.do?r=${resource.shortname}" title="${resource.title!resource.shortname}">${resource.title!resource.shortname}</a>
                </h5>

                <p class="mx-md-4 mx-2 mb-0">
                    <@s.text name='manage.metadata.citations.intro'/>
                </p>

                <p class="mx-md-4 mx-2 mb-0">
                    <strong><@s.text name='manage.metadata.citations.warning'/></strong>
                </p>

                <!-- retrieve some link names one time -->
                <#assign removeLink><@s.text name='manage.metadata.removethis'/> <@s.text name='manage.metadata.citations.item'/></#assign>
                <#assign addLink><@s.text name='manage.metadata.addnew'/> <@s.text name='manage.metadata.citations.item'/></#assign>

                <div class="row g-3 mx-md-3 mx-1">
                    <div class="mt-3 d-flex justify-content-end">
                        <a id="generateOff" class="removeLink" <#if resource.citationAutoGenerated?c != "true">style="display: none"</#if> href="">[ <@s.text name='eml.citation.generate.turn.off'/> ]</a>
                        <a id="generateOn" class="removeLink" <#if resource.citationAutoGenerated?c == "true">style="display: none"</#if> href="">[ <@s.text name='eml.citation.generate.turn.on'/> ]</a>
                        <input id="cit" name="resource.citationAutoGenerated" type=hidden value="${resource.citationAutoGenerated?c}"/>
                    </div>
                    <@text name="eml.citation.citation" help="i18n" requiredField=true />
                    <#if resource.doi?? && doiReservedOrAssigned>
                        <@input name="eml.citation.identifier" help="i18n" disabled=true value="${resource.doi.getUrl()!}"/>
                    <#else>
                        <@input name="eml.citation.identifier" help="i18n"/>
                    </#if>
                </div>

            </div>
        </div>

        <div class="row g-3 mt-1">
            <div class="col-lg-12 p-3 bg-body rounded shadow-sm">
                <div class="listBlock">
                    <@textinline name="manage.metadata.citations.bibliography" help="i18n"/>
                    <div id="items">
                        <#list eml.bibliographicCitationSet.bibliographicCitations as item>
                            <div id="item-${item_index}" class="item row g-3 mx-md-3 mx-1 border-bottom pb-3 mt-1">
                                <div class="mt-1 d-flex justify-content-end">
                                    <a id="removeLink-${item_index}" class="removeLink" href="">[ ${removeLink?lower_case?cap_first} ]</a>
                                </div>
                                <@text name="eml.bibliographicCitationSet.bibliographicCitations[${item_index}].citation" help="i18n" i18nkey="eml.bibliographicCitationSet.bibliographicCitations.citation" size=40 requiredField=true />
                                <@input name="eml.bibliographicCitationSet.bibliographicCitations[${item_index}].identifier" help="i18n" i18nkey="eml.bibliographicCitationSet.bibliographicCitations.identifier" />
                            </div>
                        </#list>
                    </div>
                </div>

                <div class="addNew col-12 mx-md-4 mx-2 mt-1">
                    <a id="plus" href="">${addLink?lower_case?cap_first}</a>
                </div>

                <div class="buttons col-12 mx-md-4 mx-2 mt-3">
                    <@s.submit cssClass="button btn btn-outline-gbif-primary" name="save" key="button.save" />
                    <@s.submit cssClass="button btn btn-outline-secondary" name="cancel" key="button.cancel" />
                </div>

                <!-- internal parameter -->
                <input name="r" type="hidden" value="${resource.shortname}" />

                <div id="baseItem" class="item row g-3 mx-md-3 mx-1 border-bottom pb-3 mt-1" style="display:none;">
                    <div class="mt-1 d-flex justify-content-end">
                        <a id="removeLink" class="removeLink" href="">[ <@s.text name='manage.metadata.removethis'/> <@s.text name='manage.metadata.citations.item'/> ]</a>
                    </div>
                    <@text name="citation" help="i18n" i18nkey="eml.bibliographicCitationSet.bibliographicCitations.citation"  value="" size=40 requiredField=true />
                    <@input name="identifier" help="i18n" i18nkey="eml.bibliographicCitationSet.bibliographicCitations.identifier" />
                </div>
            </div>
        </div>
    </main>

    </form>

    <#include "/WEB-INF/pages/inc/footer.ftl">
</#escape>
