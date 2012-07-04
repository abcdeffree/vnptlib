<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet"%>
<%--
  - Display the results of browsing a full hit list
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="org.dspace.sort.SortOption" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    String urlFragment = "browse";
    String layoutNavbar = "default";
    boolean withdrawn = false;
    if (request.getAttribute("browseWithdrawn") != null) {
        layoutNavbar = "admin";
        urlFragment = "dspace-admin/withdrawn";
        withdrawn = true;
    }

    // First, get the browse info object
    BrowseInfo bi = (BrowseInfo) request.getAttribute("browse.info");
    BrowseIndex bix = bi.getBrowseIndex();
    SortOption so = bi.getSortOption();

    // values used by the header
    String scope = "";
    String type = "";
    String value = "";

    Community community = null;
    Collection collection = null;
    if (bi.inCommunity()) {
        community = (Community) bi.getBrowseContainer();
    }
    if (bi.inCollection()) {
        collection = (Collection) bi.getBrowseContainer();
    }

    if (community != null) {
        scope = "\"" + community.getMetadata("name") + "\"";
    }
    if (collection != null) {
        scope = "\"" + collection.getMetadata("name") + "\"";
    }

    type = bix.getName();

    // next and previous links are of the form:
    // [handle/<prefix>/<suffix>/]browse?type=<type>&sort_by=<sort_by>&order=<order>[&value=<value>][&rpp=<rpp>][&[focus=<focus>|vfocus=<vfocus>]

    // prepare the next and previous links
    String linkBase = request.getContextPath() + "/";
    if (collection != null) {
        linkBase = linkBase + "handle/" + collection.getHandle() + "/";
    }
    if (community != null) {
        linkBase = linkBase + "handle/" + community.getHandle() + "/";
    }

    String direction = (bi.isAscending() ? "ASC" : "DESC");

    String argument = null;
    if (bi.hasAuthority()) {
        value = bi.getAuthority();
        argument = "authority";
    } else if (bi.hasValue()) {
        value = bi.getValue();
        argument = "value";
    }

    String valueString = "";
    if (value != null) {
        valueString = "&amp;" + argument + "=" + URLEncoder.encode(value);
    }

    String sharedLink = linkBase + urlFragment + "?";

    if (bix.getName() != null) {
        sharedLink += "type=" + URLEncoder.encode(bix.getName());
    }

    sharedLink += "&amp;sort_by=" + URLEncoder.encode(Integer.toString(so.getNumber()))
            + "&amp;order=" + URLEncoder.encode(direction)
            + "&amp;rpp=" + URLEncoder.encode(Integer.toString(bi.getResultsPerPage()))
            + "&amp;etal=" + URLEncoder.encode(Integer.toString(bi.getEtAl()))
            + valueString;

    String next = sharedLink;
    String prev = sharedLink;

    if (bi.hasNextPage()) {
        next = next + "&amp;offset=" + bi.getNextOffset();
    }

    if (bi.hasPrevPage()) {
        prev = prev + "&amp;offset=" + bi.getPrevOffset();
    }

    // prepare a url for use by form actions
    String formaction = request.getContextPath() + "/";
    if (collection != null) {
        formaction = formaction + "handle/" + collection.getHandle() + "/";
    }
    if (community != null) {
        formaction = formaction + "handle/" + community.getHandle() + "/";
    }
    formaction = formaction + urlFragment;

    // prepare the known information about sorting, ordering and results per page
    String sortedBy = so.getName();
    String ascSelected = (bi.isAscending() ? "selected=\"selected\"" : "");
    String descSelected = (bi.isAscending() ? "" : "selected=\"selected\"");
    int rpp = bi.getResultsPerPage();

    // the message key for the type
    String typeKey;

    if (bix.isMetadataIndex()) {
        typeKey = "browse.type.metadata." + bix.getName();
    } else if (bi.getSortOption() != null) {
        typeKey = "browse.type.item." + bi.getSortOption().getName();
    } else {
        typeKey = "browse.type.item." + bix.getSortOption().getName();
    }

    // Admin user or not
    Boolean admin_b = (Boolean) request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    String uri = (String) request.getParameter("type");
%>

<%-- OK, so here we start to develop the various components we will use in the UI --%>

