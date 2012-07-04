<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Displays a message indicating the user has logged out
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<dspace:layout locbar="nolink" titlekey="jsp.login.logged-out.title">
    <div class="div_home_content">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/community.png"/>
            <fmt:message key="jsp.login.logged-out.title"/>
        </h3>
    <%-- <p>Thank you for remembering to log out!</p> --%>
    <p><fmt:message key="jsp.login.logged-out.thank"/></p>
    <%-- <p><a href="<%= request.getContextPath() %>/">Go to DSpace Home</a></p> --%>
    <p><a href="<%= request.getContextPath() %>/"><fmt:message key="jsp.general.gohome"/></a></p>
    </div>
</dspace:layout>
