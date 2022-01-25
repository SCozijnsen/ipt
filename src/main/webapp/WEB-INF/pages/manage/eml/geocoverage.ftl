<#escape x as x?html>
    <#setting number_format="#####.##">
    <#include "/WEB-INF/pages/inc/header.ftl">
<title xmlns="http://www.w3.org/1999/html"><@s.text name='manage.metadata.geocoverage.title'/></title>
    <#assign currentMetadataPage = "geocoverage"/>
    <#assign currentMenu="manage"/>

    <link rel="stylesheet" href="${baseURL}/styles/leaflet/leaflet.css" />
    <link rel="stylesheet" href="${baseURL}/styles/leaflet/locationfilter.css" />
    <script src="${baseURL}/js/leaflet/leaflet.js"></script>
    <script src="${baseURL}/js/leaflet/tile.stamen.js"></script>
    <script src="${baseURL}/js/leaflet/locationfilter.js"></script>

    <script>
        $(document).ready(function() {
            var newBboxBase = "eml\\.geospatialCoverages\\[0\\]\\.boundingCoordinates\\.";
            var maxLatId = newBboxBase + "max\\.latitude";
            var minLatId = newBboxBase + "min\\.latitude";
            var maxLngId = newBboxBase + "max\\.longitude";
            var minLngId = newBboxBase + "min\\.longitude";

            const MIN_LNG_VAL_LIMIT = -180;
            const MAX_LNG_VAL_LIMIT = 180;
            const MIN_LAT_VAL_LIMIT = -90;
            const MAX_LAT_VAL_LIMIT = 90;

            var map = new L.map('map').setView([0, 0], 10).setMaxBounds(L.latLngBounds(L.latLng(-90, -360), L.latLng(90, 360)));

            var layer = new L.StamenTileLayer("terrain");
            map.addLayer(layer, {
                detectRetina: true
            });

            // populate coordinate fields, using min max values as defaults if none exist
            var minLngVal = isNaN(parseFloat($("#" + minLngId).val())) ? MIN_LNG_VAL_LIMIT : parseFloat($("#" + minLngId).val());
            var maxLngVal = isNaN(parseFloat($("#" + maxLngId).val())) ? MAX_LNG_VAL_LIMIT : parseFloat($("#" + maxLngId).val());
            var minLatVal = isNaN(parseFloat($("#" + minLatId).val())) ? MIN_LAT_VAL_LIMIT : parseFloat($("#" + minLatId).val());
            var maxLatVal = isNaN(parseFloat($("#" + maxLatId).val())) ? MAX_LAT_VAL_LIMIT : parseFloat($("#" + maxLatId).val());

            // make the location filter: a draggable/resizable rectangle
            var locationFilter = new L.LocationFilter({
                enable: true,
                enableButton: false,
                adjustButton:false,
                bounds:  L.latLngBounds(L.latLng(minLatVal, minLngVal), L.latLng(maxLatVal, maxLongitudeAdjust(maxLngVal, minLngVal)))
            }).addTo(map);

            // checks if global coverage is set. If on, coordinate input fields are hidden and the map disabled
            if (maxLatVal === MAX_LAT_VAL_LIMIT && minLatVal === MIN_LAT_VAL_LIMIT && maxLngVal === MAX_LNG_VAL_LIMIT && minLngVal === MIN_LNG_VAL_LIMIT) {
                $('input[name=globalCoverage]').attr('checked', true);
                $("#" + minLngId).val(MIN_LNG_VAL_LIMIT);
                $("#" + maxLngId).val(MAX_LNG_VAL_LIMIT);
                $("#" + minLatId).val(MIN_LAT_VAL_LIMIT);
                $("#" + maxLatId).val(MAX_LAT_VAL_LIMIT);
                $("#coordinates").slideUp('slow');
                locationFilter.disable();
                map.fitWorld();
            }

            /** This function updates the map each time the global coverage checkbox is checked or unchecked  */
            $(":checkbox").click(function() {
                if($("#globalCoverage").is(":checked")) {
                    $("#" + minLngId).val(MIN_LNG_VAL_LIMIT);
                    $("#" + maxLngId).val(MAX_LNG_VAL_LIMIT);
                    $("#" + minLatId).val(MIN_LAT_VAL_LIMIT);
                    $("#" + maxLatId).val(MAX_LAT_VAL_LIMIT);
                    $("#coordinates").slideUp('slow');
                    locationFilter.disable();
                    map.fitWorld();
                } else {
                    var minLngVal = parseFloat(${(eml.geospatialCoverages[0].boundingCoordinates.min.longitude)!\-180?c});
                    var maxLngVal = parseFloat(${(eml.geospatialCoverages[0].boundingCoordinates.max.longitude)!180?c});
                    var minLatVal = parseFloat(${(eml.geospatialCoverages[0].boundingCoordinates.min.latitude)!\-90?c});
                    var maxLatVal = parseFloat(${(eml.geospatialCoverages[0].boundingCoordinates.max.latitude)!90?c});
                    $("#" + minLngId).val(minLngVal);
                    $("#" + maxLngId).val(maxLngVal);
                    $("#" + minLatId).val(minLatVal);
                    $("#" + maxLatId).val(maxLatVal);
                    $("#coordinates").slideDown('slow');
                    locationFilter.enable();
                    locationFilter.setBounds(L.latLngBounds(L.latLng(minLatVal, minLngVal), L.latLng(maxLatVal, maxLongitudeAdjust(maxLngVal, minLngVal))));
                }
            });

            /** This function updates the coordinate input fields to mirror bounding box coordinates, after each map change event  */
            locationFilter.on("change", function (e) {
                var minLatVal = clamp(locationFilter.getBounds()._southWest.lat, MIN_LAT_VAL_LIMIT, MAX_LAT_VAL_LIMIT)
                var minLngVal = datelineAdjust(locationFilter.getBounds()._southWest.lng)
                var maxLatVal = clamp(locationFilter.getBounds()._northEast.lat, MIN_LAT_VAL_LIMIT, MAX_LAT_VAL_LIMIT)
                var maxLngVal = datelineAdjust(locationFilter.getBounds()._northEast.lng)
                $("#" + minLatId).val(minLatVal);
                $("#" + minLngId).val(minLngVal);
                $("#" + maxLatId).val(maxLatVal);
                $("#" + maxLngId).val(maxLngVal);
            });

            // lock map on disable
            locationFilter.on("disabled", function (e) {
                locationFilter.setBounds(L.latLngBounds(L.latLng(minLatVal, minLngVal), L.latLng(maxLatVal, maxLngVal)))
            });

            /**
             * Adjusts longitude with respect to dateLine.
             * Do not apply to 180.
             *
             * @param {number} lng The longitude value to adjust.
             * @returns {number} The adjusted longitude value.
             */
            function datelineAdjust(lng) {
                return lng === 180 ? lng : ((lng + 180) % 360) - 180;
            }

            /**
             * Function adjusts max longitude as work-around for leaflet bug occurring when rendering map with max longitude
             * smaller than min longitude.
             *
             * @param {number} maxLng The max longitude value.
             * @param {number} minLng The min longitude value.
             * @returns {number} The adjusted longitude value.
             */
            function maxLongitudeAdjust(maxLng, minLng) {
                if (maxLng < minLng) {
                    maxLng = maxLng + 360;
                }
                return maxLng;
            }

            /**
             * Restricts latitude to be between min and max. Returns min if latitude is less than min.
             * Returns max if latitude is greater than max.
             *
             * @param {number} lat The latitude value to adjust.
             * @param {number} min The minimum latitude value permitted.
             * @param {number} max The maximum latitude value permitted.
             * @returns {number} The restricted latitude value.
             */
            function clamp(lat, min, max) {
                return Math.min(Math.max(lat, min), max);
            }

            /** This function adjusts the map each time the user enters a  */
            $("#bbox input").keyup(function() {
                var minLngStr = $("#" + minLngId).val();
                var maxLngStr = $("#" + maxLngId).val();
                var minLatStr = $("#" + minLatId).val();
                var maxLatStr = $("#" + maxLatId).val();

                // ignore these values
                if (minLngStr.endsWith(".") || minLngStr === "-" || minLngStr === ""
                    || maxLngStr.endsWith(".") || maxLngStr === "-" || maxLngStr === ""
                    || minLatStr.endsWith(".") || minLatStr === "-" || minLatStr === ""
                    || maxLatStr.endsWith(".") || maxLatStr === "-" || maxLatStr === "") {
                    return
                }

                var minLngVal = parseFloat(minLngStr);
                var maxLngVal = parseFloat(maxLngStr);
                var minLatVal = parseFloat(minLatStr);
                var maxLatVal = parseFloat(maxLatStr);

                if (isNaN(minLngVal)) {
                    minLngVal = MIN_LNG_VAL_LIMIT;
                }
                if (isNaN(maxLngVal)) {
                    maxLngVal = MAX_LNG_VAL_LIMIT;
                }
                if (isNaN(minLatVal)) {
                    minLatVal = MIN_LAT_VAL_LIMIT;
                }
                if (isNaN(maxLatVal)) {
                    maxLatVal = MAX_LAT_VAL_LIMIT;
                }
                locationFilter.setBounds(L.latLngBounds(L.latLng(minLatVal, minLngVal), L.latLng(maxLatVal, maxLongitudeAdjust(maxLngVal, minLngVal))))
            });

            $('#metadata-section').change(function () {
                var metadataSection = $('#metadata-section').find(':selected').val()
                $(location).attr('href', 'metadata-' + metadataSection + '.do?r=${resource.shortname!r!}');
            });
        });
    </script>

    <#include "/WEB-INF/pages/inc/menu.ftl">
    <#include "/WEB-INF/pages/macros/forms.ftl"/>

