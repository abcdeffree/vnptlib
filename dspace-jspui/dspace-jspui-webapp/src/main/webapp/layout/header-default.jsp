<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.browse.BrowseInfo"%>
<%@page import="org.dspace.browse.BrowseIndex"%>
<%@page import="org.dspace.app.webui.util.UIUtil"%>
<%@page import="org.dspace.eperson.EPerson"%>
<%--
  - HTML header for main home page
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.util.Util" %>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>

<%
    String title = (String) request.getAttribute("dspace.layout.title");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    boolean locbar = ((Boolean) request.getAttribute("dspace.layout.locbar")).booleanValue();

    String siteName = ConfigurationManager.getProperty("dspace.name");
    String feedRef = (String) request.getAttribute("dspace.layout.feedref");
    boolean osLink = ConfigurationManager.getBooleanProperty("websvc.opensearch.autolink");
    String osCtx = ConfigurationManager.getProperty("websvc.opensearch.svccontext");
    String osName = ConfigurationManager.getProperty("websvc.opensearch.shortname");
    List parts = (List) request.getAttribute("dspace.layout.linkparts");
    String extraHeadData = (String) request.getAttribute("dspace.layout.head");
    String dsVersion = Util.getSourceVersion();
    String generator = dsVersion == null ? "DSpace" : "DSpace " + dsVersion;
