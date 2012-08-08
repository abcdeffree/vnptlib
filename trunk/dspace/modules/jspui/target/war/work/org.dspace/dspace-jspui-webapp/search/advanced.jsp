<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Set"%>
<%@page import="org.dspace.content.Item"%>
<%@page import="org.dspace.content.Collection"%>
<%@page import="org.dspace.sort.SortOption"%>
<%@page import="org.dspace.sort.SortOption"%>
<%--
  - Advanced Search JSP
  -
  -
  -
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.search.QueryResults" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@page import="java.util.ArrayList"%>
<%@page import="java.lang.String"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>


<%
    Community[] communityArray = (Community[]) request.getAttribute("communities");

       Map<String, List<String>> queryMap = (Map<String, List<String>>) request.getAttribute("queryMap");
    QueryResults qResults = (QueryResults) request.getAttribute("queryresults");
    String num_search_field = request.getParameter("num_search_field") == null ? "4" : request.getParameter("num_search_field");
    int numField = Integer.parseInt(num_search_field);
    // Get the attributes
    Community community = (Community) request.getAttribute("community");
    Collection collection = (Collection) request.getAttribute("collection");
    //Community[] communityArray   = (Community[] ) request.getAttribute("community.array");
    Collection[] collectionArray = (Collection[]) request.getAttribute("collection.array");

%>
<script>
    jQuery(document).ready(function(){
        jQuery(".add_search_row").click(function(event){
            event.preventDefault();
            var numField = parseInt(jQuery("#num_search_field").val());
            jQuery("#num_search_field").val(numField+1);
            var row_search_content = jQuery(".row_search_div_origin"+numField).html();
            jQuery(".div_search_content").append(row_search_content);
        })
    });
