<!DOCTYPE html>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
  <head>
    <link rel="icon" href="https://www.cyberark.com/wp-content/themes/understrap-child/favicon.ico">
    <title>CyberArk Demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Zenh87qX5JnK2Jl0vWa8Ck2rdkQ2Bzep5IDxbcnCeuOxjzrPF/et3URy9Bv1WTRi" crossorigin="anonymous">
  </head>
  <body>
    <header>
      <div class="navbar navbar-dark bg-dark shadow-sm">
        <div class="container">
          <img src="https://docs.cyberark.com/Product-Doc/OnlineHelp/Portal/Content/Resources/_TopNav/Images/Skin/lg-cyberark.svg">
        </div>
      </div>
    </header>
    <main>
      <section class="py-3 text-center container">
        <div class="row py-lg-3">
          <div class="col-lg-12 col-md-12 mx-auto">
            <h1 class="fw-light">CyberArk Integration: CityApp SpringBoot Demo</h1>
            <p class="lead">&nbsp</p>
            <h2 class="fw-light">Random World Cities!</h2>
            <h3 class="fw-light">
              <c:if test="${!empty cities}">
                ${cities.get(0).ShowContent()}
              </c:if>
              <c:if test="${empty cities}">
                <b><font color=red>ERROR: Query is empty</b></font>
              </c:if>
            </h3>
            <%
              String conjur = System.getenv("CONJUR_APPLIANCE_URL");
              String secretSource = "";
              String dbuser = "";
              String dbpass = "";
              if (conjur==null ){
                secretSource = "ENVIRONMENT";
                dbuser = System.getenv("DB_USER");
                dbpass = System.getenv("DB_PASS");
              } else {
                secretSource = "CONJUR: " + conjur;
                dbuser = "getting from " + System.getenv("CONJUR_MAPPING_DB_USER");
                dbpass = "getting from " + System.getenv("CONJUR_MAPPING_DB_PASS");
              }
            %>
            <p class="lead">&nbsp</p>
            <div class="bg-light p-3 rounded col-lg-5 col-md-5 mx-auto">
              <p class="lead">
                  Host: <b><% out.print(System.getenv("HOSTNAME")); %></b>
              </p>
              <p class="lead">
                Secret source: <b><% 
                    out.print(secretSource); %></b>
                </p>
              <p class="lead">
                Connected to database <b><% out.print(System.getenv("DB_NAME")); %></b> on <b><% out.print(System.getenv("DB_HOST")); %></b>:<b><% out.print(System.getenv("DB_PORT")); %></b>
              </p>
              <p class="lead">
                Using username: <b><% out.print(dbuser); %></b> and password: <b><% out.print(dbpass); %></b>
              </p>
            </div>
            <p class="lead">&nbsp</p>
            <p>
              <a href="https://docs.cyberark.com" class="btn btn-primary my-2">CyberArk Docs</a>
              <a href="https://cyberark-customers.force.com/mplace/s/" class="btn btn-secondary my-2">CyberArk Marketplace</a>
            </p>
          </div>
        </div>
      </section>
    </main>
    <footer class="text-muted py-3">
      <div class="container">
        <p class="float-end mb-1">
          <a href="#">Back to top</a>
        </p>
        <p class="mb-1">A CyberArk demo by Joe Tan <a href="mailto:joe.tan@cyberark.com">&#128231;</a></p>
        <p class="mb-1">Converting to SpringBoot by Huy Do <a href="mailto:huy.do@cyberark.com"> &#x1F4E7;</a></p>
        <p class="mb-0">Style by <a href="https://getbootstrap.com/">Bootstrap</a>.</p>
      </div>
    </footer>
  </body>
</html>