%>
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
<!DOCTYPE HTML>
<html>
    <head>
        <title><%= siteName%>: <%= title%></title>
        <meta charset="UTF-8">
        <meta name="Generator" content="<%= generator%>" />
        <link rel="stylesheet" href="<%= request.getContextPath()%>/styles.css"/>
        <link rel="stylesheet" href="<%= request.getContextPath()%>/jquery.treeview.css"/>
        <link rel="stylesheet" href="<%= request.getContextPath()%>/print.css" media="print"/>
        <link rel="shortcut icon" href="<%= request.getContextPath()%>/favicon.ico" type="image/x-icon"/>
        <%
            if (!"NONE".equals(feedRef)) {
                for (int i = 0; i < parts.size(); i += 3) {
        %>
        <link rel="alternate" type="application/<%= (String) parts.get(i)%>" title="<%= (String) parts.get(i + 1)%>" href="<%= request.getContextPath()%>/feed/<%= (String) parts.get(i + 2)%>/<%= feedRef%>"/>
        <%
                }
            }

            if (osLink) {
        %>
        <link rel="search" type="application/opensearchdescription+xml" href="<%= request.getContextPath()%>/<%= osCtx%>description.xml" title="<%= osName%>"/>
        <%
            }

            if (extraHeadData != null) {%>
        <%= extraHeadData%>
        <%
            }
        %>

        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/prototype.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/effects.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/builder.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/controls.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/choice-support.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/jquery-1.7.2.min.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/jquery.cookie.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/jquery.treeview.min.js"></script>
        <script src="<%= request.getContextPath()%>/static/js/scriptaculous/jquery.colorbox-min.js"></script>
        <script> 
            jQuery.noConflict();
        </script>
        <script src="<%= request.getContextPath()%>/utils.js"></script>
        <script src="http://www.google.com/jsapi"></script> 
        <script> 
            google.setOnLoadCallback(function() {
                // Place init code here instead of $(document).ready()
            });
        </script>
    </head>

    <%-- HACK: leftmargin, topmargin: for non-CSS compliant Microsoft IE browser --%>
    <%-- HACK: marginwidth, marginheight: for non-CSS compliant Netscape browser --%>
    <body>
        <div class="maincontent">
            <%-- DSpace top-of-page banner --%>
            <%-- HACK: width, border, cellspacing, cellpadding: for non-CSS compliant Netscape, Mozilla browsers --%>
            <div class="divpageBanner">
                <div class="divuser">
                    <ul>
                        <%
                            if (user != null) {
                        %>
                        <li>
                            <img  class="nav_a_mydspace" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <a href="<%= request.getContextPath()%>/mydspace"><%= navbarEmail%></a>
                        </li>
                        <li>
                            <img  class="nav_a_profile" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <a href="<%= request.getContextPath()%>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a>
                        </li>
                        <%
                        } else {

                        %>
                        <li>
                            <img  class="nav_a_login" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <a href="<%= request.getContextPath()%>/password-login"><fmt:message key="jsp.components.login-form.login"/></a>
                        </li>
                        <li>
                            <img  class="nav_a_register" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <a href="<%= request.getContextPath()%>/register">Đăng ký</a>
                        </li>
                        <%
                            }
                        %>
                        <li>
                            <img  class="nav_a_help" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, 
                    
                            
                            \"help.index\")%>"><fmt:message key="jsp.layout.navbar-default.help"/></dspace:popup>
                            </li>

                        <%
                            if (isAdmin) {
                        %>  
                        <li>
                            <img  class="nav_a_admin" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <a href="<%= request.getContextPath()%>/dspace-admin"><fmt:message key="jsp.administer"/></a>
                        </li>
                        <%
                            }
                        %>
                        <%
                            if (user != null) {
                        %>
                        <li>
                            <img  class="nav_a_logout" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                            <a href="<%= request.getContextPath()%>/logout"><fmt:message key="jsp.layout.navbar-default.logout"/></a>
                        </li>
                        <%}%>
                    </ul>
                </div>
                <div class="divformsearch">
                    <form method="get" action="<%= request.getContextPath()%>/simple-search">
                        <%-- <input type="text" name="query" id="tequery" size="10"/><input type=image border="0" src="<%= request.getContextPath() %>/image/search-go.gif" name="submit" alt="Go" value="Go"/> --%>
                        <input type="text" name="query" id="tequery" />
                        <input type="submit" name="submit" class="inputformsearch" value=""/>
                        <a href="<%= request.getContextPath()%>/advanced-search"><fmt:message key="jsp.layout.navbar-default.advanced"/></a>
                        <%
                            if (ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable")) {
                        %>        
                        <br/><a href="<%= request.getContextPath()%>/subject-search"><fmt:message key="jsp.layout.navbar-default.subjectsearch"/></a>
                        <%
                            }
                        %>
                    </form>
                </div>
                <div class="divtitlepage">
                    <span>THƯ VIỆN SỐ</span>
                </div>
            </div>
            <div class="nav">
                <ul id="navid" class="nav fl">
                    <li>
                        <a href="<%= request.getContextPath()%>/" class="nav-home">
                            <span class="a_nav_home"><fmt:message key="jsp.layout.navbar-default.home"/></span>
                        </a>    
                    </li>
                    <li>
                        <a href="<%= request.getContextPath()%>/category" class="nav-community-list">
                            <span><fmt:message key="jsp.layout.navbar-default.communities-collections"/></span>
                        </a>
                    </li>
                    <%
                        for (int i = 0; i < bis.length - 1; i++) {
                            BrowseIndex bix = bis[i];
                            String key = "browse.menu." + bix.getName();
                    %>
                    <li>
                        <a href="<%= request.getContextPath()%>/browse?type=<%= bix.getName()%>" class="nav-<%= bix.getName()%>">
                            <span><fmt:message key="<%= key%>"/></span>
                        </a>
                    </li>
                    <%
                        }
                    %>
                    <li>
                        <%
                            if (isAdmin) {
                        %>  
                        <a href="<%= request.getContextPath()%>/dspace-admin" class="nav-dspace-admin">
                            <span><fmt:message key="jsp.administer"/></span>
                        </a>
                        <%
                            }
                        %>
                    </li>
                </ul>
            </div>

            <%-- Localization --%>
            <%--  <c:if test="${param.locale != null}">--%>
            <%--   <fmt:setLocale value="${param.locale}" scope="session" /> --%>
            <%-- </c:if> --%>
            <%--        <fmt:setBundle basename="Messages" scope="session"/> --%>

            <%-- Page contents --%>

            <%-- HACK: width, border, cellspacing, cellpadding: for non-CSS compliant Netscape, Mozilla browsers --%>
            <div style="clear: both"></div>
            <div class="divcontent">

                <%-- HACK: valign: for non-CSS compliant Netscape browser --%>
                <%-- Navigation bar --%>
                <%
                    if (!navbar.equals("off") && navbar.indexOf("admin") > -1) {
                %>
                <div class="divnavbar">
                    <dspace:include page="<%= navbar%>" />
                </div>
                <%
                    }
                %>
                <%-- Page Content --%>
                <div class="divpagecontent">
                    <div class="divmargin">
                        <%-- HACK: width specified here for non-CSS compliant Netscape 4.x --%>
                        <%-- HACK: Width shouldn't really be 100%, but omitting this means --%>
                        <%--       navigation bar gets far too wide on certain pages --%>
                        <%-- Location bar --%>
                        <%
                            if (locbar) {
                        %>
                        <dspace:include page="/layout/location-bar.jsp" />
                        <%    }
                        %>