<form class="needs-validation" action="metadata-${section}.do" method="post" novalidate>
    <div class="container-fluid bg-body border-bottom">
        <div class="container pt-2">
            <#include "/WEB-INF/pages/inc/action_alerts.ftl">
        </div>

        <div class="container p-3">

            <div class="text-center">
                <h5 class="pt-2 text-gbif-header fs-4 fw-400 text-center">
                    <@s.text name='manage.metadata.geocoverage.title'/>
                </h5>
            </div>

            <div class="text-center fs-smaller">
                <a href="resource.do?r=${resource.shortname}" title="${resource.title!resource.shortname}">${resource.title!resource.shortname}</a>
            </div>
        </div>
    </div>

    <#include "metadata_section_select.ftl"/>

    <div class="container-fluid bg-body">
        <div class="container bd-layout">

            <main class="bd-main bd-main-right">
                <div class="bd-toc mt-4 mb-5 ps-3 mb-lg-5 text-muted">
                    <#include "eml_sidebar.ftl"/>
                </div>

                <div class="bd-content ps-lg-4">
                    <div class="my-md-3 p-3">
                        <p><@s.text name='manage.metadata.geocoverage.intro'/></p>

                        <div id="map"></div>

                        <div id="bbox" class="row g-3">
                            <div class="col-12">
                                <@checkbox name="globalCoverage" help="i18n" i18nkey="eml.geospatialCoverages.globalCoverage"/>
                            </div>
                            <div id="coordinates" class="row g-3 mt-0">
                                <p class="mb-0">
                                    <strong><@s.text name='manage.metadata.geocoverage.warning'/></strong>
                                </p>

                                <div class="col-md-6">
                                    <@input name="eml.geospatialCoverages[0].boundingCoordinates.min.longitude" value="${(eml.geospatialCoverages[0].boundingCoordinates.min.longitude?c)!}" i18nkey="eml.geospatialCoverages.boundingCoordinates.min.longitude" requiredField=true />
                                </div>
                                <div class="col-md-6">
                                    <@input name="eml.geospatialCoverages[0].boundingCoordinates.max.longitude" value="${(eml.geospatialCoverages[0].boundingCoordinates.max.longitude?c)!}" i18nkey="eml.geospatialCoverages.boundingCoordinates.max.longitude" requiredField=true />
                                </div>
                                <div class="col-md-6">
                                    <@input name="eml.geospatialCoverages[0].boundingCoordinates.min.latitude" value="${(eml.geospatialCoverages[0].boundingCoordinates.min.latitude?c)!}" i18nkey="eml.geospatialCoverages.boundingCoordinates.min.latitude" requiredField=true />
                                </div>
                                <div class="col-md-6">
                                    <@input name="eml.geospatialCoverages[0].boundingCoordinates.max.latitude" value="${(eml.geospatialCoverages[0].boundingCoordinates.max.latitude?c)!}" i18nkey="eml.geospatialCoverages.boundingCoordinates.max.latitude" requiredField=true />
                                </div>
                            </div>
                        </div>

                        <div class="row g-3 mt-2">
                            <div class="col-12">
                                <@text name="eml.geospatialCoverages[0].description" value="${(eml.geospatialCoverages[0].description)!}" i18nkey="eml.geospatialCoverages.description" requiredField=true minlength=2 />
                            </div>

                            <div class="col-12">
                                <@s.submit cssClass="button btn btn-outline-gbif-primary" name="save" key="button.save" />
                                <@s.submit cssClass="button btn btn-outline-secondary" name="cancel" key="button.back" />
                            </div>
                        </div>


                        <!-- internal parameter -->
                        <input name="r" type="hidden" value="${resource.shortname}" />
                    </div>
                </div>
            </main>
        </div>
    </div>
</form>

    <#include "/WEB-INF/pages/inc/footer.ftl">
</#escape>
