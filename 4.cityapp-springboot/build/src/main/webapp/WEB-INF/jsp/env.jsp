<%@ page pageEncoding="utf8" import="java.util.*"
	contentType="text/html; charset=utf8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Environment dump</title>
<link rel="stylesheet"
	href="//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css" />
<script type="text/javascript"
	src="//code.jquery.com/jquery-1.10.1.min.js"></script>
<script type="text/javascript"
	src="//netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
</head>
<body data-target="#scrollspy" data-spy="scroll">
	<div class="container">
		<div class="row clearfix">
			<div class="col-md-3 column" id="scrollspy">
				&nbsp;
				<ul class="nav nav-stacked nav-pills" id="affix" data-offset-top="0"
					data-spy="affix">
					<li class="active"><a href="#request">Request Data</a></li>
					<li><a href="#header">HTTP Request Header</a></li>
					<li><a href="#params">HTTP Request Parameter</a></li>
					<li><a href="#request-attributes">HTTP Request Attributes</a></li>
					<li><a href="#env">System Environment Variables</a></li>
					<li><a href="#properties">System Properties</a></li>
					<li><a href="#session">Session Attributes</a></li>
					<li><a href="#cookies">Cookies</a></li>
					<li><a href="#form">Form</a></li>
				</ul>
			</div>
			<div class="col-md-9 column">
				<h1>Environment dump</h1>
				<h2>
					<a id="request">Request Data</a>
				</h2>
				<table class="table">
					<col width="40%">
					<col width="60%">
					<tbody>
						<tr>
							<th>Auth Type</th>
							<td>${pageContext.request.authType}</td>
						</tr>
						<tr>
							<th>Character Encoding</th>
							<td>${pageContext.request.characterEncoding}</td>
						</tr>
						<tr>
							<th>Context Path</th>
							<td>${pageContext.request.contextPath}</td>
						</tr>
						<tr>
							<th>Remote User</th>
							<td>${pageContext.request.remoteUser}</td>
						</tr>
						<tr>
							<th>Method</th>
							<td>${pageContext.request.method}</td>
						</tr>
						<tr>
							<th>Secure</th>
							<td>${pageContext.request.secure}</td>
						</tr>
						<tr>
							<th>User Principal</th>
							<td>${pageContext.request.userPrincipal}</td>
						</tr>
					</tbody>
				</table>

				<h2>
					<a id="header">HTTP Request Header</a>
				</h2>
				<table class="table">
					<col width="40%">
					<col width="60%">
					<tr>
						<th>Name</th>
						<th>Value</th>
					</tr>
					<c:forEach var="next" items="${header}">
						<tr>
							<td>${next.key}</td>
							<td>${next.value}</td>
						</tr>
					</c:forEach>
				</table>

				<h3>Common multi-value headers</h3>
				<table class="table">
					<col width="40%">
					<col width="60%">
					<tr>
						<th>Name</th>
						<th>Value</th>
					</tr>
					<tr>
						<td>accept</td>
						<td>
							<ul>
								<c:forTokens var="item" items="${header.accept}" delims=",">
									<li>${item}</li>
								</c:forTokens>
							</ul>
						</td>
					</tr>
					<tr>
						<td>accept-language</td>
						<td>
							<ul>
								<c:forTokens var="item" items="${header['accept-language']}"
									delims=",">
									<li>${item}</li>
								</c:forTokens>
							</ul>
						</td>
					</tr>
				</table>

				<h2>
					<a id="params">HTTP Request Parameters</a>
				</h2>
				<table class="table">
					<col width="40%">
					<col width="60%">
					<tr>
						<th>Name</th>
						<th>Value</th>
					</tr>
					<c:forEach var="next" items="${param}">
						<tr>
							<td>${next.key}</td>
							<td>${next.value}</td>
						</tr>
					</c:forEach>
				</table>
				<h2>
					<a id="request-attributes">HTTP Request Attributes</a>
				</h2>
				<c:if test="${empty requestScope}">
					<div class="alert alert-warning">
						<i>requestScope is empty</i>
					</div>
				</c:if>
				<c:if test="${not empty requestScope}">
					<table class="table">
						<col width="40%">
						<col width="60%">
						<tr>
							<th>Name</th>
							<th>Value</th>
						</tr>
						<c:forEach var="next" items="${requestScope}">
							<tr>
								<td>${next.key}</td>
								<td>${next.value}</td>
							</tr>
						</c:forEach>
					</table>
				</c:if>

				<h2>
					<a id="env">System Environment Variables</a>
				</h2>
				<table class="table">
					<col width="40%">
					<col width="60%">
					<tr>
						<th>Name</th>
						<th>Value</th>
					</tr>
					<%
					    final Map<String, String> env = System.getenv(); 
					    for (final String envVar : new TreeSet<String>(env.keySet())) {
					%>
					<tr>
						<td><%=envVar%></td>
						<%
						    if (env.get(envVar)
						                .contains(";")) {
						%>
						<td>
							<ul>
								<%
								    for (final String pathElement : env.get(envVar)
								                    .split(";")) {
								%>
								<li><%=pathElement%></li>
								<%
								    }
								%>
							</ul>
						</td>
						<%
						    } else {
						%>
						<td><%=env.get(envVar)%></td>
						<%
						    }
						%>
					</tr>
					<%
					    }
					%>
				</table>

				<h2>
					<a id="properties">System Properties</a>
				</h2>

				<table class="table">
					<col width="40%">
					<col width="60%">
					<tr>
						<th>Name</th>
						<th>Value</th>
					</tr>
					<%
					    for (final String propertyName : new TreeSet<String>(System.getProperties()
					            .stringPropertyNames())) {
					%>
					<tr>
						<td><%=propertyName%></td>
						<%
						    if (System.getProperty(propertyName)
						                .contains(";")) {
						%>
						<td>
							<ul>
								<%
								    for (final String pathElement : System.getProperty(propertyName)
								                    .split(";")) {
								%>
								<li><%=pathElement%></li>
								<%
								    }
								%>
							</ul>
						</td>
						<%
						    } else if (System.getProperty(propertyName)
						                .contains(",")) {
						%>
						<td>
							<ul>
								<%
								    for (final String pathElement : System.getProperty(propertyName)
								                    .split(",")) {
								%>
								<li><%=pathElement%></li>
								<%
								    }
								%>
							</ul>
						</td>
						<%
						    } else {
						%>
						<td><%=System.getProperty(propertyName)%></td>
						<%
						    }
						%>
					</tr>
					<%
					    }
					%>
				</table>

				<h2>
					<a id="session">Session Attributes</a>
				</h2>
				<c:if test="${empty sessionScope}">
					<div class="alert alert-warning">
						<i>HttpSession is empty or not available</i>
					</div>
				</c:if>
				<c:if test="${not empty sessionScope}">
					<table class="table">
						<col width="40%">
						<col width="60%">
						<tr>
							<th>Name</th>
							<th>Value</th>
						</tr>
						<c:forEach var="next" items="${sessionScope}">
							<tr>
								<td>${next.key}</td>
								<td>${next.value}</td>
							</tr>
						</c:forEach>
					</table>
				</c:if>

				<h2>
					<a id="cookies">Cookies</a>
				</h2>
				<table class="table">
					<tr>
						<th>Name</th>
						<th>Value</th>
					</tr>
					<c:set var="cookieSize" value="0" />
					<c:forEach var="next" items="${cookie}">
						<tr>
							<td>${next.key}</td>
							<td>${next.value.value}</td>
						</tr>

						<c:set var="cookieSize"
							value="${cookieSize + fn:length(next.key) + fn:length(next.value.value) }" />

					</c:forEach>
					<tr>
						<th>Size of names and values</th>
						<td>${cookieSize}</td>
					</tr>
				</table>

				<h2>
					<a id="form">Form POST</a>
				</h2>
				<p>Use this to send a post request to this JSP and see what kind
					of data gets sent.</p>
				<form action="env.jsp" method="post" onsubmit="">
					<input type="text" name="text"> <input type="checkbox"
						name="checkbox">
					<textarea name="textarea"></textarea>
					<input type="submit" class="btn btn-default">
				</form>

			</div>
		</div>
	</div>
</body>
</html>