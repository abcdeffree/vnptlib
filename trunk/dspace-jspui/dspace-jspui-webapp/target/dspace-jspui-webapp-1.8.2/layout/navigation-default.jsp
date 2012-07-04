<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.core.Context"%>
<%@page import="org.dspace.content.Collection"%>
<%@page import="org.dspace.app.webui.util.UIUtil"%>
<%@page import="org.dspace.browse.ItemCounter"%>
<%@page import="org.dspace.browse.ItemCountException"%>
<%@page import="org.dspace.content.Community"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.io.IOException"%>
<%@page import="org.dspace.core.ConfigurationManager"%>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%--
  - Default navigation bar
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>
<script  >
    jQuery(document).ready(function(){
        jQuery("#navigation").treeview({
            control: "#treecontrol",
            persist: "cookie",
            cookieId: "treeview-black",
            speed: "fast",
            collapsed: false
            });
    });
</script>
<%!    JspWriter out = null;
    HttpServletRequest request = null;

    void setContext(JspWriter out, HttpServletRequest request) {
        this.out = out;
        this.request = request;
    }

    void showCommunity(Community c) throws ItemCountException, IOException, SQLException {
        ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
        out.println("<li>");
        out.println("<span class=\"folder\"><strong><a href=\"" + request.getContextPath() + "/handle/" + c.getHandle() + "\">" + c.getMetadata("name") + "</a></strong>");
        if (ConfigurationManager.getBooleanProperty("webui.strengths.show")) {
            out.println("<span class=\"communityStrength\">[" + ic.getCount(c) + "]</span>");
        }
        out.println("</span>");
        // Get the collections in this community
        Collection[] cols = c.getCollections();
        if (cols.length > 0) {
            out.println("<ul>");
            for (int j = 0; j < cols.length; j++) {
                out.println("<li>");
                out.println("<span class=\"folder\">"
                        + "<a href=\"" + request.getContextPath() + "/handle/" + cols[j].getHandle() + "\">" + cols[j].getMetadata("name") + "</a>");
                if (ConfigurationManager.getBooleanProperty("webui.strengths.show")) {
                    out.println("<span class=\"collectionStrength\">[" + ic.getCount(cols[j]) + "]</span>");
                }
                out.println("</span>");
                out.println("</li>");
            }
            out.println("</ul>");
        }

        // Get the sub-communities in this community
        Community[] comms = c.getSubcommunities();
        if (comms.length > 0) {
            out.println("<ul>");
            for (int k = 0; k < comms.length; k++) {
                showCommunity(comms[k]);
            }
            out.println("</ul>");
        }
        out.println("</li>");
    }
%>
<%
    Context context = UIUtil.obtainContext(request);
    Community[] communities = Community.findAllTop(context);
    if (communities.length != 0) {
%>
<div class="div_box_navigation">
    <h3>Danh mục tài liệu</h3>
    <ul id="navigation" class="filetree treeview">
        <%
            if (true) {
                setContext(out, request);
                for (int i = 0; i < communities.length; i++) {
                    showCommunity(communities[i]);
                }
            } else {
                for (int i = 0; i < communities.length; i++) {
        %>		

        <%                        }
            }
        %>
    </ul>
    <div id="treecontrol">
        <a href="#"></a><a href="#"></a><a href="#"></a>
    </div>
</div>
<% 
    }
%>