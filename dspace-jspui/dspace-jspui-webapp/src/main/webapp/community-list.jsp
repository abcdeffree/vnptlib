<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%--
  - Display hierarchical list of communities and collections
  -
  - Attributes to be passed in:
  -    communities         - array of communities
  -    collections.map  - Map where a keys is a community IDs (Integers) and 
  -                      the value is the array of collections in that community
  -    subcommunities.map  - Map where a keys is a community IDs (Integers) and 
  -                      the value is the array of subcommunities in that community
  -    admin_button - Boolean, show admin 'Create Top-Level Community' button
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
	
<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.ItemCountException" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@page import="org.dspace.content.DCValue"%>
<%@page import="org.dspace.content.Item"%>
<%@page import="org.dspace.app.webui.components.RecentSubmissions"%>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<script  >
    jQuery(document).ready(function(){
        jQuery("#communities").treeview({
            control: "#treecontrol",
            persist: "cookie",
            cookieId: "treeview-black",
            speed: "fast",
            collapsed: false
            });
    });
</script>
<%
    Community[] communities = (Community[]) request.getAttribute("communities");
    Map collectionMap = (Map) request.getAttribute("collections.map");
    Map subcommunityMap = (Map) request.getAttribute("subcommunities.map");
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    boolean showAll = true;
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>

<%!
    JspWriter out = null;
    HttpServletRequest request = null;

    void setContext(JspWriter out, HttpServletRequest request)
    { 
        this.out = out;
        this.request = request;
    }

    void showCommunity(Community c) throws ItemCountException, IOException, SQLException
    {
    	ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
        out.println( "<li>" );
        out.println( "<span class=\"folder\"><strong><a href=\"" + request.getContextPath() + "/handle/" + c.getHandle() + "\">" + c.getMetadata("name") + "</a></strong>");
        if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
        {
            out.println("<span class=\"communityStrength\">[" + ic.getCount(c) + "]</span>");
        }
        out.println("</span>");
        // Get the collections in this community
        Collection[] cols = c.getCollections();
        if (cols.length > 0)
        {
            out.println("<ul>");
            for (int j = 0; j < cols.length; j++)
            {
                out.println("<li>");
                out.println("<span class=\"folder\">"
                        + "<a href=\"" + request.getContextPath() + "/handle/" + cols[j].getHandle() + "\">" + cols[j].getMetadata("name") +"</a>");
                if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                {
                    out.println("<span class=\"collectionStrength\">[" + ic.getCount(cols[j]) + "]</span>");
                }
                out.println("</span>");
                out.println("</li>");
            }
            out.println("</ul>");
        }

        // Get the sub-communities in this community
        Community[] comms = c.getSubcommunities();
        if (comms.length > 0)
        {
            out.println("<ul>");
            for (int k = 0; k < comms.length; k++)
            {
               showCommunity(comms[k]);
            }
            out.println("</ul>"); 
        }
        out.println("</li>");
    }
%>

<dspace:layout titlekey="jsp.community-list.title">
<div class="div_home_content">
    <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/folder.png"/><fmt:message key="jsp.community-list.title"/></h3>
    <p><fmt:message key="jsp.community-list.text1"/></p>
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
<div class="div_box_rightbar">
            <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_new.png"/><fmt:message key="jsp.community-home.recentsub"/></h3>
<%
RecentSubmissions rs = (RecentSubmissions) request.getAttribute("recently.submitted");
        if (rs != null)
        {
                Item[] items = rs.getRecentSubmissions();
                for (int i = 0; i < items.length; i++)
                {
                        DCValue[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
                        String displayTitle = "Untitled";
                        if (dcv != null)
                        {
                                if (dcv.length > 0)
                                {
                                        displayTitle = dcv[0].value;
                                }
                        }
                        %><p class="recentItem">
                            <img  class="a_recentitem" src="./image/transparent.gif"/>
                            <a href="<%= request.getContextPath() %>/handle/<%= items[i].getHandle() %>"><%= displayTitle %></a></p><%
                }
        }
%>
</div>
</dspace:sidebar>
<% if (communities.length != 0)
{
%>
    <ul id="communities" class="filetree treeview">
<%
    if (showAll)
    {
        setContext(out, request);
        for (int i = 0; i < communities.length; i++)
        {
            showCommunity(communities[i]);
        }
     }
     else
     {
        for (int i = 0; i < communities.length; i++)
        {
%>		
            <li class="communityLink">
            <%-- HACK: <strong> tags here for broken Netscape 4.x CSS support --%>
            <span><a href="<%= request.getContextPath() %>/handle/<%= communities[i].getHandle() %>"><%= communities[i].getMetadata("name") %></a></span>
	    <ul>
<%
            // Get the collections in this community from the map
            Collection[] cols = (Collection[]) collectionMap.get(
                new Integer(communities[i].getID()));

            for (int j = 0; j < cols.length; j++)
            {
%>
                <li class="collectionListItem">
                <a href="<%= request.getContextPath() %>/handle/<%= cols[j].getHandle() %>"><%= cols[j].getMetadata("name") %></a>
<%
                if (ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                {
%>
                    [<%= ic.getCount(cols[j]) %>]
<%
                }
%>

				</li>
<%
            }
%>
            </ul>
	    <ul>
<%
            // Get the sub-communities in this community from the map
            Community[] comms = (Community[]) subcommunityMap.get(
                new Integer(communities[i].getID()));

            for (int k = 0; k < comms.length; k++)
            {
%>
                <li class="communityLink">
                <a href="<%= request.getContextPath() %>/handle/<%= comms[k].getHandle() %>"><%= comms[k].getMetadata("name") %></a>
<%
                if (ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                {
%>
                    [<%= ic.getCount(comms[k]) %>]
<%
                }
%>
				</li>
<%
            }
%>
            </ul>
            <br />
        </li>
<%
        }
    }
%>
    </ul>
    <div id="treecontrol">
            <a href="#"></a><a href="#"></a><a href="#"></a>
    </div>
<% }
%>
</div>
</dspace:layout>
