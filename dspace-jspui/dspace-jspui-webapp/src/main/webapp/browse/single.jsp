<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@page import="org.dspace.core.ConfigurationManager"%>
<%--
  - 
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    //First, get the browse info object
    BrowseInfo bi = (BrowseInfo) request.getAttribute("browse.info");
    BrowseIndex bix = bi.getBrowseIndex();

    //values used by the header
    String scope = "";
    String type = "";

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

    //FIXME: so this can probably be placed into the Messages.properties file at some point
    // String header = "Browsing " + scope + " by " + type;

    // get the values together for reporting on the browse values
    // String range = "Showing results " + bi.getStart() + " to " + bi.getFinish() + " of " + bi.getTotal();

    // prepare the next and previous links
    String linkBase = request.getContextPath() + "/";
    if (collection != null) {
        linkBase = linkBase + "handle/" + collection.getHandle() + "/";
    }
    if (community != null) {
        linkBase = linkBase + "handle/" + community.getHandle() + "/";
    }

    String direction = (bi.isAscending() ? "ASC" : "DESC");
    String sharedLink = linkBase + "browse?type=" + URLEncoder.encode(bix.getName())
            + "&amp;order=" + URLEncoder.encode(direction)
            + "&amp;rpp=" + URLEncoder.encode(Integer.toString(bi.getResultsPerPage()));

    // prepare the next and previous links
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
    formaction = formaction + "browse";

    String ascSelected = (bi.isAscending() ? "selected=\"selected\"" : "");
    String descSelected = (bi.isAscending() ? "" : "selected=\"selected\"");
    int rpp = bi.getResultsPerPage();

//	 the message key for the type
    String typeKey = "browse.type.metadata." + bix.getName();
    String adventiseNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-adventise.html"));
%>

<dspace:layout titlekey="browse.page-title">
    <div class="div_home_content">
        <%-- Build the header (careful use of spacing) --%>
        <h3><img  class="nav_home_h3" src="./image/document_browse.png"/>
            <fmt:message key="browse.single.header"><fmt:param value="<%= scope%>"/></fmt:message> <fmt:message key="<%= typeKey%>"/>
        </h3>

        <%-- Include the main navigation for all the browse pages --%>
        <%-- This first part is where we render the standard bits required by both possibly navigations --%>
        <div align="center" id="browse_navigation">
            <form method="get" action="<%= formaction%>">
                <input type="hidden" name="type" value="<%= bix.getName()%>"/>
                <input type="hidden" name="order" value="<%= direction%>"/>
                <input type="hidden" name="rpp" value="<%= rpp%>"/>

                <%-- If we are browsing by a date, or sorting by a date, render the date selection header --%>
                <%
                    if (bix.isDate()) {
                %>
                <table align="center" border="0" bgcolor="#CCCCCC" cellpadding="0" summary="Browsing by date">
                    <tr>
                        <td>
                            <table border="0" bgcolor="#EEEEEE" cellpadding="2">
                                <tr>
                                    <td class="browseBar">
                                        <span class="browseBarLabel"><fmt:message key="browse.nav.date.jump"/> </span>
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
                                    </td>
                                    <td class="browseBar" rowspan="2">
                                        <input type="submit" value="<fmt:message key="browse.nav.go"/>" />
                                    </td>
                                </tr>
                                <tr>
                                    <%-- HACK:  Shouldn't use align here --%>
                                    <td class="browseBar" align="center">
                                        <span class="browseBarLabel"><fmt:message key="browse.nav.type-year"/></span>
                                        <input type="text" name="starts_with" size="4" maxlength="4"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <%
                } // If we are not browsing by a date, render the string selection header //
                else {
                %>	
                <div>
                    <ul class="browse-alpha">
                        <li>
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
                    <fmt:message key="browse.single.range">
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

        <%-- THE RESULTS --%>
        <table align="center" class="miscTable" summary="This table displays a list of results">
            <%
                // Row: toggles between Odd and Even
                String row = "odd";
                String[][] results = bi.getStringResults();

                for (int i = 0; i < results.length; i++) {
            %>
            <tr>
                <td class="<%= row%>RowOddCol">
                    <a href="<%= sharedLink%><% if (results[i][1] != null) {%>&amp;authority=<%= URLEncoder.encode(results[i][1], "UTF-8")%>" class="authority <%= bix.getName()%>"><%= Utils.addEntities(results[i][0])%></a> <% } else {%>&amp;value=<%= URLEncoder.encode(results[i][0], "UTF-8")%>"><%= Utils.addEntities(results[i][0])%></a> <% }%>
                </td>
            </tr>
            <%
                    row = (row.equals("odd") ? "even" : "odd");
                }
            %>
        </table>

        <%-- give us the bottom report on what we are looking at --%>
        <div align="center" class="browse_range">
            <fmt:message key="browse.single.range">
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
            <a href="<%= prev%>"><fmt:message key="browse.single.prev"/></a>&nbsp;
            <%
                }
            %>

            <%
                if (bi.hasNextPage()) {
            %>
            &nbsp;<a href="<%= next%>"><fmt:message key="browse.single.next"/></a>
            <%
                }
            %>
        </div>

        <%-- dump the results for debug (uncomment to enable) --%>
        <%-- 
        <!-- <%= bi.toString() %> -->
        --%>
    </div>
        <dspace:sidebar>
            <embed height="349" width="240" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" 
            src="/dspace/image/vnptipcv2.swf" play="true" loop="true" menu="true">
        <div class="div_box_rightbar">
                <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_good.png"/>Liên kết</h3>
                <%= adventiseNews%>
        </div>
        </dspace:sidebar>
</dspace:layout>