<%@page import="java.util.Set"%>
<dspace:layout titlekey="browse.page-title" navbar="<%=layoutNavbar%>">
    <div class="div_home_content">
        <%-- Build the header (careful use of spacing) --%>
        <%
            if (!(uri == null)) {
        %>
        <h3><img  class="nav_home_h3" src="./image/document_browse.png"/>
            <fmt:message key="browse.full.header"><fmt:param value="<%= scope%>"/></fmt:message> <fmt:message key="<%= typeKey%>"/> <%= value%>
        </h3>
        <%-- Include the main navigation for all the browse pages --%>
        <%-- This first part is where we render the standard bits required by both possibly navigations --%>
        <div align="center" id="browse_navigation">
            <form method="get" action="<%= formaction%>">
                <input type="hidden" name="type" value="<%= bix.getName()%>"/>
                <input type="hidden" name="sort_by" value="<%= so.getNumber()%>"/>
                <input type="hidden" name="order" value="<%= direction%>"/>
                <input type="hidden" name="rpp" value="<%= rpp%>"/>
                <input type="hidden" name="etal" value="<%= bi.getEtAl()%>" />
                <%
                    if (bi.hasAuthority()) {
                %><input type="hidden" name="authority" value="<%=bi.getAuthority()%>"/><%
                } else if (bi.hasValue()) {
                %><input type="hidden" name="value" value="<%= bi.getValue()%>"/><%
                    }
                %>

                <%-- If we are browsing by a date, or sorting by a date, render the date selection header --%>
                <%
                    if (so.isDate() || (bix.isDate() && so.isDefault())) {
                %>
                <div>
                    <span class="browseBarLabel">Chọn thời gian xuất bản:</span>
                    <select name="year">
                        <option selected="selected" value="-1"><fmt:message key="browse.nav.year"/></option>
                        <%
                            int thisYear = DCDate.getCurrent().getYear();
                            for (int i = thisYear; i >= 1990; i--) {
                        %>
                        <option><%= i%></option>
                        <%
                            }
                        %>
                        <option>1985</option>
                        <option>1980</option>
                        <option>1975</option>
                        <option>1970</option>
                        <option>1960</option>
                        <option>1950</option>
                    </select>
                    <select name="month">
                        <option selected="selected" value="-1"><fmt:message key="browse.nav.month"/></option>
                        <%
                            for (int i = 1; i <= 12; i++) {
                        %>
                        <option value="<%= i%>"><%= DCDate.getMonthName(i, UIUtil.getSessionLocale(request))%></option>
                        <%
                            }
                        %>
                    </select>
                    <input type="submit" value="<fmt:message key="browse.nav.go"/>" />
                </div>
                <!--div>
                    <%-- HACK:  Shouldn't use align here --%>
                    <span class="browseBarLabel"><fmt:message key="browse.nav.type-year"/></span>
                    <input type="text" name="starts_with" size="4" maxlength="4"/>
                </div-->
                <%
                } // If we are not browsing by a date, render the string selection header //
                else {
                %>	
                <div>
                    <ul class="browse-alpha">
                        <li >
                            <a href="<%= sharedLink%>&amp;starts_with=0">0-9</a>
                        </li>
                        <%
                            for (char c = 'A'; c <= 'Z'; c++) {
                        %>
                        <li>
                            <a href="<%= sharedLink%>&amp;starts_with=<%= c%>"><%= c%></a>
                        </li>
                        <%
                            }
                        %>
                    </ul>
                </div>
                <div class="start_with">
                    <input type="text" name="starts_with"/>&nbsp;<input type="submit" value="<fmt:message key="browse.nav.go"/>" />
                </div>
                <div align="center" class="browse_range">
                    <fmt:message key="browse.full.range">
                        <fmt:param value="<%= Integer.toString(bi.getStart())%>"/>
                        <fmt:param value="<%= Integer.toString(bi.getFinish())%>"/>
                        <fmt:param value="<%= Integer.toString(bi.getTotal())%>"/>
                    </fmt:message>
                    <%
                        if (bi.hasPrevPage()) {
                    %>
                    <a href="<%= prev%>"><fmt:message key="browse.full.prev"/></a>&nbsp;
                    <%
                        }
                    %>

                    <%
                        if (bi.hasNextPage()) {
                    %>
                    &nbsp;<a href="<%= next%>"><fmt:message key="browse.full.next"/></a>
                    <%
                        }
                    %>
                </div>
                <%
                    }
                %>
            </form>
        </div>
        <%-- End of Navigation Headers --%>
        <%}else{
        %>
        <h3><img  class="nav_home_h3" src="./image/document_browse.png"/>
            Danh sách tài liệu
        </h3>
        <dspace:sidebar>
        <%
            if (admin_button)
            {
        %>     
        <div class="div_box_rightbar">
            <h3><fmt:message key="jsp.admintools"/></h3>
            <form method="post" action="<%=request.getContextPath()%>/dspace-admin/edit-communities">
                    <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_CREATE_COMMUNITY%>" />
                <%--<input type="submit" name="submit" value="Create Top-Level Community...">--%>
                    <form method="post" action="<%=request.getContextPath()%>/dspace-admin/edit-communities">				<input type="submit" name="submit" value="<fmt:message key="jsp.community-list.create.button"/>" />
            </form>
            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>"><fmt:message key="jsp.adminhelp"/></dspace:popup>
        </div>
        <%
            }
        %>
        </dspace:sidebar>
        <%}%>
        <%-- give us the top report on what we are looking at --%>
        <div class="clearall"></div>

        <%-- output the results using the browselist tag --%>
        <%
            if (bix.isMetadataIndex()) {
        %>
        <dspace:browselist browseInfo="<%= bi%>" emphcolumn="<%= bix.getMetadata()%>" />
        <%
        } else if (request.getAttribute("browseWithdrawn") != null) {
        %>
        <dspace:browselist browseInfo="<%= bi%>" emphcolumn="<%= bix.getSortOption().getMetadata()%>" linkToEdit="true" disableCrossLinks="true" />
        <%
        } else {
        %>
        <dspace:browselist browseInfo="<%= bi%>" emphcolumn="<%= bix.getSortOption().getMetadata()%>" />
        <%
            }
        %>
        <%-- give us the bottom report on what we are looking at --%>
        <div align="center" class="browse_range">
            <fmt:message key="browse.full.range">
                <fmt:param value="<%= Integer.toString(bi.getStart())%>"/>
                <fmt:param value="<%= Integer.toString(bi.getFinish())%>"/>
                <fmt:param value="<%= Integer.toString(bi.getTotal())%>"/>
            </fmt:message>
        </div>

        <%--  do the bottom previous and next page links --%>
        <div align="center">
            <%
                if (bi.hasPrevPage()) {
            %>
            <a href="<%= prev%>"><fmt:message key="browse.full.prev"/></a>&nbsp;
            <%
                }
            %>

            <%
                if (bi.hasNextPage()) {
            %>
            &nbsp;<a href="<%= next%>"><fmt:message key="browse.full.next"/></a>
            <%
                }
            %>
        </div>

        <%-- dump the results for debug (uncomment to enable) --%>
        <%-- 
        <!-- <%= bi.toString() %> -->
        --%>
    </div>
</dspace:layout>





























