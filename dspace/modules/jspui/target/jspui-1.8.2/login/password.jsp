<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Page that displays the email/password login form
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
    
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<dspace:layout navbar="off" locbar="off" titlekey="jsp.login.password.title" nocache="true">
    <div class="div_home_content">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/community.png"/>
            <fmt:message key="jsp.login.password.heading"/> 
            <span class="link_normal">
                <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#login\"%>"><fmt:message key="jsp.help"/></dspace:popup>
            </span>
        </h3>
    <dspace:include page="/components/login-form.jsp" />
    </div>
</dspace:layout>
