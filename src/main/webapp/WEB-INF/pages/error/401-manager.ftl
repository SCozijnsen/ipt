[#ftl output_format="HTML"]
[#include "/WEB-INF/pages/inc/header-bootstrap.ftl"/]
<title>Login required</title>
[#include "/WEB-INF/pages/inc/menu-bootstrap.ftl"/]

<main class="container pt-5">
    <div class="my-3 p-3 bg-body rounded shadow-sm" id="summary">
        <h4 class="border-bottom pb-2 mb-2 mx-md-4 mx-2 pt-2 text-success text-center">
            [@s.text name="401.manager.title"/]
        </h4>
        <p class="text-muted text-center">[@s.text name="401.manager.body"][@s.param]${baseURL}/login[/@s.param][/@s.text]</p>
    </div>
</main>

[#include "/WEB-INF/pages/inc/footer-bootstrap.ftl"/]
