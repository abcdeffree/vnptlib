<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Default navigation bar
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="java.util.Map" %>
<%
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin
    Boolean admin = (Boolean) request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf('?');
    if (c > -1) {
        currentPage = currentPage.substring(0, c);
    }

    // E-mail may have to be truncated
    String navbarEmail = null;

    if (user != null) {
        navbarEmail = user.getEmail();
        if (navbarEmail.length() > 18) {
            navbarEmail = navbarEmail.substring(0, 17) + "...";
        }
    }

    // get the browse indices

    BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
    String browseCurrent = "";
    if (binfo != null) {
        BrowseIndex bix = binfo.getBrowseIndex();
        // Only highlight the current browse, only if it is a metadata index,
        // or the selected sort option is the default for the index
        if (bix.isMetadataIndex() || bix.getSortOption() == binfo.getSortOption()) {
            if (bix.getName() != null) {
                browseCurrent = bix.getName();
            }
        }
    }
%>

<%-- Search Box --%>

<%-- HACK: width, border, cellspacing, cellpadding: for non-CSS compliant Netscape, Mozilla browsers --%>
<table width="100%" border="0" cellspacing="2" cellpadding="2">
    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/index.jsp") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>

        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/"><fmt:message key="jsp.layout.navbar-default.home"/></a>
        </td>
    </tr>

    <tr>
        <td colspan="2">&nbsp;</td>
    </tr>

    <tr>
        <td nowrap="nowrap" colspan="2" class="navigationBarSublabel"><fmt:message key="jsp.layout.navbar-default.browse"/></td>
    </tr>

    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/community-list") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a>
        </td>
    </tr>


    <%-- Insert the dynamic browse indices here --%>

    <%
        for (int i = 0; i < bis.length; i++) {
            BrowseIndex bix = bis[i];
            String key = "browse.menu." + bix.getName();
    %>
    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (browseCurrent.equals(bix.getName()) ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/browse?type=<%= bix.getName()%>"><fmt:message key="<%= key%>"/></a>
        </td>
    </tr>
    <%
        }
    %>

    <%-- End of dynamic browse indices --%>

    <tr>
        <td colspan="2">&nbsp;</td>
    </tr>

    <tr>
        <td nowrap="nowrap" colspan="2" class="navigationBarSublabel"><fmt:message key="jsp.layout.navbar-default.sign"/></td>
    </tr>

    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/subscribe") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a>
        </td>
    </tr>

    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/mydspace") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a><br/>
            <fmt:message key="jsp.layout.navbar-default.users-authorized" />
        </td>
    </tr>

    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/profile") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a>
        </td>
    </tr>

    <%
        if (isAdmin) {
    %>  
    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/dspace-admin") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="<%= request.getContextPath()%>/dspace-admin"><fmt:message key="jsp.administer"/></a>
        </td>
    </tr>
    <%
        }
    %>

    <tr>
        <td colspan="2">&nbsp;</td>
    </tr>

    <tr class="navigationBarItem">
        <td>
            <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/help") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, 
                \"help.index\")%>"><fmt:message key="jsp.layout.navbar-default.help"/></dspace:popup>
            </td>
        </tr>

        <tr class="navigationBarItem">
            <td>
                <img alt="" src="<%= request.getContextPath()%>/image/<%= (currentPage.endsWith("/about") ? "arrow-highlight" : "arrow")%>.gif" width="16" height="16"/>
        </td>
        <td nowrap="nowrap" class="navigationBarItem">
            <a href="http://www.dspace.org/"><fmt:message key="jsp.layout.navbar-default.about"/></a>
        </td>
    </tr>
</table>