</script>
<dspace:layout locbar="nolink" titlekey="jsp.search.advanced.title">
    <div class="div_home_content">
        <h3><fmt:message key="jsp.layout.navbar-default.advanced"/></h3>
        <form action="<%= request.getContextPath()%>/simple-search" method="get">
            <input type="hidden" name="advanced" value="true"/>
            <input type="hidden" name="num_search_field" value="<%=num_search_field%>" id="num_search_field"/>
            <div class="div_search_content">
                <div>
                    <strong><fmt:message key="jsp.search.advanced.search"/></strong>
                    &nbsp;
                    <select name="location" id="tlocation">
                    <%
                        if (community == null && collection == null) {
                            // Scope of the search was all of DSpace.  The scope control will list
                            // "all of DSpace" and the communities.
                    %>
                    <%-- <option selected value="/">All of DSpace</option> --%>
                    <option selected="selected" value="/"><fmt:message key="jsp.general.genericScope"/></option>
                    <%
                        for (int i = 0; i < communityArray.length; i++) {
                    %>
                    <option value="<%= communityArray[i].getHandle()%>"><%= communityArray[i].getMetadata("name")%></option>
                    <%
                        }
                    } else if (collection == null) {
                        // Scope of the search was within a community.  Scope control will list
                        // "all of DSpace", the community, and the collections within the community.
                    %>
                    <%-- <option value="/">All of DSpace</option> --%>
                    <option value="/"><fmt:message key="jsp.general.genericScope"/></option>
                    <option selected="selected" value="<%= community.getHandle()%>"><%= community.getMetadata("name")%></option>
                    <%
                        for (int i = 0; i < collectionArray.length; i++) {
                    %>
                    <option value="<%= collectionArray[i].getHandle()%>"><%= collectionArray[i].getMetadata("name")%></option>
                    <%
                        }
                    } else {
                        // Scope of the search is a specific collection
                    %>
                    <%-- <option value="/">All of DSpace</option> --%>
                    <option selected="selected" value="/"><fmt:message key="jsp.general.genericScope"/></option>

                        <%
                            for (int i = 0; i < communityArray.length; i++) {
                        %>
                        <option value="<%= communityArray[i].getHandle()%>"><%= communityArray[i].getMetadata("name")%></option>
                        <%
                            }
                        %>
                    <%
                        }
                    %>
                    </select>
                </div>
                <%
                    List<String> querys = new ArrayList<String>();
                    List<String> fields = new ArrayList<String>();
                    List<String> conjunctions = new ArrayList<String>();
                    if (queryMap != null) {
                        querys = (List<String>) queryMap.get("query");
                        fields = (List<String>) queryMap.get("field");
                        conjunctions = (List<String>) queryMap.get("conjunction");
                    }
                    for (int i = 0; i < numField - 1; i++) {
                        String query = "";
                        try {
                            query = querys.get(i);
                        } catch (Exception e) {
                        }
                        String field = "ANY";
                        try {
                            field = fields.get(i);
                        } catch (Exception e) {
                        }
                        String conjunction = null;
                        try {
                            if (i > 0) {
                                conjunction = conjunctions.get(i - 1);
                            }
                        } catch (Exception e) {
                            conjunction = "AND";
                        }
                %>
                <div class="row_search_div">
                    <%if (conjunction != null) {%>
                    <select name="conjunction<%=i + 1%>">
                        <option value="AND" <%= conjunction.equals("AND") ? "selected=\"selected\"" : ""%>> <fmt:message key="jsp.search.advanced.logical.and" /> </option>
                        <option value="OR" <%= conjunction.equals("OR") ? "selected=\"selected\"" : ""%>> <fmt:message key="jsp.search.advanced.logical.or" /> </option>
                        <option value="NOT" <%= conjunction.equals("NOT") ? "selected=\"selected\"" : ""%>> <fmt:message key="jsp.search.advanced.logical.not" /> </option>
                    </select>
                    <%}%>
                    <select name="field<%=i + 1%>">
                        <option value="ANY" <%= field.equals("ANY") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.keyword"/></option>
                        <option value="author" <%= field.equals("author") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.author"/></option>
                        <option value="title" <%= field.equals("title") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.title"/></option>
                        <option value="keyword" <%= field.equals("keyword") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.subject"/></option>
                        <option value="abstract" <%= field.equals("abstract") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.abstract"/></option>
                        <option value="series" <%= field.equals("series") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.series"/></option>
                        <option value="sponsor" <%= field.equals("sponsor") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.sponsor"/></option>
                        <option value="identifier" <%= field.equals("identifier") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.id"/></option>
                        <option value="language" <%= field.equals("language") ? "selected=\"selected\"" : ""%>><fmt:message key="jsp.search.advanced.type.language"/></option>
                    </select>
                    <input type="text" name="query<%=i + 1%>" value="<%=StringEscapeUtils.escapeHtml(query)%>" size="30"/>
                </div>
                <%
                    }
                %>
            </div>
            <div class="div_action_search">
                <a href="" class="add_search_row" id="add_search_row">Thêm dòng</a>
                &nbsp; &nbsp; &nbsp;
                <%-- <input type="submit" name="submit" value="Search"> --%>
                <input type="submit" name="submit" value="<fmt:message key="jsp.search.advanced.search2"/>" />
                &nbsp;  &nbsp; &nbsp;
                <%-- <input type="reset" name="reset" value=" Clear "> --%>
                <input type="reset" name="reset" value=" <fmt:message key="jsp.search.advanced.clear"/>" />
            </div>
        </form>
        <%for (int j = 1; j < 15; j++) {%>
        <div class="row_search_div_origin<%=j%>"  style="display: none;">
            <div class="row_search_div">
                <select name="conjunction<%=j - 1%>">
                    <option value="AND" selected=\"selected\"> <fmt:message key="jsp.search.advanced.logical.and" /> </option>
                    <option value="OR"> <fmt:message key="jsp.search.advanced.logical.or" /> </option>
                    <option value="NOT"> <fmt:message key="jsp.search.advanced.logical.not" /> </option>
                </select>
                <select name="field<%=j%>">
                    <option value="ANY" selected=\"selected\"><fmt:message key="jsp.search.advanced.type.keyword"/></option>
                    <option value="author"><fmt:message key="jsp.search.advanced.type.author"/></option>
                    <option value="title"><fmt:message key="jsp.search.advanced.type.title"/></option>
                    <option value="keyword"><fmt:message key="jsp.search.advanced.type.subject"/></option>
                    <option value="abstract"><fmt:message key="jsp.search.advanced.type.abstract"/></option>
                    <option value="series"><fmt:message key="jsp.search.advanced.type.series"/></option>
                    <option value="sponsor"><fmt:message key="jsp.search.advanced.type.sponsor"/></option>
                    <option value="identifier"><fmt:message key="jsp.search.advanced.type.id"/></option>
                    <option value="language"><fmt:message key="jsp.search.advanced.type.language"/></option>
                </select>
                <input type="text" name="query<%=j%>" value="" size="30"/>
            </div>
        </div>
        <%}%>
    </div>
    <%if(qResults != null){%>

    <div class="div_home_content">
        <h3><fmt:message key="jsp.search.results.title"/></h3>
        <%
            String order = (String) request.getAttribute("order");
            String ascSelected = (SortOption.ASCENDING.equalsIgnoreCase(order) ? "selected=\"selected\"" : "");
            String descSelected = (SortOption.DESCENDING.equalsIgnoreCase(order) ? "selected=\"selected\"" : "");
            SortOption so = (SortOption) request.getAttribute("sortedBy");
            String sortedBy = (so == null) ? null : so.getName();

            
            Item[] items = (Item[]) request.getAttribute("items");
            Community[] communities = (Community[]) request.getAttribute("communities");
            Collection[] collections = (Collection[]) request.getAttribute("collections");

            String query = (String) request.getAttribute("query");

            //QueryResults qResults = (QueryResults)request.getAttribute("queryresults");

            int pageTotal = ((Integer) request.getAttribute("pagetotal")).intValue();
            int pageCurrent = ((Integer) request.getAttribute("pagecurrent")).intValue();
            int pageLast = ((Integer) request.getAttribute("pagelast")).intValue();
            int pageFirst = ((Integer) request.getAttribute("pagefirst")).intValue();
            int rpp = qResults.getPageSize();
            int etAl = qResults.getEtAl();

            // retain scope when navigating result sets
            String searchScope = "";
            if (community == null && collection == null) {
                searchScope = "";
            } else if (collection == null) {
                searchScope = "/handle/" + community.getHandle();
            } else {
                searchScope = "/handle/" + collection.getHandle();
            }

            // Admin user or not
            Boolean admin_b = (Boolean) request.getAttribute("admin_button");
            boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
        %>
        <% if (qResults.getErrorMsg() != null) {
                String qError = "jsp.search.error." + qResults.getErrorMsg();
        %>
        <p align="center" class="submitFormWarn"><fmt:message key="<%= qError%>"/></p>
        <%
        } else if (qResults.getHitCount() == 0) {
        %>
        <%-- <p align="center">Search produced no results.</p> --%>
        <p align="center"><fmt:message key="jsp.search.general.noresults"/></p>
        <%        } else {
        %>
        <%-- <p align="center">Results <//%=qResults.getStart()+1%>-<//%=qResults.getStart()+qResults.getHitHandles().size()%> of --%>
        <p align="center"><fmt:message key="jsp.search.results.results">
                <fmt:param><%=qResults.getStart() + 1%></fmt:param>
                <fmt:param><%=qResults.getStart() + qResults.getHitHandles().size()%></fmt:param>
                <fmt:param><%=qResults.getHitCount()%></fmt:param>
            </fmt:message></p>

        <% }%>
        <%-- Include a component for modifying sort by, order, results per page, and et-al limit --%>
        <div align="center">
            <form method="get" action="<%= request.getContextPath() + searchScope + "/simple-search"%>">
                <table border="0">
                    <tr><td>
                            <input type="hidden" name="query" value="<%= StringEscapeUtils.escapeHtml(query)%>" />
                            <fmt:message key="search.results.perpage"/>
                            <select name="rpp">
                                <%
                                    for (int i = 5; i <= 100; i += 5) {
                                        String selected = (i == rpp ? "selected=\"selected\"" : "");
                                %>
                                <option value="<%= i%>" <%= selected%>><%= i%></option>
                                <%
                                    }
                                %>
                            </select>
                            &nbsp;|&nbsp;
                            <%
                                Set<SortOption> sortOptions = SortOption.getSortOptions();
                                if (sortOptions.size() > 1) {
                            %>
                            <fmt:message key="search.results.sort-by"/>
                            <select name="sort_by">
                                <option value="0"><fmt:message key="search.sort-by.relevance"/></option>
                                <%
                                    for (SortOption sortBy : sortOptions) {
                                        if (sortBy.isVisible()) {
                                            String selected = (sortBy.getName().equals(sortedBy) ? "selected=\"selected\"" : "");
                                            String mKey = "search.sort-by." + sortBy.getName();
                                %> <option value="<%= sortBy.getNumber()%>" <%= selected%>><fmt:message key="<%= mKey%>"/></option><%
                                                            }
                                                        }
                                %>
                            </select>
                            <%
                                }
                            %>
                            <fmt:message key="search.results.order"/>
                            <select name="order">
                                <option value="ASC" <%= ascSelected%>><fmt:message key="search.order.asc" /></option>
                                <option value="DESC" <%= descSelected%>><fmt:message key="search.order.desc" /></option>
                            </select>
                            <fmt:message key="search.results.etal" />
                            <select name="etal">
                                <%
                                    String unlimitedSelect = "";
                                    if (qResults.getEtAl() < 1) {
                                        unlimitedSelect = "selected=\"selected\"";
                                    }
                                %>
                                <option value="0" <%= unlimitedSelect%>><fmt:message key="browse.full.etal.unlimited"/></option>
                                <%
                                    boolean insertedCurrent = false;
                                    for (int i = 0; i <= 50; i += 5) {
                                        // for the first one, we want 1 author, not 0
                                        if (i == 0) {
                                            String sel = (i + 1 == qResults.getEtAl() ? "selected=\"selected\"" : "");
                                %><option value="1" <%= sel%>>1</option><%
                                                        }

                                                        // if the current i is greated than that configured by the user,
                                                        // insert the one specified in the right place in the list
                                                        if (i > qResults.getEtAl() && !insertedCurrent && qResults.getEtAl() > 1) {
                                %><option value="<%= qResults.getEtAl()%>" selected="selected"><%= qResults.getEtAl()%></option><%
                                                            insertedCurrent = true;
                                                        }

                                                        // determine if the current not-special case is selected
                                                        String selected = (i == qResults.getEtAl() ? "selected=\"selected\"" : "");

                                                        // do this for all other cases than the first and the current
                                                        if (i != 0 && i != qResults.getEtAl()) {
                                %>
                                <option value="<%= i%>" <%= selected%>><%= i%></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <%-- add results per page, etc. --%>
                            <input type="submit" name="submit_search" value="<fmt:message key="search.update" />" />

                            <%
                                if (admin_button) {
                            %><input type="submit" name="submit_export_metadata" value="<fmt:message key="jsp.general.metadataexport.button"/>" /><%                    }
                            %>

                        </td></tr>
                </table>
            </form>
        </div>

        <% if (items.length > 0) {%>
        <br/>
        <dspace:itemlist items="<%= items%>" sortOption="<%= so%>" authorLimit="<%= qResults.getEtAl()%>" />
        <% }%>

        <p align="center">

            <%
                // create the URLs accessing the previous and next search result pages
                String prevURL = request.getContextPath()
                        + searchScope
                        + "/simple-search?query="
                        + URLEncoder.encode(query, "UTF-8")
                        + "&amp;sort_by=" + (so != null ? so.getNumber() : 0)
                        + "&amp;order=" + order
                        + "&amp;rpp=" + rpp
                        + "&amp;etal=" + etAl
                        + "&amp;start=";

                String nextURL = prevURL;

                prevURL = prevURL
                        + (pageCurrent - 2) * qResults.getPageSize();

                nextURL = nextURL
                        + (pageCurrent) * qResults.getPageSize();


                if (pageFirst != pageCurrent) {
            %><a href="<%= prevURL%>"><fmt:message key="jsp.search.general.previous" /></a><%
                    };


                    for (int q = pageFirst; q <= pageLast; q++) {
                        String myLink = "<a href=\""
                                + request.getContextPath()
                                + searchScope
                                + "/simple-search?query="
                                + URLEncoder.encode(query, "UTF-8")
                                + "&amp;sort_by=" + (so != null ? so.getNumber() : 0)
                                + "&amp;order=" + order
                                + "&amp;rpp=" + rpp
                                + "&amp;etal=" + etAl
                                + "&amp;start=";


                        if (q == pageCurrent) {
                            myLink = "" + q;
                        } else {
                            myLink = myLink
                                    + (q - 1) * qResults.getPageSize()
                                    + "\">"
                                    + q
                                    + "</a>";
                        }
            %>

            <%= myLink%>

            <%
                }

                if (pageTotal > pageCurrent) {
            %><a href="<%= nextURL%>"><fmt:message key="jsp.search.general.next" /></a><%
                    }
            %>

        </p>
    </div>
            <%}%>
</dspace:layout>